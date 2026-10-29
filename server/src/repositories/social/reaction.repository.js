// Cảm xúc cho bài (post) và bình luận (comment). Hai bảng giống nhau nên dùng chung hàm.
const { pool } = require("../../lib/social/db");

// Tên bảng/cột lấy từ danh sách cố định này, KHÔNG bao giờ lấy từ input người dùng
const KINDS = {
  post: { table: "social.post_reactions", col: "post_id" },
  comment: { table: "social.comment_reactions", col: "comment_id" },
};

// Thả mới hoặc đổi cảm xúc (đã có thì cập nhật)
async function upsertReaction(kind, targetId, userId, type, db = pool) {
  const { table, col } = KINDS[kind];
  await db.query(
    `INSERT INTO ${table} (${col}, user_id, type) VALUES ($1, $2, $3)
     ON CONFLICT (${col}, user_id) DO UPDATE SET type = EXCLUDED.type, updated_at = now()`,
    [targetId, userId, type]
  );
}

async function deleteReaction(kind, targetId, userId, db = pool) {
  const { table, col } = KINDS[kind];
  await db.query(`DELETE FROM ${table} WHERE ${col} = $1 AND user_id = $2`, [targetId, userId]);
}

// Đếm theo loại cho nhiều bài/bình luận một lượt -> [{targetId, type, count}]
async function countByTargets(kind, ids, db = pool) {
  if (ids.length === 0) return [];
  const { table, col } = KINDS[kind];
  const { rows } = await db.query(
    `SELECT ${col} AS "targetId", type, COUNT(*)::int AS count
     FROM ${table} WHERE ${col} = ANY($1::uuid[]) GROUP BY ${col}, type`,
    [ids]
  );
  return rows;
}

// Cảm xúc của 1 người cho nhiều đối tượng -> [{targetId, type}]
async function findMyReactions(kind, ids, userId, db = pool) {
  if (ids.length === 0) return [];
  const { table, col } = KINDS[kind];
  const { rows } = await db.query(
    `SELECT ${col} AS "targetId", type FROM ${table}
     WHERE ${col} = ANY($1::uuid[]) AND user_id = $2`,
    [ids, userId]
  );
  return rows;
}

// Danh sách người đã react bài (lọc theo loại nếu có), tối đa 100 người
async function listPostReactions(postId, type, db = pool) {
  const { rows } = await db.query(
    `SELECT r.type, r.created_at AS "createdAt",
            u.id AS "userId", u."fullName" AS "fullName", u."avatarUrl" AS "avatarUrl"
     FROM social.post_reactions r JOIN public.users u ON u.id = r.user_id
     WHERE r.post_id = $1 AND ($2::text IS NULL OR r.type = $2)
     ORDER BY r.created_at DESC, r.user_id
     LIMIT 100`,
    [postId, type || null]
  );
  return rows;
}

module.exports = { upsertReaction, deleteReaction, countByTargets, findMyReactions, listPostReactions };
