const express = require("express");
const jobController = require("../controllers/job.controller");

const router = express.Router();

/**
 * Route công khai cho tin tuyển dụng
 * GET /api/v1/jobs - Tìm kiếm và lọc danh sách job đang mở
 * GET /api/v1/jobs/:id - Xem chi tiết job
 */
router.get("/", jobController.getPublicJobs);
router.get("/:id", jobController.getJobDetail);

module.exports = router;
