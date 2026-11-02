// Cùng hạn mức trích skill của Atom: 3 lần thành công mỗi tháng, tính theo giờ Việt Nam.
// Lượt thất bại không tính (ALG-05). Đổi số này là một quyết định mới, không có bảng cài đặt.
const SCAN_LIMIT = 3;

function monthWindow(now = new Date()) {
  const parts = new Intl.DateTimeFormat("en-US", {
    timeZone: "Asia/Ho_Chi_Minh",
    year: "numeric",
    month: "2-digit",
  }).formatToParts(now);
  const year = parts.find((part) => part.type === "year").value;
  const month = parts.find((part) => part.type === "month").value;
  const start = new Date(`${year}-${month}-01T00:00:00+07:00`);
  const nextMonth = month === "12" ? 1 : Number(month) + 1;
  const nextYear = month === "12" ? Number(year) + 1 : Number(year);
  return {
    start,
    resetsAt: new Date(`${nextYear}-${String(nextMonth).padStart(2, "0")}-01T00:00:00+07:00`),
  };
}

module.exports = { SCAN_LIMIT, monthWindow };
