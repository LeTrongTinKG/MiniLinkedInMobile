const applicationRepository = require("../repositories/application.repository");
const jobRepository = require("../repositories/job.repository");
const cvRepository = require("../repositories/cv.repository");
const aiClient = require("./ai/aiClient");
const { ApiError } = require("../middleware/error");
const { parsePagination } = require("../utils/job.util");
const {
  VALID_APPLICATION_STATUSES,
  ALLOWED_DECISION_STATUSES,
  extractCvSkills,
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

  // 1. Kiểm tra Job tồn tại và đang mở tuyển
  let job;
  try {
    job = await jobRepository.findJobById(cleanJobId);
  } catch (err) {
    if (err?.code === "P2023") throw new ApiError(404, "JOB_NOT_FOUND", "Không tìm thấy công việc");
    throw err;
  }

  if (!job) throw new ApiError(404, "JOB_NOT_FOUND", "Không tìm thấy công việc");
  if (job.status !== "open") {
    throw new ApiError(400, "JOB_CLOSED", "Công việc này đã đóng đơn ứng tuyển");
  }

  // 2. Chống nộp trùng lặp (Tiêu chuẩn nghiệm thu 1: Ứng tuyển 2 lần trả 409)
  const existing = await applicationRepository.findByJobAndStudent(cleanJobId, user.userId);
  if (existing) {
    throw new ApiError(409, "ALREADY_APPLIED", "Bạn đã ứng tuyển vào công việc này rồi");
  }

  // 3. Xác thực quyền sở hữu CV hoặc tự động fallback CV mặc định
  const targetCv = await resolveTargetCv(user.userId, cvId, cvRepository);

  // 4. Trích xuất kỹ năng CV và tính điểm AI match
  const cvSkills = extractCvSkills(targetCv);
  let matchResult = { score: 0, matchedSkills: [], missingSkills: [] };
  try {
    matchResult = await aiClient.match(cvSkills, {
      requiredSkills: job.requiredSkills || [],
      niceToHave: job.niceToHave || [],
    });
  } catch (aiErr) {
    console.warn("[applicationService] Lỗi tính AI match (fallback 0):", aiErr.message);
  }

  // 5. Lưu đơn ứng tuyển vào DB (bắt lỗi P2002 đề phòng race conditions)
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
  let job;
  try {
    job = await jobRepository.findJobById(cleanJobId);
  } catch (err) {
    if (err?.code === "P2023") throw new ApiError(404, "JOB_NOT_FOUND", "Không tìm thấy công việc");
    throw err;
  }

  if (!job) throw new ApiError(404, "JOB_NOT_FOUND", "Không tìm thấy công việc");

  // Tiêu chuẩn nghiệm thu 3: Không phải chủ job trả 403
  if (job.recruiterId !== user.userId) {
    throw new ApiError(403, "FORBIDDEN", "Bạn không có quyền xem danh sách ứng viên của công việc này");
  }

  const { page, limit, skip } = parsePagination(query, 10, 50);
  const status = VALID_APPLICATION_STATUSES.includes(query.status) ? query.status : undefined;

  // Tiêu chuẩn nghiệm thu 2: Ứng viên giảm dần theo matchScore (trong repository)
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
    applicationRepository.findApplicationsByStudentId({
      studentId: user.userId,
      status,
      skip,
      limit,
    }),
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
    throw new ApiError(
      400,
      "INVALID_STATUS",
      `Trạng thái không hợp lệ. Chỉ chấp nhận: ${ALLOWED_DECISION_STATUSES.join(", ")}`
    );
  }

  const application = await applicationRepository.findById(applicationId.trim());
  if (!application) {
    throw new ApiError(404, "APPLICATION_NOT_FOUND", "Không tìm thấy đơn ứng tuyển");
  }

  // Quyền sở hữu: Chỉ chủ Job mới có quyền duyệt đơn
  if (application.job.recruiterId !== user.userId) {
    throw new ApiError(403, "FORBIDDEN", "Bạn không có quyền cập nhật đơn ứng tuyển của công việc này");
  }

  return applicationRepository.updateStatus(application.id, newStatus);
}

module.exports = {
  applyJob,
  getJobApplications,
  getMyApplications,
  updateApplicationStatus,
};
