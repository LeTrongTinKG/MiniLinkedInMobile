const { prisma } = require("../lib/prisma");

/**
 * Tìm tin tức theo bộ lọc, phân trang, sắp xếp mới nhất
 */
async function findArticles({ where = {}, skip = 0, limit = 30 }, db = prisma) {
  return db.newsArticle.findMany({
    where,
    orderBy: { publishedAt: "desc" },
    skip,
    take: limit,
  });
}

/**
 * Đếm số lượng tin tức theo bộ lọc
 */
async function countArticles(where = {}, db = prisma) {
  return db.newsArticle.count({ where });
}

/**
 * Lưu danh sách tin tức vào Supabase (bỏ qua nếu trùng sourceUrl)
 */
async function upsertArticles(articles, db = prisma) {
  if (!Array.isArray(articles) || articles.length === 0) {
    return { count: 0 };
  }

  // Đảm bảo dữ liệu đúng schema Prisma
  const formatted = articles.map((a) => ({
    title: a.title,
    summary: a.summary || null,
    sourceUrl: a.sourceUrl,
    sourceName: a.sourceName,
    imageUrl: a.imageUrl || null,
    category: a.category === "jobs" ? "career" : a.category || "tech",
    language: a.language || "en",
    publishedAt: a.publishedAt instanceof Date ? a.publishedAt : new Date(a.publishedAt || Date.now()),
  }));

  return db.newsArticle.createMany({
    data: formatted,
    skipDuplicates: true,
  });
}

/**
 * Xóa tin cũ hơn một mốc thời gian (retention)
 */
async function deleteOlderThan(date, db = prisma) {
  return db.newsArticle.deleteMany({
    where: { publishedAt: { lt: date } },
  });
}

/**
 * Giữ tối đa maxCount bài viết mới nhất, xóa các bài cũ hơn
 */
async function trimOldArticles(maxCount = 500, db = prisma) {
  const total = await db.newsArticle.count();
  if (total <= maxCount) return { count: 0 };

  const excess = total - maxCount;
  const oldest = await db.newsArticle.findMany({
    orderBy: { publishedAt: "asc" },
    take: excess,
    select: { id: true },
  });

  return db.newsArticle.deleteMany({
    where: { id: { in: oldest.map((a) => a.id) } },
  });
}

module.exports = {
  findArticles,
  countArticles,
  upsertArticles,
  deleteOlderThan,
  trimOldArticles,
};
