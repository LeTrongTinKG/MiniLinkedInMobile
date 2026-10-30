const applicationRepository = require("../repositories/application.repository");
const jobRepository = require("../repositories/job.repository");
const cvRepository = require("../repositories/cv.repository");
const skillRepository = require("../repositories/skill.repository");
const aiClient = require("./ai/aiClient");
const { ApiError } = require("../middleware/error");
const { parsePagination } = require("../utils/job.util");
const {
  VALID_APPLICATION_STATUSES,
  ALLOWED_DECISION_STATUSES,
  WITHDRAWABLE_STATUSES,
  extractCvSkills,
  mergeMatchSkills,
  findJobOrThrow,
  resolveTargetCv,
} = require("../utils/application.util");

/**
 * Sinh viên nộp đơn ứng tuyển vào công việc
 */
async function applyJob(user, { jobId, cvId }) {
  if (!user || user.role !== "student" || !user.userId) {
    throw new ApiError(403, "FORBIDDEN", "Chỉ sinh viên mới có quyền ứng tuyển");
  }
  if (!jobId || typeof jobId !== "string" || jobId.trim().length === 0) {
    throw new ApiError(400, "INVALID_INPUT", "jobId là bắt buộc");
  }

  const cleanJobId = jobId.trim();
  const job = await findJobOrThrow(cleanJobId, jobRepository);
  if (job.status !== "open") {
    throw new ApiError(400, "JOB_CLOSED", "Công việc này đã đóng đơn ứng tuyển");
  }

  // Job kéo từ nguồn ngoài: không nhận đơn trong app, trả link ứng tuyển gốc
  if (job.source && job.source !== "internal") {
    throw new ApiError(409, "EXTERNAL_JOB_APPLY", "Job này đăng ở nguồn bên ngoài, vui lòng ứng tuyển trực tiếp qua link gốc", { applyUrl: job.applyUrl ?? null });
  }

  const existing = await applicationRepository.findByJobAndStudent(cleanJobId, user.userId);
  if (existing) {
    throw new ApiError(409, "ALREADY_APPLIED", "Bạn đã ứng tuyển vào công việc này rồi");
  }

  const targetCv = await resolveTargetCv(user.userId, cvId, cvRepository);
  const cvSkills = mergeMatchSkills(
    extractCvSkills(targetCv),
    await skillRepository.listApprovedNames(user.userId),
  );
  let matchResult = { score: 0, matchedSkills: [], missingSkills: [] };
  try {
    matchResult = await aiClient.match(cvSkills, {
      requiredSkills: job.requiredSkills || [],
      niceToHave: job.niceToHave || [],
    });
  } catch (aiErr) {
    console.warn("[applicationService] Lỗi tính AI match (fallback 0):", aiErr.message);
  }

  try {
    return await applicationRepository.createApplication({
      jobId: job.id,
      studentId: user.userId,
      cvId: targetCv.id,
      matchScore: typeof matchResult?.score === "number" ? matchResult.score : 0,
      matchedSkills: Array.isArray(matchResult?.matchedSkills) ? matchResult.matchedSkills : [],
      missingSkills: Array.isArray(matchResult?.missingSkills) ? matchResult.missingSkills : [],
      status: "submitted",
    });
  } catch (createErr) {
    if (createErr?.code === "P2002") {
      throw new ApiError(409, "ALREADY_APPLIED", "Bạn đã ứng tuyển vào công việc này rồi");
    }
    throw createErr;
  }
}

/**
 * Lấy danh sách ứng viên của một tin tuyển dụng (sắp xếp matchScore giảm dần)
 */
async function getJobApplications(user, jobId, query = {}) {
  if (!user || user.role !== "recruiter" || !user.userId) {
    throw new ApiError(403, "FORBIDDEN", "Chỉ nhà tuyển dụng mới có quyền xem danh sách ứng viên");
  }
  if (!jobId || typeof jobId !== "string" || jobId.trim().length === 0) {
    throw new ApiError(400, "INVALID_INPUT", "jobId là bắt buộc");
  }

  const cleanJobId = jobId.trim();
  const job = await findJobOrThrow(cleanJobId, jobRepository);
  if (job.recruiterId !== user.userId) {
    throw new ApiError(403, "FORBIDDEN", "Bạn không có quyền xem danh sách ứng viên của công việc này");
  }

  const { page, limit, skip } = parsePagination(query, 10, 50);
  const status = VALID_APPLICATION_STATUSES.includes(query.status) ? query.status : undefined;

  const [items, total] = await Promise.all([
    applicationRepository.findApplicationsByJobId({ jobId: cleanJobId, status, skip, limit }),
    applicationRepository.countApplicationsByJobId({ jobId: cleanJobId, status }),
  ]);

  return { items, pagination: { page, limit, total } };
}

/**
 * Sinh viên xem lại các đơn đã nộp của mình
 */
