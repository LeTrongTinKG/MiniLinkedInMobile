// Test các cleaner đơn giản: html, freshness, location, url, work-mode, level
const test = require("node:test");
const assert = require("node:assert");
const { stripHtml } = require("../../src/services/job-sync/cleaner/html");
const { isTooOld, getPostedDate } = require("../../src/services/job-sync/cleaner/freshness");
const { isVietnamJob, normalizeLocation } = require("../../src/services/job-sync/cleaner/location");
const { pickApplyLink, normalizeUrl } = require("../../src/services/job-sync/cleaner/url");
const { inferWorkMode } = require("../../src/services/job-sync/cleaner/work-mode");
const { inferLevel } = require("../../src/services/job-sync/cleaner/level");

const NOW = new Date("2026-10-28T00:00:00Z");

test("stripHtml: bỏ thẻ, giải mã ký tự, giữ xuống dòng giữa các đoạn", () => {
  const html = '<p>Yêu cầu:&nbsp;React &amp; Node</p><ul><li>Biết Git</li><li>It&#39;s ok &#x41;</li></ul><script>alert(1)</script>';
  const text = stripHtml(html);
  assert.strictEqual(text, "Yêu cầu: React & Node\n\n- Biết Git\n\n- It's ok A".replace("\n\n- Biết", "\n- Biết").replace("\n\n- It", "\n- It"));
  assert.ok(!text.includes("alert"));
  assert.strictEqual(stripHtml("a <b>b</b><br>c"), "a b\nc");
  assert.strictEqual(stripHtml("5 < 6 và C++ > Java"), "5 < 6 và C++ > Java");
  assert.strictEqual(stripHtml(null), "");
});

test("freshness: quá 30 ngày thì loại, không rõ ngày thì giữ", () => {
  assert.strictEqual(isTooOld({ postedAt: "2026-08-01T00:00:00Z" }, NOW), true);
  assert.strictEqual(isTooOld({ postedAt: "2026-10-20T00:00:00Z" }, NOW), false);
  assert.strictEqual(isTooOld({}, NOW), false);
  assert.strictEqual(isTooOld({ postedText: "5 ngày trước" }, NOW), false);
  assert.strictEqual(isTooOld({ postedText: "2 months ago" }, NOW), true);
  // Ngày ghi trong mô tả: dd/mm/yyyy
  assert.strictEqual(isTooOld({ descriptionRaw: "Ngày đăng: 11/12/2023\nCấp bậc" }, NOW), true);
  assert.strictEqual(getPostedDate({ descriptionRaw: "Ngày đăng: 05/10/2026" }, NOW).toISOString().slice(0, 10), "2026-10-05");
});

test("location: JSearch/SerpApi phải ở VN, Remotive chỉ nhận Worldwide/Asia/Vietnam", () => {
  assert.strictEqual(isVietnamJob({ source: "jsearch", countryCode: "VN", location: "x" }), true);
  assert.strictEqual(isVietnamJob({ source: "jsearch", countryCode: "US", location: "Việt Nam" }), false);
  assert.strictEqual(isVietnamJob({ source: "jsearch", location: "Việt Nam     •  qua LinkedIn" }), true);
  assert.strictEqual(isVietnamJob({ source: "serpapi", location: "Đà Nẵng, Hải Châu, Đà Nẵng (+1 vị trí khác)" }), true);
  assert.strictEqual(isVietnamJob({ source: "serpapi", location: "Singapore" }), false);
  assert.strictEqual(isVietnamJob({ source: "remotive", location: "Worldwide" }), true);
  assert.strictEqual(isVietnamJob({ source: "remotive", location: "USA, Canada" }), false);
  assert.strictEqual(normalizeLocation({ source: "remotive" }), "Remote");
  assert.strictEqual(normalizeLocation({ source: "jsearch", location: "Việt Nam" }), "Việt Nam");
  assert.strictEqual(normalizeLocation({ source: "jsearch", location: "Quận 1, Ho Chi Minh City" }), "TP. Hồ Chí Minh");
});

