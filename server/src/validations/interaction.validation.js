const { ApiError } = require("../middleware/error");

const REACTION_TYPES = ["LIKE", "CELEBRATE", "SUPPORT", "LOVE", "INSIGHTFUL", "FUNNY"];
const MAX_IDS = 50;
const MAX_COMMENT = 1000;

const bad = (message) => new ApiError(400, "VALIDATION_ERROR", message);

// Hiện chỉ có tin tuyển dụng (job) để tương tác
function parseTargetType(value) {
  if (String(value || "").toLowerCase() !== "job") throw bad('targetType phải là "job"');
}

function parseId(value, field = "targetId") {
  const id = String(value || "").trim();
  if (!id || id.length > 64) throw bad(`${field} không hợp lệ`);
  return id;
}

function parseReactionType(value) {
  const t = String(value || "").toUpperCase();
  if (!REACTION_TYPES.includes(t)) {
    throw bad(`type phải là một trong: ${REACTION_TYPES.join(", ")}`);
  }
  return t;
}

function parseIds(value) {
  const ids = [
    ...new Set(
      String(value || "")
        .split(",")
        .map((s) => s.trim())
        .filter(Boolean),
    ),
  ];
  if (ids.length === 0) throw bad("ids không được rỗng");
  if (ids.length > MAX_IDS) throw bad(`ids tối đa ${MAX_IDS} phần tử`);
  ids.forEach((id) => parseId(id, "ids"));
  return ids;
}

function parseContent(value) {
  const content = String(value || "").trim();
  if (!content) throw bad("Bình luận không được rỗng");
  if (content.length > MAX_COMMENT) throw bad(`Bình luận tối đa ${MAX_COMMENT} ký tự`);
  return content;
}

function parsePage(query) {
  const page = Math.max(1, parseInt(query.page, 10) || 1);
  const limit = Math.min(50, Math.max(1, parseInt(query.limit, 10) || 20));
  return { page, limit };
}

module.exports = {
  parseTargetType,
  parseId,
  parseReactionType,
  parseIds,
  parseContent,
  parsePage,
};
