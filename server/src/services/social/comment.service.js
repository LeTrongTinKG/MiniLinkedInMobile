// Nghiệp vụ bình luận + trả lời (tối đa 2 cấp).
const commentRepo = require("../../repositories/social/comment.repository");
const postRepo = require("../../repositories/social/post.repository");
const { ApiError } = require("../../middleware/error");
const { buildPage } = require("../../utils/social/cursor");
const { buildSummary, loadCountRows } = require("./reaction-summary");
const { toAuthorDto } = require("./post-view.service");

const postNotFound = () => new ApiError(404, "POST_NOT_FOUND", "Bài viết không tồn tại");
const commentNotFound = () => new ApiError(404, "COMMENT_NOT_FOUND", "Bình luận không tồn tại");

async function assertPostExists(postId, viewerId) {
  const post = await postRepo.findPostById(postId, viewerId);
  if (!post || post.deletedAt) throw postNotFound();
}

// Lấy bình luận còn sống, không có thì báo 404
async function getAliveComment(commentId, viewerId) {
  const row = await commentRepo.findCommentById(commentId, viewerId);
  if (!row || row.deletedAt) throw commentNotFound();
  return row;
}

async function toCommentDtos(rows, viewerId) {
  const countsById = await loadCountRows("comment", rows.map((r) => r.id));
  return rows.map((r) => ({
    id: r.id,
    postId: r.postId,
    parentId: r.parentId,
    content: r.content,
    author: toAuthorDto(r),
    replyCount: r.replyCount,
    reactionSummary: buildSummary(countsById.get(r.id) || [], r.myReaction),
    isMine: r.authorId === viewerId,
    editedAt: r.editedAt,
    createdAt: r.createdAt,
  }));
}

async function createComment({ userId, postId, content, parentId }) {
  await assertPostExists(postId, userId);

  // Trả lời vào một trả lời -> gắn về bình luận gốc (chỉ có 2 cấp, không báo lỗi)
  let realParentId = null;
  if (parentId) {
    const parent = await getAliveComment(parentId, userId);
    if (parent.postId !== postId) throw commentNotFound();
    realParentId = parent.parentId || parent.id;
  }

  const created = await commentRepo.insertComment({
    postId,
    authorId: userId,
    parentId: realParentId,
    content,
  });
  const row = await commentRepo.findCommentById(created.id, userId);
  const [dto] = await toCommentDtos([row], userId);
  return dto;
}

async function listComments({ viewerId, postId, cursor, limit }) {
  await assertPostExists(postId, viewerId);
  const rows = await commentRepo.listComments({ postId, viewerId, cursor, limit });
  const page = buildPage(rows, limit);
  return { items: await toCommentDtos(page.items, viewerId), meta: page.meta };
}

async function listReplies({ viewerId, commentId, cursor, limit }) {
  await getAliveComment(commentId, viewerId);
  const rows = await commentRepo.listReplies({ parentId: commentId, viewerId, cursor, limit });
  const page = buildPage(rows, limit);
  return { items: await toCommentDtos(page.items, viewerId), meta: page.meta };
}

// Chỉ người viết mới được sửa (không lưu lịch sử)
async function updateComment({ userId, commentId, content }) {
  const comment = await getAliveComment(commentId, userId);
  if (comment.authorId !== userId) {
    throw new ApiError(403, "NOT_COMMENT_OWNER", "Bạn không phải người viết bình luận này");
  }
  await commentRepo.updateCommentContent(commentId, content);
  const row = await commentRepo.findCommentById(commentId, userId);
  const [dto] = await toCommentDtos([row], userId);
  return dto;
}

// Người viết HOẶC chủ bài được xóa
async function deleteComment({ userId, commentId }) {
  const comment = await getAliveComment(commentId, userId);
  const isWriter = comment.authorId === userId;
  const isPostOwner = comment.postAuthorId === userId;
  if (!isWriter && !isPostOwner) {
    throw new ApiError(403, "NOT_COMMENT_OWNER", "Bạn không có quyền xóa bình luận này");
  }
  await commentRepo.softDeleteComment(commentId);
  return { id: commentId, deleted: true };
}

module.exports = {
  createComment,
  listComments,
  listReplies,
  updateComment,
  deleteComment,
  getAliveComment,
};
