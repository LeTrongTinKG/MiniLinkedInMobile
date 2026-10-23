const interactionService = require("../services/interaction.service");
const v = require("../validations/interaction.validation");
const { sendSuccess } = require("./response");
const { asyncHandler } = require("../middleware/error");

/**
 * Controller cảm xúc + bình luận: validate input, gọi Service, trả response.
 * API nhận targetType + targetId; hiện targetType chỉ có "job" (targetId = jobId).
 */
const setReaction = asyncHandler(async (req, res) => {
  const body = req.body || {};
  v.parseTargetType(body.targetType);
  const jobId = v.parseId(body.targetId);
  const type = v.parseReactionType(body.type);
  return sendSuccess(res, await interactionService.setReaction(req.user.userId, jobId, type));
});

const removeReaction = asyncHandler(async (req, res) => {
  v.parseTargetType(req.query.targetType);
  const jobId = v.parseId(req.query.targetId);
  return sendSuccess(res, await interactionService.removeReaction(req.user.userId, jobId));
});

const getSummary = asyncHandler(async (req, res) => {
  v.parseTargetType(req.query.targetType);
  const ids = v.parseIds(req.query.ids);
  return sendSuccess(res, await interactionService.getSummaries(req.user.userId, ids));
});

const listComments = asyncHandler(async (req, res) => {
  v.parseTargetType(req.query.targetType);
  const jobId = v.parseId(req.query.targetId);
  const { items, meta } = await interactionService.listComments(
    req.user.userId,
    jobId,
    v.parsePage(req.query),
  );
  return sendSuccess(res, items, 200, meta);
});

const createComment = asyncHandler(async (req, res) => {
  const body = req.body || {};
  v.parseTargetType(body.targetType);
  const jobId = v.parseId(body.targetId);
  const content = v.parseContent(body.content);
  return sendSuccess(
    res,
    await interactionService.createComment(req.user.userId, jobId, content),
    201,
  );
});

const deleteComment = asyncHandler(async (req, res) => {
  const id = v.parseId(req.params.id, "id");
  return sendSuccess(res, await interactionService.deleteComment(req.user.userId, id));
});

module.exports = {
  setReaction,
  removeReaction,
  getSummary,
  listComments,
  createComment,
  deleteComment,
};
