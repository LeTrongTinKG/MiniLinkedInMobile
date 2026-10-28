// Nguồn 2: SerpApi (Google Jobs). Mỗi lần gọi = 1 request. Key nằm trong URL nên lỗi phải che key (đã làm ở http.js).
const { fetchJson, slug } = require("./http");

const SOURCE = "serpapi";
const BASE_URL = "https://serpapi.com/search.json";

// Đổi 1 job của SerpApi sang RawJob
function toRawJob(item, keyword) {
  const ext = item.detected_extensions || {};
  const links = (item.apply_options || []).map((o) => ({ url: o.link, isDirect: false }));
  if (item.source_link) links.push({ url: item.source_link, isDirect: false });
  return {
    source: SOURCE,
    externalId: item.job_id,
    title: item.title || item.job_title,
    company: item.company_name,
    logoUrl: null, // thumbnail của SerpApi là ảnh tạm, không dùng
    location: item.location,
    descriptionRaw: item.description,
    salaryText: ext.salary || null, // SerpApi chỉ có lương dạng chữ
    isRemote: ext.work_from_home === true,
    applyLinks: links,
    postedText: ext.posted_at,
    keyword,
  };
}

async function search(keyword, { env = process.env, useCache = false } = {}) {
  if (!env.SERPAPI_KEY) throw new Error("Thiếu SERPAPI_KEY trong .env");
  const url =
    `${BASE_URL}?engine=google_jobs&q=${encodeURIComponent(keyword)}&location=Vietnam&hl=vi&gl=vn` +
    `&api_key=${encodeURIComponent(env.SERPAPI_KEY)}`;
  const { data, fromCache } = await fetchJson(url, {}, { cacheName: `serpapi-${slug(keyword)}`, useCache });
  const items = (data && data.jobs_results) || [];
  return { rawJobs: items.map((item) => toRawJob(item, keyword)), fromCache };
}

module.exports = { search, toRawJob, SOURCE };
