// Bước 8: phân tích lương. Kết quả luôn quy về THEO THÁNG, đơn vị VND hoặc USD. Không đoán: không rõ thì để trống.

const EMPTY = { salaryMin: null, salaryMax: null, salaryCurrency: null };
const MAX_INT = 2000000000; // cột salary là Int 32-bit

// Đổi "15.000.000" hoặc "1,500" hoặc "2.5" thành số
function parseNumber(text) {
  if (/^\d{1,3}([.,]\d{3})+$/.test(text)) return Number(text.replace(/[.,]/g, ""));
  return Number(text.replace(",", "."));
}

function unitMultiplier(unit) {
  if (!unit) return null;
  const u = unit.toLowerCase();
  if (u === "k") return 1000;
  if (u === "m" || u === "tr" || u === "triệu" || u === "million") return 1000000;
  return null;
}

// Lấy các số kèm đơn vị. Số đứng trước chưa có đơn vị thì mượn đơn vị của số sau ("15 – 25 triệu").
function extractAmounts(text) {
  const found = [...text.matchAll(/(\d[\d.,]*)\s*(k|tr|triệu|million|m)?(?![a-z])/gi)];
  const amounts = found.map((m) => ({ value: parseNumber(m[1]), mult: unitMultiplier(m[2]) }));
  for (let i = amounts.length - 2; i >= 0; i--) {
    if (amounts[i].mult === null && amounts[i + 1].mult !== null) amounts[i].mult = amounts[i + 1].mult;
  }
  return amounts.map((a) => Math.round(a.value * (a.mult || 1))).filter((n) => n > 0);
}

function detectCurrency(text) {
  if (/\$|usd|đô la/i.test(text)) return "USD";
  if (/₫|vnd|vnđ|triệu|\btr\b|\d\s*đ\b/i.test(text)) return "VND";
  return null;
}

// Trả "month" | "year" | null (null = theo giờ / theo task, bỏ trống)
function detectPeriod(text, currency, amounts) {
  if (/\/\s*(hour|hr|giờ)|per hour|hourly|theo giờ|per task|\/task|per day|\/day|\/ngày/i.test(text)) return null;
  if (/\/\s*(year|yr|năm)|per year|annual|yearly|\/\s*y\b|\bpa\b/i.test(text)) return "year";
  if (/\/\s*(month|tháng)|per month|monthly|tháng/i.test(text)) return "month";
  // Không ghi kỳ trả: USD từ 20.000 trở lên coi là lương năm, còn lại là tháng
  if (currency === "USD" && Math.max(...amounts) >= 20000) return "year";
  return "month";
}

function finish(min, max, currency, period) {
  const divide = period === "year" ? 12 : 1;
  const fix = (n) => (n === null ? null : Math.round(n / divide));
  const result = { salaryMin: fix(min), salaryMax: fix(max), salaryCurrency: currency };
  if ((result.salaryMin || 0) > MAX_INT || (result.salaryMax || 0) > MAX_INT) return EMPTY;
  return result;
}

// Dữ liệu có cấu trúc (JSearch): { min, max, currency, period: "MONTH"|"YEAR"|"HOUR"... }
function parseStructuredSalary(s) {
  if (!s || (!s.min && !s.max)) return null;
  const period = String(s.period || "").toUpperCase();
  const currency = s.currency === "VND" || s.currency === "USD" ? s.currency : null;
  if (!currency || (period !== "MONTH" && period !== "YEAR")) return EMPTY;
  return finish(s.min || null, s.max || null, currency, period === "YEAR" ? "year" : "month");
}

// Chuỗi lương dạng chữ
function parseSalaryText(raw) {
  const text = String(raw || "").trim();
  if (!text || /thỏa thuận|thoả thuận|negotiable|cạnh tranh|competitive/i.test(text)) return EMPTY;

  const currency = detectCurrency(text);
  const amounts = extractAmounts(text);
  if (!currency || amounts.length === 0) return EMPTY;

  const period = detectPeriod(text, currency, amounts);
  if (!period) return EMPTY;

  if (amounts.length === 1) {
    const only = amounts[0];
    if (/up to|tối đa|đến|lên tới|dưới/i.test(text)) return finish(null, only, currency, period);
    if (/từ|from|trên|over|\+/i.test(text)) return finish(only, null, currency, period);
    return finish(only, only, currency, period);
  }
  return finish(Math.min(amounts[0], amounts[1]), Math.max(amounts[0], amounts[1]), currency, period);
}

// Ưu tiên dữ liệu có cấu trúc, không có thì đọc chữ
function parseSalary(structured, text) {
  return parseStructuredSalary(structured) || parseSalaryText(text);
}

module.exports = { parseSalary, parseSalaryText, parseStructuredSalary };
