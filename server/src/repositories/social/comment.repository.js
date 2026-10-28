const { pool } = require("../../lib/social/db");

const TS = `to_char(c.created_at AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS.US"Z"')`;

// $1 = id người đang xem
const SELECT_COMMENT = `
  SELECT c.id, c.post_id AS "postId", c.parent_id AS "parentId", c.content,
    c.author_id AS "authorId",
    c.edited_at AS "editedAt", c.created_at AS "createdAt",
    c.deleted_at AS "deletedAt",
    ${TS} AS "cursorTs",
    u."fullName" AS "authorName", u."avatarUrl" AS "authorAvatarUrl",
    (SELECT p.author_id FROM social.posts p WHERE p.id = c.post_id) AS "postAuthorId",
    (SELECT COUNT(*)::int FROM social.comments r
       WHERE r.parent_id = c.id AND r.deleted_at IS NULL) AS "replyCount",
    (SELECT x.type FROM social.comment_reactions x
       WHERE x.comment_id = c.id AND x.user_id = $1) AS "myReaction"
  FROM social.comments c
  JOIN public.users u ON u.id = c.author_id`;

async function insertComment({ postId, authorId, parentId, content }, db = pool) {
  const { rows } = await db.query(
    `INSERT INTO social.comments (post_id, author_id, parent_id, content)
     VALUES ($1, $2, $3, $4) RETURNING id`,
    [postId, authorId, parentId || null, content]
  );
  return rows[0];
}

// Lấy 1 bình luận (kể cả đã xóa mềm, service tự quyết định)
async function findCommentById(id, viewerId, db = pool) {
  const { rows } = await db.query(`${SELECT_COMMENT} WHERE c.id = $2`, [viewerId, id]);
  return rows[0] || null;
}

// Bình luận gốc của 1 bài, cũ trước mới sau (đọc từ trên xuống)
async function listComments({ postId, viewerId, cursor, limit }, db = pool) {
  const { rows } = await db.query(
    `${SELECT_COMMENT}
     WHERE c.post_id = $2 AND c.parent_id IS NULL AND c.deleted_at IS NULL
       AND ($3::timestamptz IS NULL OR (c.created_at, c.id) > ($3::timestamptz, $4::uuid))
     ORDER BY c.created_at ASC, c.id ASC
     LIMIT $5`,
    [viewerId, postId, cursor?.createdAt || null, cursor?.id || null, limit + 1]
  );
  return rows;
}

// Các trả lời của 1 bình luận gốc
async function listReplies({ parentId, viewerId, cursor, limit }, db = pool) {
  const { rows } = await db.query(
    `${SELECT_COMMENT}
     WHERE c.parent_id = $2 AND c.deleted_at IS NULL
       AND ($3::timestamptz IS NULL OR (c.created_at, c.id) > ($3::timestamptz, $4::uuid))
     ORDER BY c.created_at ASC, c.id ASC
     LIMIT $5`,
    [viewerId, parentId, cursor?.createdAt || null, cursor?.id || null, limit + 1]
  );
  return rows;
}

async function updateCommentContent(id, content, db = pool) {
  await db.query(
    `UPDATE social.comments SET content = $2, edited_at = now(), updated_at = now() WHERE id = $1`,
    [id, content]
  );
}

async function softDeleteComment(id, db = pool) {
  await db.query(
    `UPDATE social.comments SET deleted_at = now(), updated_at = now() WHERE id = $1`,
    [id]
  );
}

module.exports = {
  insertComment,
  findCommentById,
  listComments,
  listReplies,
  updateCommentContent,
  softDeleteComment,
};
