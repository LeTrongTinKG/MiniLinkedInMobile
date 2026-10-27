const recruiterApplicationRepository = require("../repositories/recruiter-application.repository");
const { ApiError } = require("../middleware/error");
const { parsePagination } = require("../utils/job.util");
const { VALID_APPLICATION_STATUSES } = require("../utils/application.util");

/**
 * Nhà tuyển dụng xem đơn ứng tuyển vào tất cả job của mình (không cần chọn job)
 */
async function getAllApplications(user, query = {}) {
  if (!user || user.role !== "recruiter" || !user.userId) {
    throw new ApiError(403, "FORBIDDEN", "Chỉ nhà tuyển dụng mới có quyền xem danh sách ứng viên");
  }

  const { page, limit, skip } = parsePagination(query, 10, 50);
  const status = VALID_APPLICATION_STATUSES.includes(query.status) ? query.status : undefined;
  const params = { recruiterId: user.userId, status };

  const [items, total] = await Promise.all([
    recruiterApplicationRepository.findApplicationsByRecruiterId({ ...params, skip, limit }),
    recruiterApplicationRepository.countApplicationsByRecruiterId(params),
  ]);

  return { items, pagination: { page, limit, total } };
}

module.exports = { getAllApplications };
