const express = require("express");
const jobController = require("../controllers/job.controller");
const { optionalAuthenticate } = require("../middleware/auth");

const router = express.Router();

/**
 * Route công khai cho tin tuyển dụng
 * GET /api/v1/jobs - Tìm kiếm và lọc danh sách job đang mở
 * GET /api/v1/jobs/:id - Xem chi tiết job (kèm AI match nếu đã đăng nhập và có CV)
 */
router.get("/", jobController.getPublicJobs);
router.get("/:id", optionalAuthenticate, jobController.getJobDetail);

module.exports = router;
