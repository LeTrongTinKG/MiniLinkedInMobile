const { parseUuid, parseText, bad } = require("./common.validation");

const MAX_POST_LENGTH = 5000;
const MAX_MEDIA = 10;

function parseMediaIds(value) {
  if (!Array.isArray(value)) throw bad("mediaIds phải là mảng");
  if (value.length > MAX_MEDIA) throw bad(`Tối đa ${MAX_MEDIA} ảnh mỗi bài`);
  const ids = value.map((id) => parseUuid(id, "mediaIds"));
  return [...new Set(ids)];
}

// POST /posts  {content, mediaIds}
function parseCreatePost(body = {}) {
  return {
    content: parseText(body.content ?? "", "content", MAX_POST_LENGTH),
    mediaIds: body.mediaIds === undefined ? [] : parseMediaIds(body.mediaIds),
  };
}

// PATCH /posts/:id  {content?, mediaIds?}  (trường nào không gửi thì giữ nguyên)
function parseUpdatePost(body = {}) {
  const changes = {};
  if (body.content !== undefined) changes.content = parseText(body.content, "content", MAX_POST_LENGTH);
  if (body.mediaIds !== undefined) changes.mediaIds = parseMediaIds(body.mediaIds);
  if (body.sharedPostId !== undefined) throw bad("Không được đổi bài gốc của bài chia sẻ");
  return changes;
}

// POST /posts/:id/shares  {content?}
function parseShare(body = {}) {
  return { content: parseText(body.content ?? "", "content", MAX_POST_LENGTH) };
}

module.exports = { parseCreatePost, parseUpdatePost, parseShare, MAX_POST_LENGTH };
