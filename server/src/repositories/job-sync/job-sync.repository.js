// Chỉ chứa Prisma query cho Job Sync (không có logic nghiệp vụ). Hàm nhận db = prisma làm tham số cuối.
const { prisma } = require("../../lib/prisma");

// Các cột được ghi từ job đã làm sạch (bỏ các trường phụ như applyRank, keyword...)
const JOB_COLUMNS = [
  "source", "externalId", "title", "companyName", "companyLogoUrl", "location", "workMode", "level",
  "salaryMin", "salaryMax", "salaryCurrency", "description", "requiredSkills", "niceToHave", "applyUrl", "dedupeKey",
];

function toColumns(job) {
  return Object.fromEntries(JOB_COLUMNS.filter((c) => job[c] !== undefined).map((c) => [c, job[c]]));
}

// Toàn bộ job đang có (đủ trường để so trùng). Bảng jobs nhỏ nên đọc hết.
async function findJobsForDedupe(db = prisma) {
  return db.job.findMany({
    select: {
      id: true, source: true, externalId: true, title: true, companyName: true, companyLogoUrl: true,
      location: true, salaryMin: true, salaryMax: true, salaryCurrency: true, description: true,
      requiredSkills: true, niceToHave: true, applyUrl: true, status: true, createdAt: true,
    },
  });
}

// Lưu trong 1 giao dịch: có rồi (source, externalId) thì cập nhật, chưa có thì thêm; sửa các dòng DB trùng với bản mới.
async function saveJobs({ jobs, dbPatches, touchedDbIds, now }, db = prisma) {
  return db.$transaction(
    async (tx) => {
      for (const job of jobs) {
        const data = { ...toColumns(job), lastSeenAt: now, status: "open" };
        await tx.job.upsert({
          where: { source_externalId: { source: job.source, externalId: job.externalId } },
          create: { ...data, recruiterId: null },
          update: data,
        });
      }
      for (const patch of dbPatches) {
        await tx.job.update({ where: { id: patch.id }, data: patch.data });
      }
      if (touchedDbIds.length > 0) {
        await tx.job.updateMany({ where: { id: { in: touchedDbIds } }, data: { lastSeenAt: now } });
      }
    },
    { timeout: 120000, maxWait: 20000 }
  );
}

// Đóng job nguồn ngoài không còn thấy trên nguồn từ trước mốc cutoff. Trả số job đã đóng.
async function closeStaleJobs(cutoff, db = prisma) {
  const result = await db.job.updateMany({
    where: { source: { not: "internal" }, status: "open", lastSeenAt: { lt: cutoff } },
    data: { status: "closed" },
  });
  return result.count;
}

async function createRun(dryRun, db = prisma) {
  return db.jobSyncRun.create({ data: { dryRun } });
}

async function finishRun(id, stats, db = prisma) {
  return db.jobSyncRun.update({ where: { id }, data: { finishedAt: new Date(), stats } });
}

// Thống kê từ khóa của lượt thật gần nhất (để xếp lại thứ tự từ khóa)
async function findLastKeywordStats(db = prisma) {
  const run = await db.jobSyncRun.findFirst({
    where: { dryRun: false, finishedAt: { not: null } },
    orderBy: { startedAt: "desc" },
  });
  return (run && run.stats && run.stats.keywords) || {};
}

module.exports = { findJobsForDedupe, saveJobs, closeStaleJobs, createRun, finishRun, findLastKeywordStats };
