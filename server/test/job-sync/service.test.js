// Test cleanJob + adapter + bộ điều phối với repo/adapter giả (không gọi mạng, không chạm DB)
const test = require("node:test");
const assert = require("node:assert");
const { cleanJob } = require("../../src/services/job-sync/cleaner/clean-job");
const jsearch = require("../../src/services/job-sync/adapters/jsearch.adapter");
const remotive = require("../../src/services/job-sync/adapters/remotive.adapter");
const { maskSecrets } = require("../../src/services/job-sync/adapters/http");
const { runSync, capRemotive } = require("../../src/services/job-sync/job-sync.service");
const { orderKeywords } = require("../../src/services/job-sync/report");

const NOW = new Date("2026-10-28T00:00:00Z");

function rawJob(overrides) {
  return {
    source: "jsearch", externalId: "j1", title: "Junior Node.js Developer", company: "Acme Vietnam",
    location: "Hà Nội", descriptionRaw: "<p>Yêu cầu:</p><ul><li>Node.js, Docker</li></ul>",
    applyLinks: [{ url: "https://vn.linkedin.com/jobs/view/1?utm_source=x" }], ...overrides,
  };
}

test("cleanJob: job hợp lệ ra đủ trường, mô tả đã xóa HTML", () => {
  const result = cleanJob(rawJob(), NOW);
  assert.ok(result.ok);
  assert.strictEqual(result.job.level, "junior");
  assert.strictEqual(result.job.location, "Hà Nội");
  assert.strictEqual(result.job.applyUrl, "https://vn.linkedin.com/jobs/view/1");
  assert.ok(!result.job.description.includes("<"));
  assert.ok(result.job.requiredSkills.includes("nodejs"));
});

test("cleanJob: loại đúng lý do", () => {
  const reason = (o) => cleanJob(rawJob(o), NOW).reason;
  assert.strictEqual(reason({ postedAt: "2026-01-01T00:00:00Z" }), "tooOld");
  assert.strictEqual(reason({ location: "Singapore" }), "wrongLocation");
  assert.strictEqual(reason({ applyLinks: [{ url: "http://x.com" }] }), "noLink");
  assert.strictEqual(cleanJob(rawJob({ title: "Senior Node.js Developer" }), NOW).job.level, "senior");
  assert.strictEqual(reason({ title: "Sales Executive", descriptionRaw: "Bán hàng" }), "notIT");
  assert.strictEqual(reason({ externalId: null }), "invalid");
});

test("adapter JSearch/Remotive: đổi sang RawJob đúng trường", () => {
  const item = {
    job_id: "abc", job_title: "Dev", employer_name: "Acme", job_location: "Việt Nam • qua LinkedIn", job_country: null,
    job_description: "mô tả", apply_options: [{ apply_link: "https://vn.linkedin.com/x", is_direct: false }],
    job_is_remote: false, job_min_salary: 1, job_max_salary: 2, job_salary_currency: "USD", job_salary_period: "MONTH",
  };
  const raw = jsearch.toRawJob(item, "kw");
  assert.strictEqual(raw.externalId, "abc");
  assert.strictEqual(raw.salaryStruct.currency, "USD");
  assert.strictEqual(raw.applyLinks[0].url, "https://vn.linkedin.com/x");

  const rem = remotive.toRawJob({ id: 7, title: "T", company_name: "C", url: "https://remotive.com/j/7", candidate_required_location: "Worldwide", publication_date: "2026-10-26T12:00:00", description: "<p>x</p>" });
  assert.strictEqual(rem.externalId, "7");
  assert.strictEqual(rem.isRemote, true);
  assert.strictEqual(rem.postedAt, "2026-10-26T12:00:00Z");
});

test("maskSecrets: che api_key trong URL và header", () => {
  const masked = maskSecrets("GET https://serpapi.com/search.json?q=a&api_key=SECRET123&hl=vi failed");
  assert.ok(!masked.includes("SECRET123"));
  assert.ok(masked.includes("api_key=***"));
});

test("capRemotive: Remotive tối đa ~20% tổng, giữ job mới nhất", () => {
  const jobs = [
    ...[1, 2, 3, 4].map((i) => ({ source: "jsearch", externalId: String(i) })),
    { source: "remotive", externalId: "old", postedAt: new Date("2026-10-01") },
    { source: "remotive", externalId: "new", postedAt: new Date("2026-10-20") },
  ];
  const result = capRemotive(jobs, 0.2);
  assert.strictEqual(result.jobs.filter((j) => j.source === "remotive").length, 1);
  assert.ok(result.jobs.some((j) => j.externalId === "new"));
  assert.strictEqual(result.dropped, 1);
});

