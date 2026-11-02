const newsRepository = require("../repositories/news.repository");
const { runNewsSync } = require("./news/news-cron");

const VALID_LANGUAGES = ["en", "vi"];
const VALID_CATEGORIES = ["ai", "tech", "career", "jobs"];

/**
 * Lấy danh sách tin tức từ cơ sở dữ liệu Supabase kèm bộ lọc và phân trang
 */
async function getNews(query = {}, repo = newsRepository) {
  const page = Math.max(1, parseInt(query.page, 10) || 1);
  const limit = Math.min(100, Math.max(1, parseInt(query.limit, 10) || 30));
  const skip = (page - 1) * limit;

  const where = {};

  // 1. Lọc theo ngôn ngữ (en / vi)
  const lang = (query.lang || "").toLowerCase();
  if (VALID_LANGUAGES.includes(lang)) {
    where.language = lang;
  }

  // 2. Lọc theo chủ đề (ai / tech / career / jobs)
  const category = (query.category || "").toLowerCase();
  if (VALID_CATEGORIES.includes(category)) {
    where.category = category === "jobs" ? "career" : category;
  }

  // 3. Tìm kiếm theo từ khóa trong tiêu đề
  const keyword = (query.q || "").trim();
  if (keyword) {
    where.title = { contains: keyword, mode: "insensitive" };
  }

  let [items, total] = await Promise.all([
    repo.findArticles({ where, skip, limit }),
    repo.countArticles(where),
  ]);

  // Nếu DB trống (lần đầu tiên), kích hoạt đồng bộ ngay lập tức
  if (total === 0 && !keyword && !lang && !category) {
    await runNewsSync(repo);
    [items, total] = await Promise.all([
      repo.findArticles({ where, skip, limit }),
      repo.countArticles(where),
    ]);
  }

  const totalPages = Math.ceil(total / limit) || 1;

  // Chuẩn hóa dữ liệu trả về cho Client (map career -> jobs để tương thích giao diện)
  const formattedItems = items.map((item) => ({
    id: item.id,
    title: item.title,
    summary: item.summary,
    sourceUrl: item.sourceUrl,
    sourceName: item.sourceName,
    imageUrl: item.imageUrl,
    category: item.category === "career" ? "jobs" : item.category,
    language: item.language,
    publishedAt: item.publishedAt ? new Date(item.publishedAt).toISOString() : new Date().toISOString(),
  }));

  return {
    items: formattedItems,
    meta: {
      page,
      limit,
      total,
      totalPages,
      hasNextPage: page < totalPages,
      hasPrevPage: page > 1,
    },
  };
}

module.exports = {
  getNews,
  VALID_LANGUAGES,
  VALID_CATEGORIES,
};
