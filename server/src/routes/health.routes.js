const express = require("express");
const aiClient = require("../services/ai/aiClient");
const { asyncHandler } = require("../middleware/error");
const { sendSuccess } = require("../controllers/response");

const router = express.Router();

/**
 * GET /api/v1/health/ai - Kiểm tra tình trạng kết nối AI service
 */
router.get(
  "/ai",
  asyncHandler(async (_req, res) => {
    const health = await aiClient.checkHealth();
    return sendSuccess(res, health, 200);
  })
);

module.exports = router;
