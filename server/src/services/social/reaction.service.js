// Thả / đổi / bỏ cảm xúc cho bài và bình luận.
const reactionRepo = require("../../repositories/social/reaction.repository");
const postRepo = require("../../repositories/social/post.repository");
const { ApiError } = require("../../middleware/error");
const { loadOneSummary } = require("./reaction-summary");
const commentService = require("./comment.service");

async function assertPostExists(postId, userId) {
  const post = await postRepo.findPostById(postId, userId);
  if (!post || post.deletedAt) throw new ApiError(404, "POST_NOT_FOUND", "Bài viết không tồn tại");
}

async function setPostReaction({ userId, postId, type }) {
  await assertPostExists(postId, userId);
  await reactionRepo.upsertReaction("post", postId, userId, type);
  return loadOneSummary("post", postId, userId);
}

async function removePostReaction({ userId, postId }) {
  await assertPostExists(postId, userId);
  await reactionRepo.deleteReaction("post", postId, userId);
  return loadOneSummary("post", postId, userId);
}

// Danh sách người đã react (có thể lọc theo loại)
async function listPostReactions({ userId, postId, type }) {
  await assertPostExists(postId, userId);
  const users = await reactionRepo.listPostReactions(postId, type);
  return users.map((r) => ({
    type: r.type,
    createdAt: r.createdAt,
    user: { id: r.userId, fullName: r.fullName, avatarUrl: r.avatarUrl },
  }));
}

async function setCommentReaction({ userId, commentId, type }) {
  await commentService.getAliveComment(commentId, userId);
  await reactionRepo.upsertReaction("comment", commentId, userId, type);
  return loadOneSummary("comment", commentId, userId);
}

async function removeCommentReaction({ userId, commentId }) {
  await commentService.getAliveComment(commentId, userId);
  await reactionRepo.deleteReaction("comment", commentId, userId);
  return loadOneSummary("comment", commentId, userId);
}

module.exports = {
  setPostReaction,
  removePostReaction,
  listPostReactions,
  setCommentReaction,
  removeCommentReaction,
};
