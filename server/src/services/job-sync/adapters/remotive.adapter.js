// Nguồn 3: Remotive (miễn phí, không cần key). Gọi 1 lần mỗi lượt, lấy cả danh sách.
// Điều khoản Remotive: gọi thưa và ghi nguồn. Link ứng tuyển trỏ về trang remotive.com của job.
const { fetchJson } = require("./http");

const SOURCE = "remotive";
const URL_ALL = "https://remotive.com/api/remote-jobs?category=software-dev&limit=50";

function toRawJob(item) {
  return {
    source: SOURCE,
    externalId: String(item.id),
    title: item.title,
    company: item.company_name,
    logoUrl: item.company_logo_url || item.company_logo || null,
    location: item.candidate_required_location, // vùng được tuyển, vd "Worldwide"
    descriptionRaw: item.description, // HTML, cleaner sẽ xóa thẻ
    salaryText: item.salary,
    isRemote: true,
    applyLinks: [{ url: item.url, isDirect: false }],
    postedAt: item.publication_date ? `${item.publication_date}Z` : null, // giờ UTC, API không kèm "Z"
    keyword: "remotive",
  };
}

async function search(_keyword, { useCache = false } = {}) {
  const { data, fromCache } = await fetchJson(URL_ALL, {}, { cacheName: "remotive", useCache });
  const items = (data && data.jobs) || [];
  return { rawJobs: items.map(toRawJob), fromCache };
}

module.exports = { search, toRawJob, SOURCE };
