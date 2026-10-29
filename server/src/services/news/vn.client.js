const Parser = require("rss-parser");

const parser = new Parser({ timeout: 7000 });

const VN_FEEDS = [
  {
    category: "ai",
    url: "https://news.google.com/rss/search?q=tr%C3%AD+tu%E1%BB%87+nh%C3%A2n+t%E1%BA%A1o+AI&hl=vi&gl=VN&ceid=VN:vi",
  },
  {
    category: "tech",
    url: "https://news.google.com/rss/search?q=c%C3%B4ng+ngh%E1%BB%87+ph%E1%BA%A7n+m%E1%BB%81m+l%E1%BA%ADp+tr%C3%ACnh&hl=vi&gl=VN&ceid=VN:vi",
  },
  {
    category: "jobs",
    url: "https://news.google.com/rss/search?q=tuy%E1%BB%83n+d%E1%BB%A5ng+l%E1%BA%ADp+tr%C3%ACnh+vi%C3%AAn+vi%E1%BB%87c+l%C3%A0m+IT&hl=vi&gl=VN&ceid=VN:vi",
  },
];

/**
 * Tách tiêu đề và tên nguồn báo chí từ chuỗi Google News
 */
function parseTitleAndSource(rawTitle) {
  if (!rawTitle) return { title: "Tin tức công nghệ", sourceName: "Báo chí VN" };
  const lastDashIdx = rawTitle.lastIndexOf(" - ");
  if (lastDashIdx > 0) {
    return {
      title: rawTitle.slice(0, lastDashIdx).trim(),
      sourceName: rawTitle.slice(lastDashIdx + 3).trim(),
    };
  }
  return { title: rawTitle.trim(), sourceName: "Báo chí VN" };
}

/**
 * Chuẩn hóa một RSS item thành NewsItem
 */
function normalizeVnItem(item, category, index) {
  const { title, sourceName } = parseTitleAndSource(item.title);
  const rawSnippet = item.contentSnippet || item.content || "";
  const cleanSnippet = rawSnippet.replace(/<[^>]+>/g, " ").replace(/\s+/g, " ").trim();
  const idSeed = item.guid || item.link || `${category}-${index}-${Date.now()}`;
  const safeId = `vn-${idSeed.replace(/[^a-zA-Z0-9]/g, "").slice(-24)}`;

  return {
    id: safeId,
    title,
    summary: cleanSnippet.length > 250 ? `${cleanSnippet.slice(0, 250)}...` : cleanSnippet || null,
    sourceUrl: item.link || "",
    sourceName,
    category,
    language: "vi",
    publishedAt: item.isoDate ? new Date(item.isoDate).toISOString() : new Date().toISOString(),
    imageUrl: null,
  };
}

/**
 * Kéo toàn bộ tin tức AI, Tech và Tech Jobs tiếng Việt
 */
async function fetchVnNews() {
  const fetchPromises = VN_FEEDS.map(async ({ category, url }) => {
    try {
      const feed = await parser.parseURL(url);
      const items = (feed.items || []).slice(0, 10);
      return items.map((item, idx) => normalizeVnItem(item, category, idx));
    } catch (err) {
      console.warn(`[VnClient] Lỗi fetch category=${category}:`, err.message);
      return [];
    }
  });

  const feedResults = await Promise.all(fetchPromises);
  const seenUrls = new Set();
  const results = [];

  for (const group of feedResults) {
    for (const item of group) {
      if (item.sourceUrl && !seenUrls.has(item.sourceUrl)) {
        seenUrls.add(item.sourceUrl);
        results.push(item);
      }
    }
  }

  return results;
}

module.exports = {
  fetchVnNews,
  parseTitleAndSource,
  normalizeVnItem,
};

