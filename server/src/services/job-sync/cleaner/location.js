// Bước 2: địa điểm. Job phải tuyển được sinh viên Việt Nam.
const { removeAccents } = require("../dedupe/normalize");

// [tên hiển thị, regex nhận ra]
const CITIES = [
  ["Hà Nội", /h[àa] n[ộo]i|hanoi|ha noi/i],
  ["TP. Hồ Chí Minh", /h[ồo] ch[íi] minh|ho chi minh|\bhcm|saigon|sài gòn|sai gon/i],
  ["Đà Nẵng", /đ[àa] n[ẵa]ng|da nang|danang/i],
  ["Cần Thơ", /c[ầa]n th[ơo]|can tho/i],
  ["Hải Phòng", /h[ảa]i ph[òo]ng|hai phong/i],
];
const VIETNAM_REGEX = /vi[ệe]t\s?nam|vietnam|\bvn\b/i;

// Các tỉnh/thành khác (viết không dấu) để nhận ra địa điểm trong nước khi nguồn chỉ ghi tên tỉnh
const PROVINCES = [
  "an giang", "ba ria", "vung tau", "bac giang", "bac kan", "bac lieu", "bac ninh", "ben tre", "binh dinh",
  "binh duong", "binh phuoc", "binh thuan", "ca mau", "cao bang", "dak lak", "dak nong", "dien bien", "dong nai",
  "dong thap", "gia lai", "ha giang", "ha nam", "ha tinh", "hai duong", "hau giang", "hoa binh", "hung yen",
  "khanh hoa", "nha trang", "kien giang", "kon tum", "lai chau", "lam dong", "da lat", "lang son", "lao cai",
  "long an", "nam dinh", "nghe an", "ninh binh", "ninh thuan", "phu tho", "phu yen", "quang binh", "quang nam",
  "quang ngai", "quang ninh", "quang tri", "soc trang", "son la", "tay ninh", "thai binh", "thai nguyen",
  "thanh hoa", "thua thien", "hue", "tien giang", "tra vinh", "tuyen quang", "vinh long", "vinh phuc", "yen bai",
];
const PROVINCE_REGEX = new RegExp(`\\b(${PROVINCES.join("|")})\\b`);

// Bỏ phần "• qua LinkedIn" mà JSearch hay dán vào cuối địa điểm
function cleanLocationText(text) {
  return String(text || "").split("•")[0].replace(/\s+/g, " ").trim();
}

function detectCity(text) {
  const found = CITIES.find(([, regex]) => regex.test(text));
  return found ? found[0] : null;
}

// Remotive: chỉ nhận vùng tuyển Worldwide / Asia / Vietnam
function isRemotiveLocationOk(text) {
  return /worldwide|anywhere|asia|vi[ệe]t\s?nam|vietnam/i.test(text || "");
}

// JSearch/SerpApi: phải ở Việt Nam (mã nước VN, hoặc chữ địa điểm có Việt Nam / tên thành phố)
function isVietnamJob(raw) {
  if (raw.source === "remotive") return isRemotiveLocationOk(raw.location);
  if (raw.countryCode) return String(raw.countryCode).toUpperCase() === "VN";
  const text = cleanLocationText(raw.location);
  return VIETNAM_REGEX.test(text) || detectCity(text) !== null || PROVINCE_REGEX.test(removeAccents(text));
}

// Giá trị lưu vào cột location (bắt buộc có): thành phố, hoặc "Việt Nam", hoặc "Remote"
function normalizeLocation(raw) {
  if (raw.source === "remotive") return "Remote";
  const text = [raw.city, cleanLocationText(raw.location)].filter(Boolean).join(" ");
  return detectCity(text) || "Việt Nam";
}

module.exports = { isVietnamJob, normalizeLocation, detectCity, cleanLocationText, isRemotiveLocationOk };
