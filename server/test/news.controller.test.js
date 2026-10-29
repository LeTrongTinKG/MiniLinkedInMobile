const { describe, it, beforeEach } = require("node:test");
const assert = require("node:assert/strict");

const newsController = require("../src/controllers/news.controller");
const newsService = require("../src/services/news.service");
const { NewsCache } = require("../src/services/news/news-cache");
const { dispatch } = require("./helpers");

const mockArticles = [
  {
    id: "hn-1",
    title: "OpenAI announces GPT-5 Preview for developers",
    summary: "New capabilities for coding and reasoning.",
    sourceUrl: "https://news.ycombinator.com/item?id=1",
    sourceName: "Hacker News",
    category: "ai",
    language: "en",
    publishedAt: "2026-10-29T10:00:00.000Z",
    imageUrl: null,
  },
  {
    id: "hn-2",
    title: "Flutter 4.0 architecture updates and best practices",
    summary: "Guide on clean architecture for modern mobile development.",
    sourceUrl: "https://news.ycombinator.com/item?id=2",
    sourceName: "Hacker News",
    category: "tech",
    language: "en",
    publishedAt: "2026-10-29T09:30:00.000Z",
    imageUrl: null,
  },
  {
    id: "hn-3",
    title: "Y Combinator is hiring AI Engineers and Tech Interns",
    summary: "Exciting opportunities in tech.",
    sourceUrl: "https://news.ycombinator.com/item?id=3",
    sourceName: "Hacker News",
    category: "jobs",
    language: "en",
    publishedAt: "2026-10-29T09:00:00.000Z",
    imageUrl: null,
  },
  {
    id: "vn-1",
    title: "Việt Nam đẩy mạnh ứng dụng AI trong doanh nghiệp",
    summary: "Các mô hình ngôn ngữ lớn đang được áp dụng rộng rãi.",
    sourceUrl: "https://vnexpress.net/ai-1",
    sourceName: "VNExpress",
    category: "ai",
    language: "vi",
    publishedAt: "2026-10-29T08:30:00.000Z",
    imageUrl: null,
  },
  {
    id: "vn-2",
    title: "Tuyển dụng kỹ sư lập trình di động Flutter và Node.js",
    summary: "Nhu cầu tuyển dụng lập trình viên cuối năm tăng cao.",
    sourceUrl: "https://tinhte.vn/jobs-1",
    sourceName: "Tinhte",
    category: "jobs",
    language: "vi",
    publishedAt: "2026-10-29T08:00:00.000Z",
    imageUrl: null,
  },
];

describe("GET /api/v1/news — Controller & Service", () => {
  let testCache;

  beforeEach(() => {
    testCache = new NewsCache(5 * 60 * 1000);
    testCache.setArticles([...mockArticles]);
  });

  it("trả về 200 và danh sách tin tức công khai mà không cần token", async () => {
    const originalGetNews = newsService.getNews;
    newsService.getNews = async (q) => originalGetNews(q, { cache: testCache });
    try {
      const req = { query: {} };
      const res = await dispatch(newsController.getNews, req);
      assert.equal(res.statusCode, 200);
      assert.equal(res.body.data.length, 5);
      assert.equal(res.body.meta.total, 5);
      assert.ok(res.body.meta.cachedAt);
    } finally {
      newsService.getNews = originalGetNews;
    }
  });

  it("lọc chính xác theo ngôn ngữ ?lang=en và ?lang=vi", async () => {
    const enRes = await newsService.getNews({ lang: "en" }, { cache: testCache });
    assert.equal(enRes.items.length, 3);
    assert.ok(enRes.items.every((i) => i.language === "en"));

    const viRes = await newsService.getNews({ lang: "vi" }, { cache: testCache });
    assert.equal(viRes.items.length, 2);
    assert.ok(viRes.items.every((i) => i.language === "vi"));
  });

  it("lọc chính xác theo category ?category=ai, tech, jobs", async () => {
    const aiRes = await newsService.getNews({ category: "ai" }, { cache: testCache });
    assert.equal(aiRes.items.length, 2);
    assert.ok(aiRes.items.every((i) => i.category === "ai"));

    const techRes = await newsService.getNews({ category: "tech" }, { cache: testCache });
    assert.equal(techRes.items.length, 1);
    assert.equal(techRes.items[0].category, "tech");

    const jobsRes = await newsService.getNews({ category: "jobs" }, { cache: testCache });
    assert.equal(jobsRes.items.length, 2);
    assert.ok(jobsRes.items.every((i) => i.category === "jobs"));
  });

  it("tìm kiếm theo từ khóa q trong title và summary", async () => {
    const res = await newsService.getNews({ q: "Flutter" }, { cache: testCache });
    assert.equal(res.items.length, 2);
    assert.ok(res.items.some((i) => i.id === "hn-2"));
    assert.ok(res.items.some((i) => i.id === "vn-2"));
  });

  it("hỗ trợ phân trang page và limit", async () => {
    const res = await newsService.getNews({ page: 2, limit: 2 }, { cache: testCache });
    assert.equal(res.items.length, 2);
    assert.equal(res.meta.page, 2);
    assert.equal(res.meta.limit, 2);
    assert.equal(res.meta.totalPages, 3);
    assert.equal(res.meta.hasPrevPage, true);
    assert.equal(res.meta.hasNextPage, true);
  });

  it("tự động refresh khi cache hết hạn (expired)", async () => {
    const expiredCache = new NewsCache(1); // 1ms TTL
    expiredCache.setArticles([...mockArticles.slice(0, 2)]);
    await new Promise((r) => setTimeout(r, 10)); // Đảm bảo đã quá TTL

    const mockHn = { fetchHnNews: async () => [mockArticles[0]] };
    const mockVn = { fetchVnNews: async () => [mockArticles[3]] };

    const res = await newsService.getNews({}, { cache: expiredCache, hn: mockHn, vn: mockVn });
    assert.equal(res.items.length, 2);
    assert.equal(expiredCache.isFresh(), true);
  });

  it("resilience / SWR: khi API ngoài bị lỗi, vẫn giữ cache cũ và không văng 500", async () => {
    const expiredCache = new NewsCache(1);
    expiredCache.setArticles([...mockArticles]);
    await new Promise((r) => setTimeout(r, 10));

    const failingHn = {
      fetchHnNews: async () => { throw new Error("HN Network Timeout"); },
    };
    const failingVn = {
      fetchVnNews: async () => { throw new Error("Google News 503"); },
    };

    const res = await newsService.getNews({}, { cache: expiredCache, hn: failingHn, vn: failingVn });
    assert.equal(res.items.length, 5); // Vẫn trả về 5 bài trong cache cũ!
  });
});
