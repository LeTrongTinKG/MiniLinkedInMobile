const { asyncHandler } = require("../../middleware/error");
const { sendSuccess } = require("../response");
const commentService = require("../../services/social/comment.service");
const { parseUuid, parsePaging } = require("../../validations/social/common.validation");
const {
  parseCreateComment,
  parseUpdateComment,
} = require("../../validations/social/comment.validation");

const listComments = asyncHandler(async (req, res) => {
  const { cursor, limit } = parsePaging(req.query);
  const page = await commentService.listComments({
    viewerId: req.user.userId,
    postId: parseUuid(req.params.postId, "postId"),
    cursor,
    limit,
  });
  return sendSuccess(res, page.items, 200, page.meta);
});

const listReplies = asyncHandler(async (req, res) => {
  const { cursor, limit } = parsePaging(req.query);
  const page = await commentService.listReplies({
    viewerId: req.user.userId,
    commentId: parseUuid(req.params.commentId, "commentId"),
    cursor,
    limit,
  });
  return sendSuccess(res, page.items, 200, page.meta);
});

const createComment = asyncHandler(async (req, res) => {
  const { content, parentId } = parseCreateComment(req.body);
  const comment = await commentService.createComment({
    userId: req.user.userId,
    postId: parseUuid(req.params.postId, "postId"),
    content,
    parentId,
  });
  return sendSuccess(res, comment, 201);
});

const updateComment = asyncHandler(async (req, res) => {
  const { content } = parseUpdateComment(req.body);
  const comment = await commentService.updateComment({
    userId: req.user.userId,
    commentId: parseUuid(req.params.commentId, "commentId"),
    content,
  });
  return sendSuccess(res, comment);
});

const deleteComment = asyncHandler(async (req, res) => {
  const result = await commentService.deleteComment({
    userId: req.user.userId,
    commentId: parseUuid(req.params.commentId, "commentId"),
  });
  return sendSuccess(res, result);
});

module.exports = { listComments, listReplies, createComment, updateComment, deleteComment };
