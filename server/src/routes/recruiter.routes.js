const express = require("express");
const jobController = require("../controllers/job.controller");
const applicationController = require("../controllers/application.controller");
const { authenticate, authorize } = require("../middleware/auth");

const router = express.Router();

// Tất cả route recruiter đều yêu cầu xác thực và phân quyền recruiter
router.use(authenticate, authorize("recruiter"));

/**
 * GET /api/v1/recruiter/jobs - Danh sách job của nhà tuyển dụng kèm số ứng viên
 */
router.get("/jobs", jobController.getRecruiterJobs);

/**
 * GET /api/v1/recruiter/jobs/:jobId/applications - Danh sách ứng viên của một Job (xếp theo matchScore giảm dần)
 * GET /api/v1/recruiter/applications?jobId=... - Hỗ trợ alias qua query param
 */
router.get("/jobs/:jobId/applications", applicationController.getJobApplications);
router.get("/applications", applicationController.getJobApplications);

/**
 * PATCH /api/v1/recruiter/applications/:id/status - Duyệt hoặc từ chối đơn ứng tuyển
 */
router.patch("/applications/:id/status", applicationController.updateApplicationStatus);

module.exports = router;
