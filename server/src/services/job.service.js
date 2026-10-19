const jobRepository = require("../repositories/job.repository");
const { ApiError } = require("../middleware/error");

const VALID_WORK_MODES = ["onsite", "hybrid", "remote"];
const VALID_JOB_LEVELS = ["intern", "fresher", "junior"];
const VALID_JOB_STATUSES = ["open", "closed"];

/**
 * Chuẩn hóa danh sách kỹ năng từ query string
 * Hỗ trợ chuỗi phẩy "React,Node.js" hoặc mảng query ["React", "Node.js"]
 */
function parseSkills(skillsQuery) {
  if (!skillsQuery) return [];

  if (Array.isArray(skillsQuery)) {
    return skillsQuery
      .flatMap((item) => (typeof item === "string" ? item.split(",") : []))
      .map((s) => s.trim())
      .filter((s) => s.length > 0);
  }

  if (typeof skillsQuery === "string") {
    return skillsQuery
      .split(",")
      .map((s) => s.trim())
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
 * Lấy danh sách việc làm công khai (chỉ việc làm đang mở / status = open)
 */
async function getPublicJobs(query = {}, repo = jobRepository) {
  const { page, limit, skip } = parsePagination(query, 10, 50);

  const filters = {};

  if (typeof query.q === "string" && query.q.trim().length > 0) {
    filters.q = query.q.trim();
  }

  const skills = parseSkills(query.skills);
  if (skills.length > 0) {
    filters.skills = skills;
  }

  if (typeof query.level === "string") {
    const levelLower = query.level.trim().toLowerCase();
    if (VALID_JOB_LEVELS.includes(levelLower)) {
      filters.level = levelLower;
    }
  }

  if (typeof query.workMode === "string") {
    const workModeLower = query.workMode.trim().toLowerCase();
    if (VALID_WORK_MODES.includes(workModeLower)) {
      filters.workMode = workModeLower;
    }
  }

  if (typeof query.location === "string" && query.location.trim().length > 0) {
    filters.location = query.location.trim();
  }

  const where = repo.buildPublicJobWhere(filters);
  const { items, totalItems } = await repo.findPublicJobs({
    where,
    skip,
    take: limit,
  });

  const totalPages = Math.ceil(totalItems / limit) || 1;

  // Chuẩn hóa format trả về kèm applicationsCount
  const formattedItems = items.map((job) => ({
    ...job,
    applicationsCount: job._count?.applications ?? 0,
    _count: undefined,
  }));

  return {
    items: formattedItems,
    meta: {
      page,
      limit,
      totalItems,
      totalPages,
      hasNextPage: page < totalPages,
      hasPrevPage: page > 1,
    },
  };
}

/**
 * Lấy chi tiết việc làm theo ID
 */
async function getJobDetail(id, repo = jobRepository) {
  if (typeof id !== "string" || id.trim().length === 0) {
    throw new ApiError(400, "INVALID_JOB_ID", "ID công việc không hợp lệ");
  }

  const job = await repo.findJobById(id.trim());
  if (!job) {
    throw new ApiError(404, "JOB_NOT_FOUND", "Không tìm thấy thông tin công việc");
  }

  return {
    ...job,
    applicationsCount: job._count?.applications ?? 0,
    _count: undefined,
  };
}

/**
 * Lấy danh sách việc làm do nhà tuyển dụng đăng
 */
async function getRecruiterJobs(recruiterId, query = {}, repo = jobRepository) {
  if (typeof recruiterId !== "string" || recruiterId.trim().length === 0) {
    throw new ApiError(401, "UNAUTHORIZED", "Không xác định được danh tính nhà tuyển dụng");
  }

  const { page, limit, skip } = parsePagination(query, 10, 50);

  let statusFilter = undefined;
  if (typeof query.status === "string") {
    const statusLower = query.status.trim().toLowerCase();
    if (VALID_JOB_STATUSES.includes(statusLower)) {
      statusFilter = statusLower;
    }
  }

  const { items, totalItems } = await repo.findRecruiterJobs({
    recruiterId: recruiterId.trim(),
    status: statusFilter,
    skip,
    take: limit,
  });

  const totalPages = Math.ceil(totalItems / limit) || 1;

  const formattedItems = items.map((job) => ({
    ...job,
    applicationsCount: job._count?.applications ?? 0,
    _count: undefined,
  }));

  return {
    items: formattedItems,
    meta: {
      page,
      limit,
      totalItems,
      totalPages,
      hasNextPage: page < totalPages,
      hasPrevPage: page > 1,
    },
  };
}

module.exports = {
  getPublicJobs,
  getJobDetail,
  getRecruiterJobs,
  parseSkills,
  parsePagination,
  VALID_WORK_MODES,
  VALID_JOB_LEVELS,
  VALID_JOB_STATUSES,
};
