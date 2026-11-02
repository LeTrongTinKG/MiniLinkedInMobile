const newsService = require("../services/news.service");
const { sendSuccess } = require("./response");
const { asyncHandler } = require("../middleware/error");

/**
 * GET /api/v1/news - Lấy danh sách tin tức công nghệ, AI & Việc làm IT
 */
const getNews = asyncHandler(async (req, res) => {
  const result = await newsService.getNews(req.query);
  return sendSuccess(res, result.items, 200, result.meta);
});

module.exports = {
  getNews,
};

