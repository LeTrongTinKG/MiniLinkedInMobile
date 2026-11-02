const { normalizeCompany } = require("../dedupe/normalize");

// Bước 3: chọn link ứng tuyển. Chỉ nhận https, ưu tiên: web công ty > ITviec/TopCV > LinkedIn > trang tổng hợp khác.

const PRIORITY_HOSTS = ["itviec.com", "topcv.vn"];
const LINKEDIN_HOSTS = ["linkedin.com"];
// Trang tổng hợp việc làm (không phải web công ty)
const AGGREGATOR_HOSTS = [
  "indeed.com", "glassdoor.com", "vietnamworks.com", "careerviet.vn", "glints.com",
  "jooble.org", "bebee.com", "careerlink.vn", "fidovn.com", "reeracoen.vn", "reeracoen.com.vn", "jobstreet.vn",
  "jobstreet.com", "joboko.com", "timviecnhanh.com", "vieclam24h.vn", "mywork.com.vn",
  "careerbuilder.vn", "ziprecruiter.com", "talent.com", "remotive.com", "jobsgo.vn", "adzuna.com",
  "learn4good.com", "jobrapido.com", "whatjobs.com", "recruit.net", "grabjobs.co", "monster.com",
];
const BAD_HOSTS = ["google.com"]; // link tìm kiếm của Google, không phải link ứng tuyển

function hostMatches(host, list) {
  return list.some((h) => host === h || host.endsWith("." + h));
}

// Host lạ chỉ được coi là web công ty khi tên miền chứa tên công ty (vd vng.com.vn cho "VNG Corporation")
function hostMatchesCompany(host, companyName) {
  if (!companyName) return false;
  const flat = host.replace(/[^a-z0-9]/g, "");
  return normalizeCompany(companyName).split(" ").some((word) => word.length >= 3 && flat.includes(word.replace(/[^a-z0-9]/g, "")));
}

// Phân loại link: số càng nhỏ càng ưu tiên. null = bỏ.
function rankOf(host) {
  if (hostMatches(host, BAD_HOSTS)) return null;
  if (hostMatches(host, PRIORITY_HOSTS)) return 2;
  if (hostMatches(host, LINKEDIN_HOSTS)) return 3;
  if (hostMatches(host, AGGREGATOR_HOSTS)) return 4;
  return 1; // web công ty
}

// Kiểm tra https và bỏ tham số theo dõi utm_*. Không hợp lệ thì trả null.
function normalizeUrl(link) {
  let url;
  try {
    url = new URL(String(link || "").trim());
  } catch {
    return null;
  }
  if (url.protocol !== "https:") return null;
  for (const key of [...url.searchParams.keys()]) {
    if (key.toLowerCase().startsWith("utm_")) url.searchParams.delete(key);
  }
  return url.toString();
}

// links: [{ url, isDirect }]. Trả { url, rank } tốt nhất hoặc null.
// Host lạ (không phải trang tuyển dụng quen biết) chỉ nhận khi nguồn báo "direct" hoặc tên miền khớp tên công ty,
// vì phần lớn host lạ là trang cào lại tin (có thể giả mạo).
function pickApplyLink(links, companyName) {
  const candidates = [];
  for (const item of links || []) {
    const url = normalizeUrl(item && item.url);
    if (!url) continue;
    const host = new URL(url).hostname.replace(/^www\./, "").toLowerCase();
    const rank = rankOf(host);
    if (rank === null) continue;
    if (rank === 1 && !item.isDirect && !hostMatchesCompany(host, companyName)) continue;
    candidates.push({ url, rank, isDirect: Boolean(item.isDirect) });
  }
  // rank nhỏ trước; cùng rank thì link "direct" trước
  candidates.sort((a, b) => a.rank - b.rank || Number(b.isDirect) - Number(a.isDirect));
  return candidates[0] || null;
}

module.exports = { pickApplyLink, normalizeUrl, rankOf, hostMatchesCompany };
