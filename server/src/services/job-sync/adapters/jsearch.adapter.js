// Nguồn 1: JSearch (RapidAPI). Mỗi lần gọi = 1 request.
const { fetchJson, slug } = require("./http");

const SOURCE = "jsearch";
const BASE_URL = "https://jsearch.p.rapidapi.com/search-v2";

// Đổi 1 job của JSearch sang RawJob (định dạng chung)
function toRawJob(item, keyword) {
  const links = (item.apply_options || []).map((o) => ({ url: o.apply_link, isDirect: o.is_direct }));
  if (item.job_apply_link) links.push({ url: item.job_apply_link, isDirect: item.job_apply_is_direct });
  return {
    source: SOURCE,
    externalId: item.job_id || item.job_uid,
    title: item.job_title,
    company: item.employer_name,
    logoUrl: null, // logo của JSearch là ảnh thumbnail Google, không dùng
    location: item.job_location,
    city: item.job_city,
    countryCode: item.job_country,
    descriptionRaw: item.job_description,
    salaryStruct: {
      min: item.job_min_salary,
      max: item.job_max_salary,
      currency: item.job_salary_currency,
      period: item.job_salary_period,
    },
    salaryText: item.job_salary_string || item.job_salary,
    isRemote: item.job_is_remote === true,
    applyLinks: links,
    postedAt: item.job_posted_at_datetime_utc,
    postedText: item.job_posted_at,
    keyword,
  };
}

// Gọi 1 request cho 1 từ khóa. Trả { rawJobs, fromCache }
async function search(keyword, { env = process.env, useCache = false } = {}) {
  if (!env.RAPIDAPI_KEY || !env.RAPIDAPI_HOST) throw new Error("Thiếu RAPIDAPI_KEY hoặc RAPIDAPI_HOST trong .env");
  const url = `${BASE_URL}?query=${encodeURIComponent(keyword)}&country=vn&num_pages=1`;
  const headers = { "x-rapidapi-key": env.RAPIDAPI_KEY, "x-rapidapi-host": env.RAPIDAPI_HOST };
  const { data, fromCache } = await fetchJson(url, headers, { cacheName: `jsearch-${slug(keyword)}`, useCache });
  const items = (data && data.data && data.data.jobs) || [];
  return { rawJobs: items.map((item) => toRawJob(item, keyword)), fromCache };
}

module.exports = { search, toRawJob, SOURCE };
