// Test chuẩn hóa tên, Jaccard và lọc trùng giữa các nguồn
const test = require("node:test");
const assert = require("node:assert");
const { normalizeCompany, normalizeTitle, titleTokens } = require("../../src/services/job-sync/dedupe/normalize");
const { jaccard } = require("../../src/services/job-sync/dedupe/jaccard");
const { dedupeJobs, scoreAgainst } = require("../../src/services/job-sync/dedupe/merge");

function job(overrides) {
  return {
    source: "jsearch", externalId: "1", title: "Flutter Developer", companyName: "FPT Software", location: "Hà Nội",
    description: "mô tả", requiredSkills: ["flutter"], niceToHave: [], applyUrl: "https://vn.linkedin.com/jobs/1",
    salaryMin: null, salaryMax: null, salaryCurrency: null, companyLogoUrl: null, postedAt: null, ...overrides,
  };
}

test("normalizeCompany: bỏ dấu, bỏ công ty/TNHH/cổ phần/Vietnam", () => {
  assert.strictEqual(normalizeCompany("Công ty TNHH FPT Software Việt Nam"), "fpt software");
  assert.strictEqual(normalizeCompany("CÔNG TY CỔ PHẦN RIKKEISOFT"), "rikkeisoft");
  assert.strictEqual(normalizeCompany("FPT Software Co., Ltd"), "fpt software");
});

test("normalizeTitle: bỏ nhiễu [HN], - Hà Nội, lương, Urgent", () => {
  assert.strictEqual(normalizeTitle("[HN] Junior Java Developer - Hà Nội"), "junior java developer");
  assert.strictEqual(normalizeTitle("URGENT Flutter Developer Lương upto 2000$"), "flutter developer");
  assert.strictEqual(normalizeTitle("JUNIOR AI ENGINEER (DA NANG)"), "junior ai engineer");
  assert.strictEqual(normalizeTitle("Lập trình viên C#, .NET"), "lap trinh vien c# .net");
});

test("jaccard: ví dụ trong thiết kế", () => {
  assert.ok(Math.abs(jaccard(titleTokens("flutter developer"), titleTokens("flutter mobile developer")) - 2 / 3) < 1e-9);
  assert.strictEqual(jaccard(titleTokens("senior java developer"), titleTokens("java developer senior")), 1);
});

test("dedupe: trùng giữa nguồn thì giữ bản điểm cao và bù lương", () => {
  const a = job({ source: "jsearch", externalId: "a" });
  const b = job({
    source: "serpapi", externalId: "b", title: "Flutter Developer - Hà Nội", companyName: "Công ty TNHH FPT Software Việt Nam",
    salaryMin: 10000000, salaryMax: 20000000, salaryCurrency: "VND", applyUrl: "https://careers.fpt.com/1", description: "mô tả dài hơn nhiều",
  });
  assert.ok(scoreAgainst(b, a) > scoreAgainst(a, b));
  const result = dedupeJobs([a, b]);
  assert.strictEqual(result.kept.length, 1);
  assert.strictEqual(result.duplicates, 1);
  assert.strictEqual(result.kept[0].source, "serpapi");

  // Bản thắng thiếu logo thì lấy từ bản thua
  const withLogo = job({ source: "jsearch", externalId: "c", companyLogoUrl: "https://logo/x.png" });
  const noLogo = job({ source: "serpapi", externalId: "d", salaryMin: 1, salaryMax: 2, salaryCurrency: "USD" });
  assert.strictEqual(dedupeJobs([withLogo, noLogo]).kept[0].companyLogoUrl, "https://logo/x.png");
});

test("dedupe: khác công ty, khác thành phố hoặc tiêu đề chỉ giống 67% thì không trùng", () => {
  const base = job({});
  assert.strictEqual(dedupeJobs([base, job({ externalId: "2", companyName: "VNG" })]).kept.length, 2);
  assert.strictEqual(dedupeJobs([base, job({ externalId: "3", location: "Đà Nẵng" })]).kept.length, 2);
  assert.strictEqual(dedupeJobs([base, job({ externalId: "4", title: "Flutter Mobile Developer" })]).kept.length, 2);
});

test("dedupe: so cả với job đã có trong DB và trả patch cho dòng DB", () => {
  const dbJob = job({ id: "db-1", source: "jsearch", externalId: "old" });
  const incoming = job({ source: "serpapi", externalId: "new", salaryMin: 5, salaryMax: 9, salaryCurrency: "USD", applyUrl: "https://careers.fpt.com/9" });
  const result = dedupeJobs([incoming], [dbJob]);
  assert.strictEqual(result.kept.length, 0);
  assert.strictEqual(result.duplicates, 1);
  assert.deepStrictEqual(result.touchedDbIds, ["db-1"]);
  assert.strictEqual(result.dbPatches[0].id, "db-1");
  assert.strictEqual(result.dbPatches[0].data.salaryMin, 5);

  // Job tự đăng (internal) không bị coi là bản sao
  const internal = job({ id: "db-2", source: "internal", externalId: null });
  assert.strictEqual(dedupeJobs([job({ externalId: "z" })], [internal]).kept.length, 1);
  // Cùng (source, externalId) với dòng DB là tầng 1 (upsert), không coi là trùng tầng 2
  assert.strictEqual(dedupeJobs([job({ source: "jsearch", externalId: "old" })], [dbJob]).kept.length, 1);
});
