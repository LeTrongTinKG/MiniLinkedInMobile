// Chạy lần lượt các bộ lọc (rẻ trước, đắt sau) cho 1 job thô (RawJob).
// Trả { ok: true, job } hoặc { ok: false, reason } với reason: tooOld | wrongLocation | noLink | notIT | invalid
const { isTooOld, getPostedDate } = require("./freshness");
const { isVietnamJob, normalizeLocation } = require("./location");
const { pickApplyLink } = require("./url");
const { inferLevel } = require("./level");
const { stripHtml } = require("./html");
const { extractSkills } = require("./skills");
const { parseSalary } = require("./salary");
const { inferWorkMode } = require("./work-mode");

// Từ khóa IT trong tiêu đề (đủ để coi là job IT dù ít kỹ năng được nhận ra)
const IT_TITLE_RE = /\b(developer|programmer|software|frontend|front-end|backend|back-end|full[\s-]?stack|devops|tester|qa|qc|data|mobile|web|ai[\s-](engineer|developer|agent)|ml|it|dev|coder)\b|lập trình|phần mềm|kiểm thử|an ninh mạng|cntt/i;

function cleanJob(raw, now = new Date(), options = {}) {
  const maxAgeDays = options.maxAgeDays || 30;

  // 1. Còn mới
  if (isTooOld(raw, now, maxAgeDays)) return { ok: false, reason: "tooOld" };

  // 2. Địa điểm
  if (!isVietnamJob(raw)) return { ok: false, reason: "wrongLocation" };

  // 3. Link ứng tuyển
  const link = pickApplyLink(raw.applyLinks, raw.company);
  if (!link) return { ok: false, reason: "noLink" };

  // Dữ liệu tối thiểu
  const title = String(raw.title || "").replace(/\s+/g, " ").trim();
  const companyName = String(raw.company || "").replace(/\s+/g, " ").trim();
  if (!raw.externalId || !title || !companyName) return { ok: false, reason: "invalid" };

  // 5. Xóa HTML (làm trước bước 4 để đọc cấp độ trên chữ sạch)
  const description = stripHtml(raw.descriptionRaw);

  // 4. Cấp độ (chỉ phân loại, không loại job)
  const level = inferLevel(title, description);

  // 6 + 7. Kỹ năng, đúng ngành IT (>= 2 kỹ năng hoặc tiêu đề có từ khóa IT)
  const { requiredSkills, niceToHave } = extractSkills(title, description);
  const skillCount = requiredSkills.length + niceToHave.length;
  if (skillCount < 2 && !IT_TITLE_RE.test(title)) return { ok: false, reason: "notIT" };

  // 8. Lương (không loại, chỉ để trống)
  const salary = parseSalary(raw.salaryStruct, raw.salaryText);

  // 9. Hình thức làm việc
  const workMode = inferWorkMode({ isRemote: raw.isRemote, title, description });

  return {
    ok: true,
    job: {
      source: raw.source,
      externalId: String(raw.externalId),
      title,
      companyName,
      companyLogoUrl: raw.logoUrl || null,
      location: normalizeLocation(raw),
      workMode,
      level,
      ...salary,
      description: description || title,
      requiredSkills,
      niceToHave,
      applyUrl: link.url,
      applyRank: link.rank,
      applyIsDirect: link.isDirect,
      postedAt: getPostedDate(raw, now),
      keyword: raw.keyword || null,
    },
  };
}

module.exports = { cleanJob };
