const jobRepository = require("../repositories/job.repository");
const cvRepository = require("../repositories/cv.repository");
const aiClient = require("./ai/aiClient");
const { ApiError } = require("../middleware/error");
const {
  VALID_WORK_MODES,
  VALID_JOB_LEVELS,
  VALID_JOB_STATUSES,
  parseSkills,
  parsePagination,
  formatJob,
} = require("../utils/job.util");

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

  return {
    items: items.map(formatJob),
    meta: {
      page,
      limit,
      total: totalItems,
      totalPages,
      hasNextPage: page < totalPages,
      hasPrevPage: page > 1,
    },
  };
}

/**
 * Lấy chi tiết việc làm theo ID, kèm chấm điểm mức độ phù hợp (AI match) cho sinh viên
 */
async function getJobDetail(
  id,
  context = {},
  repo = jobRepository,
  cvRepo = cvRepository,
  ai = aiClient
) {
  if (typeof id !== "string" || id.trim().length === 0) {
    throw new ApiError(404, "JOB_NOT_FOUND", "Không tìm thấy job");
  }

  let job;
  try {
    job = await repo.findJobById(id.trim());
  } catch (error) {
    if (error?.code === "P2023") {
      throw new ApiError(404, "JOB_NOT_FOUND", "Không tìm thấy job");
    }
    throw error;
  }

  if (!job) {
    throw new ApiError(404, "JOB_NOT_FOUND", "Không tìm thấy job");
  }

  const formattedJob = formatJob(job);

  // Tính toán AI Match nếu người dùng là sinh viên
  const user = context?.user;
  if (user && user.role === "student" && user.userId) {
    let matchResult = null;
    try {
      let targetCv = null;
      if (typeof context.cvId === "string" && context.cvId.trim().length > 0) {
        targetCv = await cvRepo.findById(context.cvId.trim());
        if (targetCv && targetCv.userId !== user.userId) {
          targetCv = null;
        }
      }

      if (!targetCv) {
        targetCv = await cvRepo.findDefaultByUserId(user.userId);
      }

      if (targetCv && targetCv.extractedSkills) {
        let cvSkills = [];
        if (Array.isArray(targetCv.extractedSkills.skills)) {
          cvSkills = targetCv.extractedSkills.skills;
        } else if (Array.isArray(targetCv.extractedSkills)) {
          cvSkills = targetCv.extractedSkills;
        }

        if (cvSkills.length > 0) {
          try {
            matchResult = await ai.match(cvSkills, formattedJob);
          } catch (aiErr) {
            console.warn("AI service match error (fallback null):", aiErr.message);
            matchResult = null;
          }
        }
      }
    } catch (matchErr) {
      console.warn("Lỗi tính toán AI match (fallback an toàn sang null):", matchErr.message);
      matchResult = null;
    }

    // Chỉ gán thuộc tính match cho sinh viên (recruiter và khách vãng lai không có field này)
    formattedJob.match = matchResult;
  }

  return formattedJob;
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

  return {
    items: items.map(formatJob),
    meta: {
      page,
      limit,
      total: totalItems,
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
};
