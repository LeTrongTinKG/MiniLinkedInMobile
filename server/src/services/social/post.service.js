// Nghiệp vụ bài viết: đăng, xem, sửa, xóa, lịch sử sửa.
const dbLib = require("../../lib/social/db");
const postRepo = require("../../repositories/social/post.repository");
const mediaRepo = require("../../repositories/social/media.repository");
const revisionRepo = require("../../repositories/social/revision.repository");
const { ApiError } = require("../../middleware/error");
const { buildPage } = require("../../utils/social/cursor");
const { toPostDtos } = require("./post-view.service");

const postNotFound = () => new ApiError(404, "POST_NOT_FOUND", "Bài viết không tồn tại");
const postEmpty = () => new ApiError(400, "POST_EMPTY", "Bài viết phải có nội dung hoặc ảnh");
const mediaNotFound = () => new ApiError(404, "MEDIA_NOT_FOUND", "Ảnh không tồn tại hoặc không phải của bạn");

// Kiểm tra mọi mediaId đều là ảnh của người dùng (và chưa gắn bài khác)
async function checkMedia(mediaIds, userId, postId, db) {
  const found = await mediaRepo.findUsableMedia(mediaIds, userId, postId, db);
  if (found.length !== mediaIds.length) throw mediaNotFound();
}

async function getPost(postId, viewerId) {
  const row = await postRepo.findPostById(postId, viewerId);
  if (!row || row.deletedAt) throw postNotFound();
  const [dto] = await toPostDtos([row], viewerId);
  return dto;
}

async function createPost({ userId, content, mediaIds }) {
  if (!content && mediaIds.length === 0) throw postEmpty();

  // Tạo bài + gắn ảnh trong cùng transaction: lỗi giữa chừng thì không để lại bài dở
  const created = await dbLib.withTransaction(async (client) => {
    await checkMedia(mediaIds, userId, null, client);
    const post = await postRepo.insertPost({ authorId: userId, content }, client);
    await mediaRepo.attachMedia(post.id, mediaIds, client);
    return post;
  });
  return getPost(created.id, userId);
}

// Trang bài viết (feed chung nếu authorId = null, hoặc bài của 1 người)
async function listPosts({ viewerId, authorId, cursor, limit }) {
  const rows = await postRepo.listPosts({ viewerId, authorId, cursor, limit });
  const page = buildPage(rows, limit);
  const items = await toPostDtos(page.items, viewerId);
  return { items, meta: page.meta };
}

async function updatePost({ userId, postId, changes }) {
  await dbLib.withTransaction(async (client) => {
    // 1. Khóa bài, kiểm tra tồn tại + đúng chủ bài TRƯỚC khi sửa
    const post = await postRepo.lockPost(postId, client);
    if (!post || post.deletedAt) throw postNotFound();
    if (post.authorId !== userId) {
      throw new ApiError(403, "NOT_POST_OWNER", "Bạn không phải tác giả bài viết này");
    }
    const isShare = Boolean(post.sharedPostId);
    if (isShare && changes.mediaIds !== undefined) {
      throw new ApiError(400, "VALIDATION_ERROR", "Bài chia sẻ không thể gắn ảnh");
    }

    // 2. Tính nội dung + ảnh sau khi sửa
    const oldMedia = await mediaRepo.listMediaByPostIds([postId], client);
    const oldIds = oldMedia.map((m) => m.id);
    const newIds = changes.mediaIds === undefined ? oldIds : changes.mediaIds;
    const newContent = changes.content === undefined ? post.content : changes.content;
    if (changes.mediaIds !== undefined) await checkMedia(newIds, userId, postId, client);
    if (!isShare && !newContent && newIds.length === 0) throw postEmpty();

    // 3. Lưu lại thay đổi
    const contentChanged = newContent !== post.content;
    const mediaChanged = newIds.join() !== oldIds.join();
    if (contentChanged) {
      await revisionRepo.insertRevision(postId, post.content, client); // lưu bản cũ
      await postRepo.updatePostContent(postId, newContent, client); // đồng thời set edited_at
    } else if (mediaChanged) {
      await postRepo.markPostEdited(postId, client);
    }
    if (mediaChanged) {
      await mediaRepo.detachMediaExcept(postId, newIds, client);
      await mediaRepo.attachMedia(postId, newIds, client);
    }
  });
  return getPost(postId, userId);
}

// Xóa mềm: chỉ đánh dấu deleted_at, dữ liệu vẫn còn trong DB
async function deletePost({ userId, postId }) {
  const post = await postRepo.findPostById(postId, userId);
  if (!post || post.deletedAt) throw postNotFound();
  if (post.authorId !== userId) {
    throw new ApiError(403, "NOT_POST_OWNER", "Bạn không phải tác giả bài viết này");
  }
  await postRepo.softDeletePost(postId);
  return { id: postId, deleted: true };
}

async function listRevisions({ viewerId, postId }) {
  await getPost(postId, viewerId); // bài không tồn tại thì báo 404
  return revisionRepo.listRevisions(postId);
}

module.exports = { getPost, createPost, listPosts, updatePost, deletePost, listRevisions };
