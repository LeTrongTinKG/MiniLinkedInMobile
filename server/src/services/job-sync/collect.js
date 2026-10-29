// Bước ②③: gọi các nguồn trong ngân sách, làm sạch từng job, đếm job bị loại theo lý do.
const { cleanJob } = require("./cleaner/clean-job");
const { maskSecrets } = require("./adapters/http");

const REASONS = ["tooOld", "wrongLocation", "noLink", "notIT", "invalid", "duplicate"];

function newSourceStats() {
  return { requests: 0, fromCache: 0, fetched: 0, kept: 0, error: null };
}

// config: cấu hình; adapters: { jsearch, serpapi, remotive } mỗi cái có search(keyword, opts)
async function collectJobs({ adapters, keywords, config, useCache, now, env }) {
  const seen = new Map(); // "nguồn|mã gốc" -> job sạch (tầng 1: không trùng trong cùng nguồn)
  const rejected = Object.fromEntries(REASONS.map((r) => [r, 0]));
  const sources = { jsearch: newSourceStats(), serpapi: newSourceStats(), remotive: newSourceStats() };
  const keywordStats = {}; // keyword -> { fetched, kept }

  // Nhận 1 lô job thô: làm sạch, loại hoặc giữ
  function ingest(sourceName, rawJobs, keyword) {
    const kw = (keywordStats[keyword] = keywordStats[keyword] || { fetched: 0, kept: 0 });
    for (const raw of rawJobs) {
      sources[sourceName].fetched++;
      kw.fetched++;
      const result = cleanJob(raw, now, { maxAgeDays: config.MAX_AGE_DAYS });
      if (!result.ok) {
        rejected[result.reason]++;
        continue;
      }
      const key = `${result.job.source}|${result.job.externalId}`;
      if (seen.has(key)) {
        rejected.duplicate++;
        continue;
      }
      seen.set(key, result.job);
      sources[sourceName].kept++;
      kw.kept++;
    }
  }

  // Gọi 1 request, ghi lỗi (đã che key) nếu hỏng. Trả số job sạch mới có thêm, hoặc null nếu lỗi.
  async function callSource(sourceName, keyword) {
    const stats = sources[sourceName];
    stats.requests++;
    const before = stats.kept;
    try {
      const { rawJobs, fromCache } = await adapters[sourceName].search(keyword, { env, useCache });
      if (fromCache) stats.fromCache++;
      ingest(sourceName, rawJobs, keyword);
      return stats.kept - before;
    } catch (error) {
      stats.error = maskSecrets(error.message);
      return null;
    }
  }

  const enough = () => seen.size >= config.TARGET_JOBS;
  const hasBudget = (name) => sources[name].requests < config.BUDGET[name] && !sources[name].error;

  // Remotive: 1 lần mỗi lượt
  if (hasBudget("remotive")) await callSource("remotive", "remotive");

  // JSearch: chạy cho từng từ khóa đến khi hết ngân sách hoặc đủ job
  const weakKeywords = []; // từ khóa JSearch ra ít job sạch -> nhờ SerpApi bù
  for (const keyword of keywords) {
    if (enough() || !hasBudget("jsearch")) break;
    const added = await callSource("jsearch", keyword);
    if (added === null || added < config.MIN_CLEAN_PER_KEYWORD) weakKeywords.push(keyword);
  }

  // SerpApi: chỉ cho các từ khóa yếu (và các từ khóa JSearch chưa kịp chạy)
  const notRun = keywords.filter((k) => !keywordStats[k]);
  for (const keyword of new Set([...weakKeywords, ...notRun])) {
    if (enough() || !hasBudget("serpapi")) break;
    await callSource("serpapi", keyword);
  }

  return { jobs: [...seen.values()], rejected, sources, keywordStats };
}

module.exports = { collectJobs, REASONS };
