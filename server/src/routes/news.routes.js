const express = require("express");
const newsController = require("../controllers/news.controller");

const router = express.Router();

/**
 * GET /api/v1/news - Danh sách tin tức công nghệ & AI công khai (không cần token)
 */
router.get("/", newsController.getNews);

module.exports = router;
