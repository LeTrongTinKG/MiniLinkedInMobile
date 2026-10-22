const jobRepository = require("../repositories/job.repository");
const cvRepository = require("../repositories/cv.repository");
const aiClient = require("./ai/aiClient");
const mockAiAdapter = require("./ai/mockAdapter");
const { ApiError } = require("../middleware/error");

const VALID_WORK_MODES = ["onsite", "hybrid", "remote"];
const VALID_JOB_LEVELS = ["intern", "fresher", "junior"];
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
  const { _count, ...rest } = job;
  return {
    ...rest,
    applicationsCount: _count?.applications ?? 0,
  };
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

  // Không nuốt lỗi DB — chỉ catch PrismaClientKnownRequestError mã P2023 (sai định dạng ID)
  let job;
  try {
    job = await repo.findJobById(id.trim());
  } catch (error) {
    if (error?.code === "P2023") {
      throw new ApiError(404, "JOB_NOT_FOUND", "Không tìm thấy job");
    }
    // Lỗi hệ thống khác (mất kết nối DB, timeout, ...) -> để nổi lên cho errorHandler trả về 500
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
      // 1. Nếu có chỉ định cvId trên query -> tìm theo ID đó
      if (typeof context.cvId === "string" && context.cvId.trim().length > 0) {
        targetCv = await cvRepo.findById(context.cvId.trim());
        // Chỉ chấp nhận CV thuộc về chính sinh viên đang đăng nhập
        if (targetCv && targetCv.userId !== user.userId) {
          targetCv = null;
        }
      }

      // 2. Nếu không có hoặc không tìm thấy, tối ưu lấy CV mặc định (không load toàn bộ list)
      if (!targetCv) {
        targetCv = await cvRepo.findDefaultByUserId(user.userId);
      }

      // 3. Gọi AI match giữa kỹ năng của CV và yêu cầu công việc
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
            console.warn("AI service match error (fallback to mock):", aiErr.message);
            matchResult = await mockAiAdapter.match(cvSkills, formattedJob);
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
  parseSkills,
  parsePagination,
  VALID_WORK_MODES,
  VALID_JOB_LEVELS,
  VALID_JOB_STATUSES,
};
