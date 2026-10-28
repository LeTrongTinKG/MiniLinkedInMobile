const { parseUuid, parseText, bad } = require("./common.validation");

const MAX_COMMENT_LENGTH = 1000;

function parseContent(value) {
  const content = parseText(value, "content", MAX_COMMENT_LENGTH);
  if (!content) throw bad("Nội dung bình luận không được để trống");
  return content;
}

// POST /posts/:id/comments  {content, parentId?}
function parseCreateComment(body = {}) {
  return {
    content: parseContent(body.content),
    parentId:
      body.parentId === undefined || body.parentId === null
        ? null
        : parseUuid(body.parentId, "parentId"),
  };
}

// PATCH /comments/:id  {content}
function parseUpdateComment(body = {}) {
  return { content: parseContent(body.content) };
}

module.exports = { parseCreateComment, parseUpdateComment };
