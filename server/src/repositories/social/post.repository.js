// SQL thuần cho bảng social.posts. Không có logic nghiệp vụ.
// Hàm nào cũng nhận `db` ở cuối (mặc định là pool) để test truyền db giả vào.
const { pool } = require("../../lib/social/db");

// Định dạng thời gian đủ micro-giây để làm cursor chính xác
const TS = `to_char(p.created_at AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS.US"Z"')`;

// Các cột chung khi đọc bài. $1 luôn là id người đang xem (để biết họ đã react gì).
const SELECT_POST = `
  SELECT p.id, p.content,
    p.author_id AS "authorId",
    p.shared_post_id AS "sharedPostId",
    p.edited_at AS "editedAt",
    p.deleted_at AS "deletedAt",
    p.created_at AS "createdAt",
    ${TS} AS "cursorTs",
    u."fullName" AS "authorName",
    u."avatarUrl" AS "authorAvatarUrl",
    (SELECT COUNT(*)::int FROM social.comments c
       WHERE c.post_id = p.id AND c.deleted_at IS NULL) AS "commentCount",
    (SELECT COUNT(*)::int FROM social.posts s
       WHERE s.shared_post_id = p.id AND s.deleted_at IS NULL) AS "shareCount",
    (SELECT r.type FROM social.post_reactions r
       WHERE r.post_id = p.id AND r.user_id = $1) AS "myReaction"
  FROM social.posts p
  JOIN public.users u ON u.id = p.author_id`;

async function insertPost({ authorId, content, sharedPostId }, db = pool) {
  const { rows } = await db.query(
    `INSERT INTO social.posts (author_id, content, shared_post_id)
     VALUES ($1, $2, $3) RETURNING id`,
    [authorId, content, sharedPostId || null]
  );
  return rows[0];
}

// Lấy 1 bài (kể cả bài đã xóa mềm, service tự quyết định)
async function findPostById(id, viewerId, db = pool) {
  const { rows } = await db.query(`${SELECT_POST} WHERE p.id = $2`, [viewerId, id]);
  return rows[0] || null;
}

async function findPostsByIds(ids, viewerId, db = pool) {
  if (ids.length === 0) return [];
  const { rows } = await db.query(`${SELECT_POST} WHERE p.id = ANY($2::uuid[])`, [viewerId, ids]);
  return rows;
}

// Feed / bài của 1 người: mới nhất trước. authorId = null là lấy của tất cả.
async function listPosts({ viewerId, authorId, cursor, limit }, db = pool) {
  const { rows } = await db.query(
    `${SELECT_POST}
     WHERE p.deleted_at IS NULL
       AND ($2::text IS NULL OR p.author_id = $2)
       AND ($3::timestamptz IS NULL OR (p.created_at, p.id) < ($3::timestamptz, $4::uuid))
     ORDER BY p.created_at DESC, p.id DESC
     LIMIT $5`,
    [viewerId, authorId || null, cursor?.createdAt || null, cursor?.id || null, limit + 1]
  );
  return rows;
}

// Khóa dòng bài trong transaction để 2 lần sửa cùng lúc không đè nhau
async function lockPost(id, db = pool) {
  const { rows } = await db.query(
    `SELECT id, author_id AS "authorId", content, shared_post_id AS "sharedPostId",
            deleted_at AS "deletedAt"
     FROM social.posts WHERE id = $1 FOR UPDATE`,
    [id]
  );
  return rows[0] || null;
}

// Chỉ đổi nội dung chữ, đồng thời đánh dấu đã chỉnh sửa
async function updatePostContent(id, content, db = pool) {
  await db.query(
    `UPDATE social.posts SET content = $2, edited_at = now(), updated_at = now() WHERE id = $1`,
    [id, content]
  );
}

// Chỉ đánh dấu đã chỉnh sửa (khi chỉ đổi ảnh)
async function markPostEdited(id, db = pool) {
  await db.query(`UPDATE social.posts SET edited_at = now(), updated_at = now() WHERE id = $1`, [id]);
}

async function softDeletePost(id, db = pool) {
  await db.query(
    `UPDATE social.posts SET deleted_at = now(), updated_at = now() WHERE id = $1`,
    [id]
  );
}

module.exports = {
  insertPost,
  findPostById,
  findPostsByIds,
  listPosts,
  lockPost,
  updatePostContent,
  markPostEdited,
  softDeletePost,
};
