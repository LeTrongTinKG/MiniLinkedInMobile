const cron = require("node-cron");
const { prisma } = require("../lib/prisma");
const repo = require("../repositories/job-sync/job-sync.repository");
const { runSync } = require("./job-sync/job-sync.service");

const adapters = {
  jsearch: require("./job-sync/adapters/jsearch.adapter"),
  serpapi: require("./job-sync/adapters/serpapi.adapter"),
  remotive: require("./job-sync/adapters/remotive.adapter"),
};

let isRunning = false;

/**
 * Thực hiện một chu kỳ đồng bộ việc làm tự động
 */
async function runJobSync() {
  if (isRunning) {
    console.log("[JobCron] Chu kỳ đồng bộ trước vẫn đang chạy, bỏ qua lượt này.");
    return { skipped: true };
  }

  isRunning = true;
  const startedAt = new Date();
  try {
    const { report } = await runSync({ dryRun: false, useCache: false }, { repo, adapters, db: prisma });
    const { saved = {}, closed = 0 } = report;
    console.log(
      `[JobCron] Đồng bộ hoàn tất: +${saved.inserted || 0} mới, ` +
        `~${saved.updated || 0} cập nhật, -${closed} hết hạn (${Date.now() - startedAt.getTime()}ms)`
    );
    return report;
  } catch (error) {
    const safeMsg = String(error.message).replace(/(api_key|key|token)=[^&\s]+/gi, "$1=***");
    console.warn("[JobCron] Lỗi chu kỳ đồng bộ việc làm:", safeMsg);
    return { error: safeMsg };
  } finally {
    isRunning = false;
  }
}

/**
 * Khởi động cron job đồng bộ định kỳ mỗi 6 giờ và kích hoạt 1 lần khi server sẵn sàng
 */
function startJobCron() {
  console.log("⏰ [JobCron] Đã kích hoạt cron job tự động đồng bộ việc làm (mỗi 6 giờ)");

  // Kích hoạt sau 8 giây để server và DB khởi động hoàn chỉnh
  setTimeout(() => {
    runJobSync().catch((err) => console.warn("[JobCron] Lỗi lượt đầu:", err.message));
  }, 8000);

  // Định kỳ mỗi 6 giờ (lúc 0h, 6h, 12h, 18h)
  cron.schedule("0 */6 * * *", () => {
    runJobSync().catch((err) => console.warn("[JobCron] Lỗi định kỳ:", err.message));
  });
}

module.exports = {
  startJobCron,
  runJobSync,
};

