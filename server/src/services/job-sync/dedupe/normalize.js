// Chuẩn hóa tên công ty và tiêu đề để so trùng giữa các nguồn.

// Bỏ dấu tiếng Việt, chữ thường
function removeAccents(text) {
  return String(text || "")
    .normalize("NFD")
    .replace(/[̀-ͯ]/g, "")
    .replace(/đ/gi, "d")
    .toLowerCase();
}

// Các cụm không mang ý nghĩa tên công ty (đã bỏ dấu)
const COMPANY_NOISE = [
  "cong ty", "trach nhiem huu han", "tnhh", "co phan", "mot thanh vien", "mtv", "thuong mai", "dich vu",
  "jsc", "joint stock company", "company", "limited", "co ltd", "co.", "ltd", "llc", "inc", "corp",
  "viet nam", "vietnam", "vn",
];

// "Công ty TNHH FPT Software Việt Nam" -> "fpt software"
function normalizeCompany(name) {
  let text = removeAccents(name).replace(/[|&,().\-]/g, " ");
  text = ` ${text.replace(/\s+/g, " ")} `;
  // Chạy 2 vòng để bắt các cụm đứng sát nhau (vd "cong ty tnhh")
  for (let round = 0; round < 2; round++) {
    for (const noise of COMPANY_NOISE) {
      text = text.split(` ${noise.replace(/\./g, "")} `).join(" ");
    }
  }
  return text.replace(/\s+/g, " ").trim();
}

const CITY_WORDS = "ha noi|hanoi|ho chi minh|hcm|sai gon|saigon|da nang|danang|can tho|hai phong|tan binh|remote";

// "[HN] Junior Java Developer - Hà Nội Lương upto 2000$ Urgent" -> "junior java developer"
function normalizeTitle(title) {
  let text = removeAccents(title);
  text = text.replace(/\[[^\]]*\]/g, " "); // [HN], [Hot]
  text = text.replace(new RegExp(`\\(\\s*(${CITY_WORDS})[^)]*\\)`, "g"), " "); // (Da Nang)
  text = text.replace(new RegExp(`[-–|,]\\s*(${CITY_WORDS}).*$`), " "); // - Ha Noi
  text = text.replace(/\b(luong|salary|upto|up to|thu nhap)\b.*$/, " "); // Lương upto 2000$
  text = text.replace(/\b(urgent|hot|tuyen gap|gap|job opening|hiring)\b/g, " ");
  text = text.replace(/[^a-z0-9+#.]+/g, " "); // giữ c#, c++, .net, node.js
  return text.split(" ").map((w) => w.replace(/\.+$/, "")).filter(Boolean).join(" ").trim();
}

// Tách tiêu đề thành tập từ để tính Jaccard
function titleTokens(title) {
  return new Set(normalizeTitle(title).split(" ").filter(Boolean));
}

module.exports = { removeAccents, normalizeCompany, normalizeTitle, titleTokens };
