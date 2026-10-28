/**
 * Các tiện ích và hằng số hỗ trợ xử lý dữ liệu Job
 * Tách từ job.service.js để đảm bảo quy tắc file <= 200 dòng theo CLAUDE.md
 */

const VALID_WORK_MODES = ["onsite", "hybrid", "remote"];
const VALID_JOB_LEVELS = ["intern", "fresher", "junior", "mid", "senior", "lead"];
const VALID_JOB_STATUSES = ["open", "closed"];

/**
 * Chuẩn hóa danh sách kỹ năng từ query string
 * Hỗ trợ chuỗi phẩy "React,Node.js" hoặc mảng query ["React", "Node.js"]
 * Tất cả kỹ năng được lowercase để so sánh không phân biệt hoa/thường
 */
function parseSkills(skillsQuery) {
  if (!skillsQuery) return [];

  if (Array.isArray(skillsQuery)) {
    return skillsQuery
      .flatMap((item) => (typeof item === "string" ? item.split(",") : []))
      .map((s) => s.trim().toLowerCase())
      .filter((s) => s.length > 0);
  }

  if (typeof skillsQuery === "string") {
    return skillsQuery
      .split(",")
      .map((s) => s.trim().toLowerCase())
      .filter((s) => s.length > 0);
  }

  return [];
}

/**
 * Xử lý phân trang an toàn
 */
function parsePagination(query, defaultLimit = 10, maxLimit = 50) {
  let page = parseInt(query.page, 10);
  if (isNaN(page) || page < 1) {
    page = 1;
  }

  let limit = parseInt(query.limit, 10);
  if (isNaN(limit) || limit < 1) {
    limit = defaultLimit;
  } else if (limit > maxLimit) {
    limit = maxLimit;
  }

  const skip = (page - 1) * limit;

  return { page, limit, skip };
}

/**
 * Format dữ liệu job trước khi trả về client
 * Chỉ giữ 1 field duy nhất applicationsCount (không trùng lặp)
 */
function formatJob(job) {
  // dedupeKey/lastSeenAt/externalId chỉ dùng nội bộ cho Job Sync, không trả ra client
  const { _count, dedupeKey, lastSeenAt, externalId, ...rest } = job;
  return {
    ...rest,
    // Job nguồn ngoài: không có recruiter, có link ứng tuyển gốc
    recruiter: job.recruiter ?? null,
    source: job.source ?? "internal",
    applyUrl: job.applyUrl ?? null,
    salaryCurrency: job.salaryCurrency ?? null,
    applicationsCount: _count?.applications ?? 0,
  };
}

module.exports = {
  VALID_WORK_MODES,
  VALID_JOB_LEVELS,
  VALID_JOB_STATUSES,
  parseSkills,
  parsePagination,
  formatJob,
};
