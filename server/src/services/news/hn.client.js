const HN_BASE_URL = "https://hn.algolia.com/api/v1/search_by_date";
const TIMEOUT_MS = 6000;

/**
 * Chuẩn hóa một hit từ Algolia Hacker News thành NewsItem
 */
function normalizeHnHit(hit, category) {
  const points = hit.points || 0;
  const comments = hit.num_comments || 0;
  const author = hit.author || "hn";
  const rawText = hit.story_text ? hit.story_text.replace(/<[^>]+>/g, " ").trim() : "";
  const summary = rawText ? rawText.slice(0, 250) : `Thảo luận Hacker News (${points} points, ${comments} comments) bởi @${author}`;

  return {
    id: `hn-${hit.objectID}`,
    title: (hit.title || hit.story_title || "Tech update").trim(),
    summary,
    sourceUrl: hit.url || `https://news.ycombinator.com/item?id=${hit.objectID}`,
    sourceName: "Hacker News",
    category,
    language: "en",
    publishedAt: new Date(hit.created_at || Date.now()).toISOString(),
    imageUrl: null,
  };
}

/**
 * Gọi API Algolia với timeout an toàn
 */
async function fetchAlgolia(params) {
  try {
    const url = `${HN_BASE_URL}?${new URLSearchParams(params).toString()}`;
    const res = await fetch(url, { signal: AbortSignal.timeout(TIMEOUT_MS) });
    if (!res.ok) return [];
    const data = await res.json();
    return Array.isArray(data.hits) ? data.hits : [];
  } catch (err) {
    console.warn(`[HNClient] Lỗi fetch query=${params.query || params.tags}:`, err.message);
    return [];
  }
}

/**
 * Kéo toàn bộ tin tức AI, Tech và Tech Jobs từ Hacker News
 */
async function fetchHnNews() {
  const [aiHits, techHits, jobHits] = await Promise.all([
    fetchAlgolia({ tags: "story", query: "AI OR LLM OR OpenAI OR Gemini", hitsPerPage: "15" }),
    fetchAlgolia({ tags: "front_page", hitsPerPage: "15" }),
    fetchAlgolia({ tags: "job", hitsPerPage: "10" }),
  ]);

  const seenIds = new Set();
  const results = [];

  for (const hit of aiHits) {
    if (!seenIds.has(hit.objectID)) {
      seenIds.add(hit.objectID);
      results.push(normalizeHnHit(hit, "ai"));
    }
  }

  for (const hit of techHits) {
    if (!seenIds.has(hit.objectID)) {
      seenIds.add(hit.objectID);
      results.push(normalizeHnHit(hit, "tech"));
    }
  }

  for (const hit of jobHits) {
    if (!seenIds.has(hit.objectID)) {
      seenIds.add(hit.objectID);
      results.push(normalizeHnHit(hit, "jobs"));
    }
  }

  return results;
}

module.exports = {
  fetchHnNews,
  normalizeHnHit,
  fetchAlgolia,
};
