const applicationService = require("../services/application.service");
const { asyncHandler } = require("../middleware/error");
const { sendSuccess } = require("./response");

/**
 * POST /api/v1/applications - Sinh viên nộp đơn ứng tuyển
 */
const applyJob = asyncHandler(async (req, res) => {
  const application = await applicationService.applyJob(req.user, req.body || {});
  return sendSuccess(res, application, 201);
});

/**
 * GET /api/v1/recruiter/jobs/:jobId/applications hoặc /api/v1/recruiter/applications
 * Lấy danh sách ứng viên của một tin tuyển dụng (sắp xếp matchScore giảm dần)
 */
const getJobApplications = asyncHandler(async (req, res) => {
  const jobId = req.params?.jobId || req.query?.jobId;
  const { items, pagination } = await applicationService.getJobApplications(
    req.user,
    jobId,
    req.query || {}
  );
  return sendSuccess(res, items, 200, pagination);
});

/**
 * GET /api/v1/applications/my - Sinh viên xem danh sách các đơn đã nộp
 */
const getMyApplications = asyncHandler(async (req, res) => {
  const { items, pagination } = await applicationService.getMyApplications(
    req.user,
    req.query || {}
  );
  return sendSuccess(res, items, 200, pagination);
});

/**
 * PATCH /api/v1/recruiter/applications/:id/status - Duyệt/từ chối đơn ứng tuyển
 */
const updateApplicationStatus = asyncHandler(async (req, res) => {
  const updated = await applicationService.updateApplicationStatus(
    req.user,
    req.params?.id,
    req.body?.status
  );
  return sendSuccess(res, updated, 200);
});

/**
 * PATCH /api/v1/applications/:id/withdraw - Sinh viên chủ động rút đơn
 */
const withdrawApplication = asyncHandler(async (req, res) => {
  const updated = await applicationService.withdrawApplication(req.user, req.params?.id);
  return sendSuccess(res, updated, 200);
});

/**
 * GET /api/v1/recruiter/applications/:id - Xem chi tiết ứng viên (tự đổi submitted -> viewed)
 */
const getRecruiterApplicationDetail = asyncHandler(async (req, res) => {
  const detail = await applicationService.getRecruiterApplicationDetail(req.user, req.params?.id);
  return sendSuccess(res, detail, 200);
});

module.exports = {
  applyJob,
  getJobApplications,
  getMyApplications,
  updateApplicationStatus,
  withdrawApplication,
  getRecruiterApplicationDetail,
};
