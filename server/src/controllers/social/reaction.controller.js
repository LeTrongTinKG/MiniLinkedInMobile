const { asyncHandler } = require("../../middleware/error");
const { sendSuccess } = require("../response");
const reactionService = require("../../services/social/reaction.service");
const { parseUuid, parseReactionType } = require("../../validations/social/common.validation");

const setPostReaction = asyncHandler(async (req, res) => {
  const summary = await reactionService.setPostReaction({
    userId: req.user.userId,
    postId: parseUuid(req.params.postId, "postId"),
    type: parseReactionType(req.body?.type),
  });
  return sendSuccess(res, summary);
});

const removePostReaction = asyncHandler(async (req, res) => {
  const summary = await reactionService.removePostReaction({
    userId: req.user.userId,
    postId: parseUuid(req.params.postId, "postId"),
  });
  return sendSuccess(res, summary);
});

const listPostReactions = asyncHandler(async (req, res) => {
  const type = req.query.type === undefined ? null : parseReactionType(req.query.type);
  const users = await reactionService.listPostReactions({
    userId: req.user.userId,
    postId: parseUuid(req.params.postId, "postId"),
    type,
  });
  return sendSuccess(res, users);
});

const setCommentReaction = asyncHandler(async (req, res) => {
  const summary = await reactionService.setCommentReaction({
    userId: req.user.userId,
    commentId: parseUuid(req.params.commentId, "commentId"),
    type: parseReactionType(req.body?.type),
  });
  return sendSuccess(res, summary);
});

const removeCommentReaction = asyncHandler(async (req, res) => {
  const summary = await reactionService.removeCommentReaction({
    userId: req.user.userId,
    commentId: parseUuid(req.params.commentId, "commentId"),
  });
  return sendSuccess(res, summary);
});

module.exports = {
  setPostReaction,
  removePostReaction,
  listPostReactions,
  setCommentReaction,
  removeCommentReaction,
};