test("orderKeywords: từ khóa ra rác lượt trước bị đẩy xuống cuối", () => {
  const order = orderKeywords(["a", "b", "c"], { a: { fetched: 10, kept: 0 }, b: { fetched: 10, kept: 8 } });
  assert.deepStrictEqual(order, ["b", "c", "a"]);
});

// Repo và adapter giả
function makeDeps(calls) {
  const repo = {
    createRun: async () => ({ id: "run-1" }),
    findLastKeywordStats: async () => ({}),
    findJobsForDedupe: async () => [],
    saveJobs: async (payload) => { calls.saved = payload; },
    closeStaleJobs: async () => 2,
    finishRun: async (id, stats) => { calls.finished = { id, stats }; },
  };
  const fake = (source, jobs) => ({
    search: async (keyword) => { calls[source] = (calls[source] || 0) + 1; return { rawJobs: jobs(keyword), fromCache: false }; },
  });
  const adapters = {
    jsearch: fake("jsearch", (kw) => [rawJob({ externalId: `j-${kw}`, title: `Junior ${kw} Node.js Developer` }), rawJob({ externalId: `s-${kw}`, title: "Dev", location: "Singapore" })]),
    serpapi: fake("serpapi", () => []),
    remotive: fake("remotive", () => []),
  };
  const config = { KEYWORDS: ["k1", "k2", "k3"], TARGET_JOBS: 2, BUDGET: { jsearch: 5, serpapi: 1, remotive: 1 }, REMOTIVE_MAX_SHARE: 0.2, MIN_CLEAN_PER_KEYWORD: 1, MAX_AGE_DAYS: 30, CLOSE_AFTER_DAYS: 14 };
  return { repo, adapters, config, db: {}, env: {} };
}

test("runSync: dừng khi đủ job sạch, ghi DB + nhật ký, thống kê lý do loại", async () => {
  const calls = {};
  const { report, jobs } = await runSync({ now: NOW }, makeDeps(calls));
  assert.strictEqual(calls.jsearch, 2); // k1, k2 đã đủ 2 job nên dừng, không gọi k3
  assert.strictEqual(report.sources.jsearch.requests, 2);
  assert.strictEqual(report.rejected.wrongLocation, 2);
  assert.strictEqual(jobs.length, 2);
  assert.strictEqual(calls.saved.jobs.length, 2);
  assert.strictEqual(calls.saved.jobs[0].dedupeKey.startsWith("acme|"), true);
  assert.strictEqual(report.closedStale, 2);
  assert.strictEqual(calls.finished.id, "run-1");
});

test("runSync --dry-run: không ghi DB, không ghi nhật ký", async () => {
  const calls = {};
  const { report } = await runSync({ now: NOW, dryRun: true }, makeDeps(calls));
  assert.strictEqual(calls.saved, undefined);
  assert.strictEqual(calls.finished, undefined);
  assert.strictEqual(report.dryRun, true);
});

test("runSync: nguồn lỗi thì ghi lỗi, nguồn khác vẫn chạy", async () => {
  const calls = {};
  const deps = makeDeps(calls);
  deps.adapters.jsearch = { search: async () => { throw new Error("Nguồn trả lỗi HTTP 429"); } };
  deps.adapters.serpapi = { search: async () => ({ rawJobs: [rawJob({ source: "serpapi", externalId: "s1" })], fromCache: false }) };
  const { report } = await runSync({ now: NOW }, deps);
  assert.match(report.sources.jsearch.error, /429/);
  assert.strictEqual(report.sources.jsearch.requests, 1); // dừng nguồn lỗi ngay, không gọi tiếp
  assert.strictEqual(report.sources.serpapi.kept, 1);
});

test("formatJob: job nguồn ngoài có recruiter null, trả source/applyUrl/salaryCurrency, giấu trường nội bộ", () => {
  const { formatJob } = require("../../src/utils/job.util");
  const out = formatJob({ id: "1", recruiter: null, source: "serpapi", applyUrl: "https://x.com", salaryCurrency: "VND", dedupeKey: "k", lastSeenAt: new Date(), externalId: "e", _count: { applications: 0 } });
  assert.strictEqual(out.recruiter, null);
  assert.strictEqual(out.source, "serpapi");
  assert.strictEqual(out.applyUrl, "https://x.com");
  assert.strictEqual(out.salaryCurrency, "VND");
  assert.strictEqual(out.dedupeKey, undefined);
  assert.strictEqual(out.externalId, undefined);
});
