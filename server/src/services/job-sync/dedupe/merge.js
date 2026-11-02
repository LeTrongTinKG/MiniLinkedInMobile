// Tầng 2: lọc trùng giữa các nguồn (và với job đã có trong DB).
// Các bước: gom nhóm theo công ty -> so tiêu đề bằng Jaccard -> chấm điểm chọn bản giữ -> bù trường thiếu.
const { normalizeCompany, normalizeTitle, titleTokens } = require("./normalize");
const { jaccard } = require("./jaccard");
const { rankOf } = require("../cleaner/url");

const SIMILAR_THRESHOLD = 0.8;
const GENERIC_CITY = "Việt Nam";

// Khóa nhóm công ty (nếu chuẩn hóa ra rỗng thì dùng tên gốc)
function companyKeyOf(job) {
  return normalizeCompany(job.companyName) || String(job.companyName || "").toLowerCase();
}

// Chuỗi lưu vào cột dedupeKey: "công ty|tiêu đề" đã chuẩn hóa
function makeDedupeKey(job) {
  return `${companyKeyOf(job)}|${normalizeTitle(job.title)}`;
}

// Cùng thành phố; nếu một bên chỉ ghi chung chung "Việt Nam" thì coi là khớp
function sameCity(a, b) {
  return a.location === b.location || a.location === GENERIC_CITY || b.location === GENERIC_CITY;
}

function isDuplicate(a, b) {
  return jaccard(titleTokens(a.title), titleTokens(b.title)) >= SIMILAR_THRESHOLD && sameCity(a, b);
}

// Link "trực tiếp": nguồn báo direct hoặc là web công ty
function hasDirectLink(job) {
  if (job.applyIsDirect) return true;
  try {
    return rankOf(new URL(job.applyUrl).hostname.replace(/^www\./, "")) === 1;
  } catch {
    return false;
  }
}

function hasSalary(job) {
  return job.salaryMin != null || job.salaryMax != null;
}

// Điểm của job a khi so với b: link trực tiếp +3, có lương +2, mô tả dài hơn +1, đăng gần đây hơn +1
function scoreAgainst(a, b) {
  let score = 0;
  if (hasDirectLink(a)) score += 3;
  if (hasSalary(a)) score += 2;
  if ((a.description || "").length > (b.description || "").length) score += 1;
  if (a.postedAt && (!b.postedAt || a.postedAt > b.postedAt)) score += 1;
  return score;
}

// Bản thắng thiếu trường nào thì lấy từ bản thua bù vào
function fillMissing(winner, loser) {
  const merged = { ...winner };
  if (!hasSalary(winner) && hasSalary(loser)) {
    merged.salaryMin = loser.salaryMin;
    merged.salaryMax = loser.salaryMax;
    merged.salaryCurrency = loser.salaryCurrency;
  }
  if (!winner.companyLogoUrl && loser.companyLogoUrl) merged.companyLogoUrl = loser.companyLogoUrl;
  if (!winner.applyUrl && loser.applyUrl) merged.applyUrl = loser.applyUrl;
  if (!(winner.requiredSkills || []).length) merged.requiredSkills = loser.requiredSkills || [];
  if (!(winner.niceToHave || []).length) merged.niceToHave = loser.niceToHave || [];
  return merged;
}

// Các cột được phép ghi đè khi bản mới thắng bản trong DB
const DB_PATCH_FIELDS = [
  "source", "externalId", "title", "location", "workMode", "level", "salaryMin", "salaryMax", "salaryCurrency",
  "description", "requiredSkills", "niceToHave", "applyUrl", "companyLogoUrl",
];
function pick(job, fields) {
  return Object.fromEntries(fields.map((f) => [f, job[f]]));
}

// newJobs: job vừa làm sạch. dbJobs: job đang có trong DB (đã có id, dedupeKey...).
// Trả { kept, duplicates, dbPatches: [{ id, data }], touchedDbIds }
function dedupeJobs(newJobs, dbJobs = []) {
  const blocks = new Map(); // companyKey -> [{ job, dbId }]
  const addToBlock = (job, dbId) => {
    const key = companyKeyOf(job);
    if (!blocks.has(key)) blocks.set(key, []);
    const entry = { job, dbId };
    blocks.get(key).push(entry);
    return entry;
  };
  // Job tự đăng (internal) không phải bản sao của nguồn ngoài nên không đưa vào so sánh
  dbJobs.filter((j) => j.source !== "internal").forEach((j) => addToBlock(j, j.id));

  const kept = [];
  const patches = new Map();
  const touchedDbIds = new Set();
  let duplicates = 0;

  for (const job of newJobs) {
    const block = blocks.get(companyKeyOf(job)) || [];
    // Không so với chính bản ghi cùng (source, externalId) của nó trong DB (đó là tầng 1)
    const match = block.find((e) => !(e.job.source === job.source && e.job.externalId === job.externalId) && isDuplicate(e.job, job));
    if (!match) {
      addToBlock(job, null);
      kept.push(job);
      continue;
    }
    duplicates++;
    const newWins = scoreAgainst(job, match.job) > scoreAgainst(match.job, job);
    const winner = newWins ? fillMissing(job, match.job) : fillMissing(match.job, job);

    if (match.dbId) {
      touchedDbIds.add(match.dbId);
      // Bản mới thắng: ghi đè dòng trong DB. Bản cũ thắng: chỉ bù trường thiếu.
      patches.set(match.dbId, pick(winner, newWins ? DB_PATCH_FIELDS : ["salaryMin", "salaryMax", "salaryCurrency", "companyLogoUrl", "applyUrl"]));
      match.job = { ...match.job, ...winner };
    } else {
      kept[kept.indexOf(match.job)] = winner;
      match.job = winner;
    }
  }

  const dbPatches = [...patches].map(([id, data]) => ({ id, data }));
  return { kept, duplicates, dbPatches, touchedDbIds: [...touchedDbIds] };
}

module.exports = { dedupeJobs, makeDedupeKey, scoreAgainst, fillMissing, isDuplicate, companyKeyOf };
