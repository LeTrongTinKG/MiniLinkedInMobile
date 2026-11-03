// Bộ điều phối (quản đốc bếp): không tự gọi API, không tự lọc, chỉ giao việc theo thứ tự và ghi sổ.
// ① mở sổ -> ② ③ gọi nguồn + làm sạch -> ④ lọc trùng -> ⑤ lưu DB -> ⑥ đóng job cũ + chốt sổ
const defaultConfig = require("./keywords.config");
const { collectJobs } = require("./collect");
const { dedupeJobs, makeDedupeKey } = require("./dedupe/merge");
const { orderKeywords, isLowQuality, buildReport } = require("./report");

const DAY_MS = 24 * 60 * 60 * 1000;

// Remotive chỉ được chiếm tối đa maxShare tổng số job (giữ job mới nhất trước)
function capRemotive(jobs, maxShare) {
  const others = jobs.filter((j) => j.source !== "remotive");
  const remotive = jobs.filter((j) => j.source === "remotive");
  const maxRemotive = others.length === 0 ? 25 : Math.floor((others.length * maxShare) / (1 - maxShare));
  const sorted = [...remotive].sort((a, b) => (b.postedAt || 0) - (a.postedAt || 0));
  return { jobs: [...others, ...sorted.slice(0, maxRemotive)], dropped: remotive.length - Math.min(remotive.length, maxRemotive) };
}

// deps: { repo, adapters, db, config, env } — truyền vào để test không cần DB/mạng thật
async function runSync(options, deps) {
  const { dryRun = false, useCache = false } = options;
  const { repo, adapters, db } = deps;
  const config = deps.config || defaultConfig;
  const now = options.now || new Date();
  const startedAt = new Date();

  // ① Mở sổ (chạy thử thì không ghi)
  const run = dryRun ? null : await repo.createRun(false, db);
  const lastStats = await repo.findLastKeywordStats(db);
  const keywords = orderKeywords(config.KEYWORDS, lastStats);

  // ②③ Gọi nguồn + làm sạch
  const collected = await collectJobs({ adapters, keywords, config, useCache, now, env: deps.env || process.env });

  // ④ Lọc trùng (trong lượt + so với DB) và giới hạn Remotive
  const dbJobs = await repo.findJobsForDedupe(db);
  const existingKeys = new Set(dbJobs.map((j) => `${j.source}|${j.externalId}`));
  const withKeys = collected.jobs.map((j) => ({ ...j, dedupeKey: makeDedupeKey(j) }));
  const deduped = dedupeJobs(withKeys, dbJobs);
  const capped = capRemotive(deduped.kept, config.REMOTIVE_MAX_SHARE);

  // ⑤ Lưu DB (1 giao dịch)
  const inserted = capped.jobs.filter((j) => !existingKeys.has(`${j.source}|${j.externalId}`)).length;
  const saved = { inserted, updated: capped.jobs.length - inserted };
  if (!dryRun) {
    await repo.saveJobs({ jobs: capped.jobs, dbPatches: deduped.dbPatches, touchedDbIds: deduped.touchedDbIds, now }, db);
  }

  // ⑥ Đóng job lâu không thấy + chốt sổ
  const closed = dryRun ? 0 : await repo.closeStaleJobs(new Date(now.getTime() - config.CLOSE_AFTER_DAYS * DAY_MS), db);
  const flaggedKeywords = Object.keys(collected.keywordStats).filter((k) => k !== "remotive" && isLowQuality(collected.keywordStats[k]));
  const report = buildReport({
    startedAt,
    finishedAt: new Date(),
    dryRun,
    collected,
    dedupe: { duplicates: deduped.duplicates, remotiveOverCap: capped.dropped, finalCount: capped.jobs.length },
    saved,
    closed,
    flaggedKeywords,
  });
  if (run) await repo.finishRun(run.id, report, db);

  return { report, jobs: capped.jobs };
}

module.exports = { runSync, capRemotive };