async function getMyApplications(user, query = {}) {
  if (!user || user.role !== "student" || !user.userId) {
    throw new ApiError(403, "FORBIDDEN", "Chỉ sinh viên mới có quyền xem đơn đã nộp");
  }

  const { page, limit, skip } = parsePagination(query, 10, 50);
  const status = VALID_APPLICATION_STATUSES.includes(query.status) ? query.status : undefined;

  const [items, total] = await Promise.all([
    applicationRepository.findApplicationsByStudentId({ studentId: user.userId, status, skip, limit }),
    applicationRepository.countApplicationsByStudentId({ studentId: user.userId, status }),
  ]);

  return { items, pagination: { page, limit, total } };
}

/**
 * Nhà tuyển dụng duyệt hoặc từ chối đơn ứng tuyển
 */
async function updateApplicationStatus(user, applicationId, newStatus) {
  if (!user || user.role !== "recruiter" || !user.userId) {
    throw new ApiError(403, "FORBIDDEN", "Chỉ nhà tuyển dụng mới có quyền cập nhật trạng thái đơn");
  }
  if (!applicationId || typeof applicationId !== "string" || applicationId.trim().length === 0) {
    throw new ApiError(400, "INVALID_INPUT", "ID đơn ứng tuyển không hợp lệ");
  }
  if (!ALLOWED_DECISION_STATUSES.includes(newStatus)) {
    throw new ApiError(400, "INVALID_STATUS", `Trạng thái không hợp lệ: ${ALLOWED_DECISION_STATUSES.join(", ")}`);
  }

  const app = await applicationRepository.findById(applicationId.trim());
  if (!app) throw new ApiError(404, "APPLICATION_NOT_FOUND", "Không tìm thấy đơn ứng tuyển");
  if (app.job.recruiterId !== user.userId) {
    throw new ApiError(403, "FORBIDDEN", "Bạn không có quyền cập nhật đơn ứng tuyển của công việc này");
  }

  return applicationRepository.updateStatus(app.id, newStatus);
}

/**
 * Sinh viên chủ động rút đơn ứng tuyển
 */
async function withdrawApplication(user, applicationId) {
  if (!user || user.role !== "student" || !user.userId) {
    throw new ApiError(403, "FORBIDDEN", "Chỉ sinh viên mới có quyền rút đơn ứng tuyển");
  }
  if (!applicationId || typeof applicationId !== "string" || applicationId.trim().length === 0) {
    throw new ApiError(400, "INVALID_INPUT", "ID đơn ứng tuyển không hợp lệ");
  }

  const app = await applicationRepository.findById(applicationId.trim());
  if (!app) throw new ApiError(404, "APPLICATION_NOT_FOUND", "Không tìm thấy đơn ứng tuyển");
  if (app.studentId !== user.userId) {
    throw new ApiError(403, "FORBIDDEN", "Bạn không có quyền rút đơn ứng tuyển này");
  }
  if (app.status === "withdrawn") {
    throw new ApiError(400, "ALREADY_WITHDRAWN", "Đơn ứng tuyển này đã được rút trước đó");
  }
  if (!WITHDRAWABLE_STATUSES.includes(app.status)) {
    throw new ApiError(400, "CANNOT_WITHDRAW", "Không thể rút đơn ứng tuyển đã có kết quả duyệt");
  }

  return applicationRepository.updateStatus(app.id, "withdrawn");
}

/**
 * Nhà tuyển dụng xem chi tiết ứng viên (tự động chuyển submitted -> viewed)
 */
async function getRecruiterApplicationDetail(user, applicationId) {
  if (!user || user.role !== "recruiter" || !user.userId) {
    throw new ApiError(403, "FORBIDDEN", "Chỉ nhà tuyển dụng mới có quyền xem chi tiết ứng viên");
  }
  if (!applicationId || typeof applicationId !== "string" || applicationId.trim().length === 0) {
    throw new ApiError(400, "INVALID_INPUT", "ID đơn ứng tuyển không hợp lệ");
  }

  const app = await applicationRepository.findDetailById(applicationId.trim());
  if (!app) throw new ApiError(404, "APPLICATION_NOT_FOUND", "Không tìm thấy đơn ứng tuyển");
  if (app.job?.recruiterId !== user.userId) {
    throw new ApiError(403, "FORBIDDEN", "Bạn không có quyền xem chi tiết đơn ứng tuyển của công việc này");
  }

  // Tự động chuyển submitted -> viewed khi mở xem lần đầu
  if (app.status === "submitted") {
    const updated = await applicationRepository.updateStatus(app.id, "viewed");
    app.status = updated.status;
  }

  return app;
}

module.exports = {
  applyJob,
  getJobApplications,
  getMyApplications,
  updateApplicationStatus,
  withdrawApplication,
  getRecruiterApplicationDetail,
};
