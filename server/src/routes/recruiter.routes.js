const express = require("express");
const jobController = require("../controllers/job.controller");
const { authenticate, authorize } = require("../middleware/auth");

const router = express.Router();

// Tất cả route recruiter đều yêu cầu xác thực và phân quyền recruiter
router.use(authenticate, authorize("recruiter"));

/**
 * GET /api/v1/recruiter/jobs - Danh sách job của nhà tuyển dụng kèm số ứng viên
 */
router.get("/jobs", jobController.getRecruiterJobs);

module.exports = router;

