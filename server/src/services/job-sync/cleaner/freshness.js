// Bước 1: job còn mới không (đăng trong vòng 30 ngày)
const DAY_MS = 24 * 60 * 60 * 1000;

// Đổi chữ kiểu "3 ngày trước", "2 weeks ago" thành số ngày
function relativeTextToDays(text) {
  const m = /(\d+)\s*\+?\s*(giờ|hours?|h\b|ngày|days?|tuần|weeks?|tháng|months?)/i.exec(text || "");
  if (!m) return null;
  const n = Number(m[1]);
  const unit = m[2].toLowerCase();
  if (unit === "giờ" || unit.startsWith("hour") || unit === "h") return 0;
  if (unit === "ngày" || unit.startsWith("day")) return n;
  if (unit === "tuần" || unit.startsWith("week")) return n * 7;
  return n * 30;
}

// Một số tin ghi ngay trong mô tả: "Ngày đăng: 11/12/2023" (ngày/tháng/năm)
function postedDateFromDescription(description) {
  const m = /(?:ngày đăng|posted(?: on)?)\s*[:\-]?\s*(\d{1,2})[\/.-](\d{1,2})[\/.-](\d{4})/i.exec(description || "");
  if (!m) return null;
  const date = new Date(Date.UTC(Number(m[3]), Number(m[2]) - 1, Number(m[1])));
  return Number.isNaN(date.getTime()) ? null : date;
}

// Trả về Date ngày đăng, hoặc null nếu nguồn không cho biết
function getPostedDate(raw, now = new Date()) {
  if (raw.postedAt) {
    const date = new Date(raw.postedAt);
    if (!Number.isNaN(date.getTime())) return date;
  }
  const days = relativeTextToDays(raw.postedText);
  if (days !== null) return new Date(now.getTime() - days * DAY_MS);
  return postedDateFromDescription(raw.descriptionRaw);
}

// true nếu đăng quá maxAgeDays ngày. Không biết ngày đăng thì giữ lại (đã có bước đóng job sau 14 ngày không thấy).
function isTooOld(raw, now = new Date(), maxAgeDays = 30) {
  const posted = getPostedDate(raw, now);
  if (!posted) return false;
  return now.getTime() - posted.getTime() > maxAgeDays * DAY_MS;
}

module.exports = { getPostedDate, isTooOld, relativeTextToDays, postedDateFromDescription };
