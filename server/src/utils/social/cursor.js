// Cursor = "mốc" để lấy trang tiếp theo. Gồm thời gian tạo + id của dòng cuối trang trước.
// Dạng gửi cho client: base64 của chuỗi "2026-01-01T00:00:00.000000Z|<uuid>".
const { ApiError } = require("../../middleware/error");

const DEFAULT_LIMIT = 10;
const MAX_LIMIT = 30;
const ISO_RE = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{1,6})?Z$/;
const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

function invalidCursor() {
  return new ApiError(400, "INVALID_CURSOR", "Cursor không hợp lệ");
}

function encodeCursor(cursorTs, id) {
  return Buffer.from(`${cursorTs}|${id}`, "utf8").toString("base64url");
}

// Giải mã cursor từ query string. Không có cursor -> null (lấy trang đầu).
function decodeCursor(value) {
  if (value === undefined || value === null || value === "") return null;
  if (typeof value !== "string" || value.length > 200) throw invalidCursor();

  const text = Buffer.from(value, "base64url").toString("utf8");
  const parts = text.split("|");
  if (parts.length !== 2) throw invalidCursor();

  const [createdAt, id] = parts;
  // Kiểm tra đúng định dạng thì mới đưa vào SQL (SQL vẫn dùng tham số $1, $2)
  if (!ISO_RE.test(createdAt) || !UUID_RE.test(id)) throw invalidCursor();
  return { createdAt, id };
}

function parseLimit(value) {
  if (value === undefined || value === "") return DEFAULT_LIMIT;
  const n = Number(value);
  if (!Number.isInteger(n) || n < 1) {
    throw new ApiError(400, "VALIDATION_ERROR", "limit phải là số nguyên dương");
  }
  return Math.min(n, MAX_LIMIT);
}

// Repository lấy limit+1 dòng. Dư 1 dòng nghĩa là còn trang sau.
function buildPage(rows, limit) {
  const hasMore = rows.length > limit;
  const items = hasMore ? rows.slice(0, limit) : rows;
  const last = items[items.length - 1];
  const nextCursor = hasMore && last ? encodeCursor(last.cursorTs, last.id) : null;
  return { items, meta: { nextCursor, hasMore } };
}

module.exports = { encodeCursor, decodeCursor, parseLimit, buildPage, DEFAULT_LIMIT, MAX_LIMIT };
