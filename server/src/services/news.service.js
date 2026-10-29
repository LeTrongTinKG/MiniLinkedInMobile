const { newsCache } = require("./news/news-cache");
const hnClient = require("./news/hn.client");
const vnClient = require("./news/vn.client");

const VALID_LANGUAGES = ["en", "vi"];
const VALID_CATEGORIES = ["ai", "tech", "jobs"];

let activeFetchPromise = null;

/**
 * Làm mới dữ liệu từ các API ngoài (HN + Google News VN)
 */
async function refreshNewsSources({ cache = newsCache, hn = hnClient, vn = vnClient } = {}) {
  if (activeFetchPromise) {
    if (cache.articles.length > 0) {
      return cache.getArticles();
    }
    return activeFetchPromise;
  }

  activeFetchPromise = (async () => {
    try {
      const [hnArticles, vnArticles] = await Promise.all([
        hn.fetchHnNews(),
        vn.fetchVnNews(),
      ]);

      const combined = [...hnArticles, ...vnArticles];
      combined.sort((a, b) => new Date(b.publishedAt) - new Date(a.publishedAt));

      if (combined.length > 0) {
        cache.setArticles(combined);
      }
      return cache.getArticles();
    } catch (err) {
      console.warn("[NewsService] Lỗi khi làm mới tin tức ngoài, dùng cache cũ:", err.message);
      return cache.getArticles();
    } finally {
      activeFetchPromise = null;
    }
  })();

  return activeFetchPromise;
}

/**
 * Lấy danh sách tin tức công nghệ, AI & Jobs kèm bộ lọc
 */
async function getNews(query = {}, deps = {}) {
  const cache = deps.cache || newsCache;
  let allArticles = cache.getArticles();

  if (!cache.isFresh()) {
    allArticles = await refreshNewsSources({ ...deps, cache });
  }

  let filtered = allArticles;

  // 1. Lọc theo ngôn ngữ (en / vi)
  const lang = (query.lang || "").toLowerCase();
  if (VALID_LANGUAGES.includes(lang)) {
    filtered = filtered.filter((item) => item.language === lang);
  }

  // 2. Lọc theo chủ đề (ai / tech / jobs)
  const category = (query.category || "").toLowerCase();
  if (VALID_CATEGORIES.includes(category)) {
    filtered = filtered.filter((item) => item.category === category);
  }

  // 3. Tìm kiếm theo từ khóa
  const keyword = (query.q || "").trim().toLowerCase();
  if (keyword) {
    filtered = filtered.filter((item) =>
      item.title.toLowerCase().includes(keyword) ||
      (item.summary && item.summary.toLowerCase().includes(keyword))
    );
  }

  // 4. Phân trang
  const page = Math.max(1, parseInt(query.page, 10) || 1);
  const limit = Math.min(100, Math.max(1, parseInt(query.limit, 10) || 30));
  const total = filtered.length;
  const totalPages = Math.ceil(total / limit) || 1;
  const skip = (page - 1) * limit;
  const items = filtered.slice(skip, skip + limit);

  return {
    items,
    meta: {
      page,
      limit,
      total,
      totalPages,
      hasNextPage: page < totalPages,
      hasPrevPage: page > 1,
      ...cache.getMeta(),
    },
  };
}

module.exports = {
  getNews,
  refreshNewsSources,
  VALID_LANGUAGES,
  VALID_CATEGORIES,
};
