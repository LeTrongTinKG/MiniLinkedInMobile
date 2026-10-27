const express = require("express");
const applicationController = require("../controllers/application.controller");
const { authenticate, authorize } = require("../middleware/auth");

const router = express.Router();

// Tất cả các route applications sinh viên đều yêu cầu xác thực role student
router.use(authenticate, authorize("student"));

/**
 * POST /api/v1/applications - Sinh viên nộp đơn ứng tuyển
 */
router.post("/", applicationController.applyJob);

/**
 * GET /api/v1/applications/my - Sinh viên xem lại các đơn đã nộp
 */
router.get("/my", applicationController.getMyApplications);

/**
 * PATCH /api/v1/applications/:id/withdraw - Sinh viên chủ động rút đơn
 */
router.patch("/:id/withdraw", applicationController.withdrawApplication);

module.exports = router;
