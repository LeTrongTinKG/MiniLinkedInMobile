const { ApiError } = require("../../middleware/error");
const { decodeCursor, parseLimit } = require("../../utils/social/cursor");

const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const REACTION_TYPES = ["LIKE", "LOVE", "HAHA", "WOW", "SAD", "ANGRY"];

const bad = (message) => new ApiError(400, "VALIDATION_ERROR", message);

// id trên URL phải đúng dạng uuid, nếu không Postgres sẽ báo lỗi 500
function parseUuid(value, field = "id") {
  if (typeof value !== "string" || !UUID_RE.test(value)) throw bad(`${field} không hợp lệ`);
  return value.toLowerCase();
}

// Đọc ?cursor=&limit= từ query
function parsePaging(query) {
  return { cursor: decodeCursor(query.cursor), limit: parseLimit(query.limit) };
}

function parseReactionType(value) {
  const type = typeof value === "string" ? value.toUpperCase() : "";
  if (!REACTION_TYPES.includes(type)) {
    throw new ApiError(
      400,
      "INVALID_REACTION_TYPE",
      `type phải là một trong: ${REACTION_TYPES.join(", ")}`
    );
  }
  return type;
}

// Nội dung chữ: bắt buộc là chuỗi, cắt khoảng trắng 2 đầu
function parseText(value, field, maxLength) {
  if (typeof value !== "string") throw bad(`${field} phải là chuỗi`);
  const text = value.trim();
  if (text.length > maxLength) throw bad(`${field} tối đa ${maxLength} ký tự`);
  return text;
}

module.exports = { parseUuid, parsePaging, parseReactionType, parseText, bad, REACTION_TYPES };
