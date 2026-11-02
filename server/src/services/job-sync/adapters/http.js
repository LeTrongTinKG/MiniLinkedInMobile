// Gọi API bằng axios, có cache JSON thô và che key khi báo lỗi.
const fs = require("fs");
const path = require("path");
const axios = require("axios");

const CACHE_DIR = path.join(__dirname, "..", "..", "..", "..", ".cache", "job-sync");
const TIMEOUT_MS = 30000;

// Che mọi giá trị key/token trong chuỗi (SerpApi nhận key qua query string)
function maskSecrets(text) {
  return String(text)
    .replace(/(api_key|apikey|key|token)=[^&\s"']+/gi, "$1=***")
    .replace(/(x-rapidapi-key)["':\s]+[^\s"',]+/gi, "$1: ***");
}

// "junior node.js" -> "junior-node-js" (bỏ dấu tiếng Việt)
function slug(text) {
  return String(text).normalize("NFD").replace(/[̀-ͯ]/g, "").replace(/đ/gi, "d").toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "");
}

function cacheFile(name) {
  return path.join(CACHE_DIR, `${name}.json`);
}

function readCache(name) {
  try {
    return JSON.parse(fs.readFileSync(cacheFile(name), "utf8"));
  } catch {
    return null;
  }
}

function writeCache(name, data) {
  fs.mkdirSync(CACHE_DIR, { recursive: true });
  fs.writeFileSync(cacheFile(name), JSON.stringify(data));
}

// options: { cacheName, useCache }. Có --cache thì đọc/ghi cache; không thì luôn gọi mạng (và vẫn ghi cache để tham khảo).
// Trả { data, fromCache }. Lỗi ném ra Error đã che key.
async function fetchJson(url, headers, options = {}) {
  const { cacheName, useCache } = options;
  if (useCache && cacheName) {
    const cached = readCache(cacheName);
    if (cached) return { data: cached, fromCache: true };
  }

  // axios tự parse JSON, tự ném lỗi khi mã HTTP không phải 2xx, và có timeout sẵn.
  let response;
  try {
    response = await axios.get(url, { headers, timeout: TIMEOUT_MS });
  } catch (error) {
    // Lỗi của axios chứa cả url (có key) trong error.config, nên KHÔNG ném nguyên lỗi ra ngoài.
    // Tạo lỗi mới chỉ giữ mã HTTP và thông báo đã che key.
    const status = error.response?.status;
    const err = new Error(
      status ? `Nguồn trả lỗi HTTP ${status}` : `Không gọi được nguồn: ${maskSecrets(error.message)}`
    );
    err.status = status;
    throw err;
  }
  const data = response.data;
  if (cacheName) writeCache(cacheName, data);
  return { data, fromCache: false };
}

module.exports = { fetchJson, maskSecrets, slug, readCache };
