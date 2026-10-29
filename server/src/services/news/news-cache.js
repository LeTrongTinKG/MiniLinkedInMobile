const CACHE_TTL_MS = 5 * 60 * 1000; // 5 phút

class NewsCache {
  constructor(ttlMs = CACHE_TTL_MS) {
    this.ttlMs = ttlMs;
    this.articles = [];
    this.lastFetchedAt = 0;
    this.isFetching = false;
  }

  isFresh() {
    return this.articles.length > 0 && Date.now() - this.lastFetchedAt < this.ttlMs;
  }

  getArticles() {
    return this.articles;
  }

  setArticles(newArticles) {
    if (Array.isArray(newArticles) && newArticles.length > 0) {
      this.articles = newArticles;
      this.lastFetchedAt = Date.now();
    }
  }

  getMeta() {
    const ageSeconds = Math.floor((Date.now() - this.lastFetchedAt) / 1000);
    const remainingSeconds = Math.max(0, Math.floor((this.ttlMs - (Date.now() - this.lastFetchedAt)) / 1000));
    return {
      cachedAt: this.lastFetchedAt > 0 ? new Date(this.lastFetchedAt).toISOString() : null,
      ageSeconds,
      expiresInSeconds: remainingSeconds,
    };
  }

  clear() {
    this.articles = [];
    this.lastFetchedAt = 0;
    this.isFetching = false;
  }
}

// Singleton cache instance cho toàn server
const newsCache = new NewsCache();

module.exports = {
  NewsCache,
  newsCache,
  CACHE_TTL_MS,
};

