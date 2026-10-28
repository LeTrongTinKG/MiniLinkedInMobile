// Bước 4: suy luận cấp độ (intern / fresher / junior / mid / senior / lead). Không loại job theo cấp độ.

const INTERN_RE = /\b(intern|internship|interns)\b|thực tập/i;
const FRESHER_RE = /\bfresher|mới tốt nghiệp|\bgraduate|entry[\s-]?level/i;
const JUNIOR_RE = /\bjunior\b|\bjr\b\.?/i;
const SENIOR_RE = /\b(senior|sr)\b/i;
const LEAD_RE = /\b(lead|manager|principal|architect|head|director|staff)\b|trưởng/i;
const MID_RE = /\b(mid|middle|mid[\s-]?level)\b/i;
const NO_EXPERIENCE_RE = /không yêu cầu kinh nghiệm|chưa có kinh nghiệm|no experience|không cần kinh nghiệm/i;

// Tìm số năm kinh nghiệm: "3+ years", "từ 3 năm", "Yêu cầu kinh nghiệm: 1 năm"...
function findYearsOfExperience(description) {
  const text = String(description || "");
  const patterns = [
    /(\d+)\s*\+?\s*(?:-|–|to|đến)?\s*\d*\s*(?:years?|yrs?|năm)[^.\n]{0,25}(?:experience|kinh nghiệm)/i,
    /(?:experience|kinh nghiệm)[^.\n]{0,25}?(\d+)\s*\+?\s*(?:years?|yrs?|năm)/i,
    /(?:kinh nghiệm|experience)\s*[:\-]\s*(\d+)\b/i,
  ];
  for (const pattern of patterns) {
    const m = pattern.exec(text);
    if (m) return Number(m[1]);
  }
  return null;
}

// Trả về 1 trong: intern | fresher | junior | mid | senior | lead (không loại job nào)
function inferLevel(title, description) {
  const t = String(title || "");
  const d = String(description || "");

  // 1. Tiêu đề trước (cấp càng cao càng ưu tiên: lead > senior > mid)
  if (INTERN_RE.test(t)) return "intern";
  if (FRESHER_RE.test(t)) return "fresher";
  if (JUNIOR_RE.test(t)) return "junior";
  if (LEAD_RE.test(t)) return "lead";
  if (SENIOR_RE.test(t)) return "senior";
  if (MID_RE.test(t)) return "mid";

  // 2. Tiêu đề không rõ: xem từ khóa trong mô tả
  if (INTERN_RE.test(d)) return "intern";
  if (FRESHER_RE.test(d)) return "fresher";
  if (JUNIOR_RE.test(d)) return "junior";

  // 3. Rồi tới số năm kinh nghiệm
  if (NO_EXPERIENCE_RE.test(d)) return "fresher";
  const years = findYearsOfExperience(d);
  if (years !== null) {
    if (years === 0) return "fresher";
    if (years <= 2) return "junior";
    if (years <= 4) return "mid";
    return "senior";
  }

  // 4. Không biết thì mặc định junior
  return "junior";
}

module.exports = { inferLevel, findYearsOfExperience };
