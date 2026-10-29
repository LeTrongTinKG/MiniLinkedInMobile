const { describe, it, beforeEach } = require("node:test");
const assert = require("node:assert/strict");

// Mock Prisma
const prisma = { newsArticle: {} };
require.cache[require.resolve("../src/lib/prisma")] = {
  exports: { prisma },
};

const newsController = require("../src/controllers/news.controller");
const newsRepository = require("../src/repositories/news.repository");
const newsService = require("../src/services/news.service");
const { dispatch } = require("./helpers");

const mockArticles = [
  {
    id: "art-1",
    title: "OpenAI announces GPT-5 Preview for developers",
    summary: "New capabilities for coding and reasoning.",
    sourceUrl: "https://news.ycombinator.com/item?id=1",
    sourceName: "Hacker News",
    category: "ai",
    language: "en",
    publishedAt: new Date("2026-10-29T10:00:00.000Z"),
    imageUrl: null,
  },
  {
    id: "art-2",
    title: "Flutter 4.0 architecture updates and best practices",
    summary: "Guide on clean architecture for modern mobile development.",
    sourceUrl: "https://news.ycombinator.com/item?id=2",
    sourceName: "Hacker News",
    category: "tech",
    language: "en",
    publishedAt: new Date("2026-10-29T09:30:00.000Z"),
    imageUrl: null,
  },
  {
    id: "art-3",
    title: "Tuyển dụng kỹ sư lập trình di động Flutter và Node.js",
    summary: "Nhu cầu tuyển dụng lập trình viên cuối năm tăng cao.",
    sourceUrl: "https://tinhte.vn/jobs-1",
    sourceName: "Tinhte",
    category: "career",
    language: "vi",
    publishedAt: new Date("2026-10-29T08:00:00.000Z"),
    imageUrl: null,
  },
];

describe("GET /api/v1/news — Controller, Service & Repository", () => {
  beforeEach(() => {
    prisma.newsArticle.findMany = async () => mockArticles;
    prisma.newsArticle.count = async () => mockArticles.length;
    prisma.newsArticle.createMany = async ({ data }) => ({ count: data.length });
    prisma.newsArticle.deleteMany = async () => ({ count: 1 });
  });

  it("trả về 200 và danh sách tin tức công khai mà không cần token", async () => {
    const req = { query: {} };
    const res = await dispatch(newsController.getNews, req);
    assert.equal(res.statusCode, 200);
    assert.equal(res.body.data.length, 3);
    assert.equal(res.body.meta.total, 3);
    // category career được map thành jobs trên response
    assert.equal(res.body.data[2].category, "jobs");
  });

  it("lọc chính xác theo ngôn ngữ ?lang=en và ?lang=vi", async () => {
    prisma.newsArticle.findMany = async ({ where }) => {
      assert.equal(where.language, "vi");
      return mockArticles.filter((a) => a.language === "vi");
    };
    prisma.newsArticle.count = async ({ where }) => {
      return mockArticles.filter((a) => a.language === where.language).length;
    };

    const res = await newsService.getNews({ lang: "vi" });
    assert.equal(res.items.length, 1);
    assert.equal(res.items[0].language, "vi");
  });

  it("lọc theo category ?category=jobs map sang career trong DB", async () => {
    prisma.newsArticle.findMany = async ({ where }) => {
      assert.equal(where.category, "career");
      return mockArticles.filter((a) => a.category === "career");
    };

    const res = await newsService.getNews({ category: "jobs" });
    assert.equal(res.items.length, 1);
    assert.equal(res.items[0].category, "jobs");
  });

  it("tìm kiếm theo từ khóa q trong tiêu đề", async () => {
    prisma.newsArticle.findMany = async ({ where }) => {
      assert.ok(where.title?.contains === "Flutter");
      return [mockArticles[1], mockArticles[2]];
    };

    const res = await newsService.getNews({ q: "Flutter" });
    assert.equal(res.items.length, 2);
  });

  it("hỗ trợ phân trang page và limit", async () => {
    prisma.newsArticle.findMany = async ({ skip, take }) => {
      assert.equal(skip, 2);
      assert.equal(take, 2);
      return [mockArticles[2]];
    };
    prisma.newsArticle.count = async () => 5;

    const res = await newsService.getNews({ page: 2, limit: 2 });
    assert.equal(res.meta.page, 2);
    assert.equal(res.meta.limit, 2);
    assert.equal(res.meta.total, 5);
    assert.equal(res.meta.totalPages, 3);
    assert.equal(res.meta.hasNextPage, true);
    assert.equal(res.meta.hasPrevPage, true);
  });

  it("repository upsertArticles lưu thành công với skipDuplicates", async () => {
    const result = await newsRepository.upsertArticles([
      {
        title: "Test",
        sourceUrl: "https://example.com/test",
        sourceName: "Test",
        category: "tech",
        language: "en",
        publishedAt: new Date(),
      },
    ]);
    assert.equal(result.count, 1);
  });

  it("repository deleteOlderThan và trimOldArticles hoạt động đúng", async () => {
    const delRes = await newsRepository.deleteOlderThan(new Date());
    assert.equal(delRes.count, 1);

    prisma.newsArticle.count = async () => 510;
    prisma.newsArticle.findMany = async () => [{ id: "1" }, { id: "2" }];
    const trimRes = await newsRepository.trimOldArticles(500);
    assert.equal(trimRes.count, 1);
  });
});
