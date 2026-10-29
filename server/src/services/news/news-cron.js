const cron = require("node-cron");
const hnClient = require("./hn.client");
const vnClient = require("./vn.client");
const newsRepository = require("../../repositories/news.repository");

const RETENTION_DAYS = 7;
const MAX_ARTICLES = 500;
let isSyncing = false;

/**
 * Thực hiện chu kỳ kéo từ HN + Google News VN và nạp vào Supabase
 */
async function runNewsSync(repo = newsRepository) {
  if (isSyncing) {
    return { skipped: true };
  }
  isSyncing = true;
  try {
    const [hnArticles, vnArticles] = await Promise.all([
      hnClient.fetchHnNews(),
      vnClient.fetchVnNews(),
    ]);

    const combined = [...hnArticles, ...vnArticles];
    const result = await repo.upsertArticles(combined);
    console.log(`[NewsCron] Đã đồng bộ ${result.count} tin mới vào Supabase`);

    // Dọn dẹp tin cũ > 7 ngày
    const cutoff = new Date(Date.now() - RETENTION_DAYS * 24 * 60 * 60 * 1000);
    await repo.deleteOlderThan(cutoff);
    await repo.trimOldArticles(MAX_ARTICLES);

    return { saved: result.count };
  } catch (err) {
    console.warn("[NewsCron] Lỗi chu kỳ đồng bộ tin tức:", err.message);
    return { error: err.message };
  } finally {
    isSyncing = false;
  }
}

/**
 * Bắt đầu cron job 5 phút và kích hoạt ngay 1 lần lúc khởi động server
 */
function startNewsCron() {
  console.log("⏰ [NewsCron] Đã kích hoạt cron job cập nhật tin tức mỗi 5 phút");
  // Đồng bộ ngay khi khởi động
  runNewsSync().catch((err) => console.warn("[NewsCron] Lỗi lần đầu:", err.message));

  // Lên lịch định kỳ mỗi 5 phút
  cron.schedule("*/5 * * * *", () => {
    runNewsSync().catch((err) => console.warn("[NewsCron] Lỗi định kỳ:", err.message));
  });
}

module.exports = {
  startNewsCron,
  runNewsSync,
};
