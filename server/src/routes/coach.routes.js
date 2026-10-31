const express = require("express");
const coachController = require("../controllers/coach.controller");
const { authenticate, authorize } = require("../middleware/auth");

const router = express.Router();

router.use(authenticate, authorize("student"));

/**
 * GET  /api/v1/coach/settings  - Đồng ý, vị trí mục tiêu, danh sách lộ trình, số câu còn lại hôm nay
 * PUT  /api/v1/coach/settings  - { consent?: boolean, targetRole?: string | null }
 * POST /api/v1/coach/ask       - { question } hoặc { intent, skill? }, thêm jobId nếu đang xem job
 */
router.get("/settings", coachController.getSettings);
router.put("/settings", coachController.updateSettings);
router.post("/ask", coachController.ask);

module.exports = router;