test("url: chỉ nhận https, ưu tiên web công ty > ITviec/TopCV > LinkedIn > trang tổng hợp", () => {
  assert.strictEqual(normalizeUrl("http://a.com/x"), null);
  assert.strictEqual(normalizeUrl("không phải url"), null);
  assert.strictEqual(normalizeUrl("https://a.com/x?utm_source=g&id=1"), "https://a.com/x?id=1");

  const links = [
    { url: "https://www.indeed.com/viewjob?jk=1" },
    { url: "https://vn.linkedin.com/jobs/view/1" },
    { url: "https://www.topcv.vn/viec-lam/1" },
    { url: "https://careers.fpt.com.vn/job/1" },
    { url: "http://insecure.fpt.com/1" },
  ];
  assert.strictEqual(pickApplyLink(links, "FPT Software").url, "https://careers.fpt.com.vn/job/1");
  assert.strictEqual(pickApplyLink(links.slice(0, 3)).url, "https://www.topcv.vn/viec-lam/1");
  assert.strictEqual(pickApplyLink(links.slice(0, 2)).url, "https://vn.linkedin.com/jobs/view/1");
  // Host lạ, không direct, không khớp tên công ty: bỏ. Google: bỏ.
  assert.strictEqual(pickApplyLink([{ url: "https://spam-clone.tattoo/job/1" }], "VNG"), null);
  assert.strictEqual(pickApplyLink([{ url: "https://www.google.com/search?q=job" }], "VNG"), null);
  assert.strictEqual(pickApplyLink([{ url: "https://spam-clone.tattoo/job/1", isDirect: true }], "VNG").rank, 1);
  assert.strictEqual(pickApplyLink([], "x"), null);
});

test("work-mode: cờ remote, hybrid/remote trong tiêu đề và mô tả", () => {
  assert.strictEqual(inferWorkMode({ isRemote: true, title: "Dev", description: "" }), "remote");
  assert.strictEqual(inferWorkMode({ title: "Backend Hybrid Working", description: "" }), "hybrid");
  assert.strictEqual(inferWorkMode({ title: "Dev", description: "Làm việc từ xa 2 ngày" }), "remote");
  assert.strictEqual(inferWorkMode({ title: "Dev", description: "No remote work. Office only" }), "onsite");
  assert.strictEqual(inferWorkMode({ title: "Dev", description: "" }), "onsite");
});

test("level: tiêu đề trước, rồi số năm kinh nghiệm, không loại job nào", () => {
  assert.strictEqual(inferLevel("Thực tập sinh Java", ""), "intern");
  assert.strictEqual(inferLevel("Fresher Node.js", ""), "fresher");
  assert.strictEqual(inferLevel("Junior Flutter Developer", ""), "junior");
  assert.strictEqual(inferLevel("Senior Java Developer", "fresher welcome"), "senior");
  assert.strictEqual(inferLevel("Tech Lead", ""), "lead");
  assert.strictEqual(inferLevel("Backend Developer", "Yêu cầu 3+ years of experience"), "mid");
  assert.strictEqual(inferLevel("Backend Developer", "từ 3 năm kinh nghiệm"), "mid");
  assert.strictEqual(inferLevel("Backend Developer", "5+ years of experience"), "senior");
  assert.strictEqual(inferLevel("Middle Java Developer", ""), "mid");
  assert.strictEqual(inferLevel("Backend Developer", "At least 2 years experience in Java"), "junior");
  assert.strictEqual(inferLevel("Backend Developer", "Yêu cầu kinh nghiệm: 1 năm"), "junior");
  assert.strictEqual(inferLevel("Backend Developer", "Không yêu cầu kinh nghiệm"), "fresher");
  assert.strictEqual(inferLevel("Backend Developer", "Mô tả chung"), "junior");
});

test("location: nhận tên tỉnh không có chữ Việt Nam (Bình Dương, Đồng Nai)", () => {
  assert.strictEqual(isVietnamJob({ source: "jsearch", location: "Bình Dương     •  qua JobsGO" }), true);
  assert.strictEqual(isVietnamJob({ source: "jsearch", location: "Đồng Nai     •  qua TopCV" }), true);
  assert.strictEqual(isVietnamJob({ source: "jsearch", location: "Bangkok, Thái Lan" }), false);
});
