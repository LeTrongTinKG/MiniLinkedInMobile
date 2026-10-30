const express = require("express");
const skillController = require("../controllers/skill.controller");
const { authenticate, authorize } = require("../middleware/auth");

const router = express.Router();

router.use(authenticate, authorize("student"));

/**
 * GET  /api/v1/skills                          - Skill đã có trong hồ sơ (kèm nguồn, bằng chứng)
 * GET  /api/v1/skills/suggestions              - Đề xuất đang chờ duyệt
 * POST /api/v1/skills/suggestions/github       - Quét repo GitHub của chính mình để tạo đề xuất
 * POST /api/v1/skills/suggestions/:id/accept   - Đồng ý: thêm skill vào hồ sơ kèm bằng chứng
 * POST /api/v1/skills/suggestions/:id/reject   - Từ chối
 */
router.get("/", skillController.getMySkills);
router.get("/suggestions", skillController.getSuggestions);
router.post("/suggestions/github", skillController.scanGithub);
router.post("/suggestions/:id/accept", skillController.acceptSuggestion);
router.post("/suggestions/:id/reject", skillController.rejectSuggestion);

module.exports = router;
