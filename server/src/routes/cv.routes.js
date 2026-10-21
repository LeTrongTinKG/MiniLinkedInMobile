const express = require("express");
const cvController = require("../controllers/cv.controller");
const { authenticate, authorize } = require("../middleware/auth");
const { uploadCvMiddleware } = require("../middleware/upload");

const router = express.Router();

// Tất cả route quản lý CV đều dành riêng cho Sinh viên (Student)
router.use(authenticate, authorize("student"));

/**
 * POST /api/v1/cvs - Upload file PDF CV (tối đa 5MB)
 * GET /api/v1/cvs - Danh sách CV của sinh viên đang đăng nhập
 * PATCH /api/v1/cvs/:id/default - Đặt CV làm mặc định
 * DELETE /api/v1/cvs/:id - Xóa CV
 */
router.post("/", uploadCvMiddleware, cvController.uploadCv);
router.get("/", cvController.getMyCvs);
router.patch("/:id/default", cvController.setDefaultCv);
router.delete("/:id", cvController.deleteCv);

module.exports = router;
