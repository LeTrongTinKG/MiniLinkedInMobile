// Biến các dòng SQL của bài viết thành JSON trả cho app
// (gắn thêm ảnh, cảm xúc, bài gốc nếu là bài chia sẻ).
const postRepo = require("../../repositories/social/post.repository");
const mediaRepo = require("../../repositories/social/media.repository");
const { buildSummary, loadCountRows } = require("./reaction-summary");

const DELETED_SHARED_MESSAGE = "Bài viết gốc không còn tồn tại";

function toMediaDto(m) {
  return {
    id: m.id,
    url: m.url,
    thumbnailUrl: m.thumbnailUrl,
    width: m.width,
    height: m.height,
    position: m.position,
  };
}

function toAuthorDto(row) {
  return { id: row.authorId, fullName: row.authorName, avatarUrl: row.authorAvatarUrl };
}

// Gom mảng thành Map theo khóa, ví dụ gom ảnh theo postId
function groupBy(list, keyName) {
  const map = new Map();
  list.forEach((item) => {
    const key = item[keyName];
    if (!map.has(key)) map.set(key, []);
    map.get(key).push(item);
  });
  return map;
}

// Chuyển danh sách dòng bài -> danh sách JSON. Mỗi loại dữ liệu chỉ truy vấn 1 lần cho cả danh sách.
async function toPostDtos(rows, viewerId) {
  if (rows.length === 0) return [];

  // 1. Bài gốc của các bài chia sẻ (có thể đã bị xóa mềm)
  const sharedIds = [...new Set(rows.map((r) => r.sharedPostId).filter(Boolean))];
  const sharedRows = await postRepo.findPostsByIds(sharedIds, viewerId);
  const aliveShared = sharedRows.filter((r) => !r.deletedAt);

  // 2. Ảnh + cảm xúc cho tất cả bài (bài chính và bài gốc)
  const allRows = [...rows, ...aliveShared];
  const allIds = allRows.map((r) => r.id);
  const mediaByPost = groupBy(await mediaRepo.listMediaByPostIds(allIds), "postId");
  const countsByPost = await loadCountRows("post", allIds);

  // 3. Hàm dựng JSON của 1 bài (không có sharedPost bên trong)
  const baseDto = (row) => ({
    id: row.id,
    content: row.content,
    author: toAuthorDto(row),
    media: (mediaByPost.get(row.id) || []).map(toMediaDto),
    reactionSummary: buildSummary(countsByPost.get(row.id) || [], row.myReaction),
    commentCount: row.commentCount,
    shareCount: row.shareCount,
    isMine: row.authorId === viewerId,
    editedAt: row.editedAt,
    createdAt: row.createdAt,
  });

  // 4. Ghép bài gốc vào bài chia sẻ
  const sharedById = new Map(aliveShared.map((r) => [r.id, r]));
  return rows.map((row) => {
    const dto = baseDto(row);
    dto.sharedPost = null;
    if (row.sharedPostId) {
      const original = sharedById.get(row.sharedPostId);
      dto.sharedPost = original
        ? baseDto(original)
        : { id: row.sharedPostId, isDeleted: true, message: DELETED_SHARED_MESSAGE };
    }
    return dto;
  });
}

module.exports = { toPostDtos, toAuthorDto, DELETED_SHARED_MESSAGE };
