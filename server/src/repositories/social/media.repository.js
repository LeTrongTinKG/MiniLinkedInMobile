const { pool } = require("../../lib/social/db");

const MEDIA_COLUMNS = `id, post_id AS "postId", url, thumbnail_url AS "thumbnailUrl",
  storage_path AS "storagePath", width, height, position`;

// Ảnh mới upload: chưa gắn bài (post_id = NULL)
async function insertMedia(m, db = pool) {
  const { rows } = await db.query(
    `INSERT INTO social.post_media
       (uploader_id, url, thumbnail_url, storage_path, width, height)
     VALUES ($1, $2, $3, $4, $5, $6)
     RETURNING ${MEDIA_COLUMNS}`,
    [m.uploaderId, m.url, m.thumbnailUrl, m.storagePath, m.width, m.height]
  );
  return rows[0];
}

// Ảnh của người này mà chưa gắn bài nào, hoặc đang gắn đúng bài postId (khi sửa bài)
async function findUsableMedia(ids, uploaderId, postId, db = pool) {
  if (ids.length === 0) return [];
  const { rows } = await db.query(
    `SELECT ${MEDIA_COLUMNS} FROM social.post_media
     WHERE id = ANY($1::uuid[]) AND uploader_id = $2
       AND (post_id IS NULL OR post_id = $3::uuid)`,
    [ids, uploaderId, postId || null]
  );
  return rows;
}

// Gắn ảnh vào bài, vị trí theo thứ tự trong mảng ids
async function attachMedia(postId, ids, db = pool) {
  if (ids.length === 0) return;
  await db.query(
    `UPDATE social.post_media m SET post_id = $1, position = (t.pos - 1)::int
     FROM unnest($2::uuid[]) WITH ORDINALITY AS t(id, pos)
     WHERE m.id = t.id`,
    [postId, ids]
  );
}

// Gỡ khỏi bài những ảnh không còn nằm trong danh sách mới (thành ảnh rác, sẽ bị dọn)
async function detachMediaExcept(postId, keepIds, db = pool) {
  await db.query(
    `UPDATE social.post_media SET post_id = NULL
     WHERE post_id = $1 AND NOT (id = ANY($2::uuid[]))`,
    [postId, keepIds]
  );
}

async function listMediaByPostIds(postIds, db = pool) {
  if (postIds.length === 0) return [];
  const { rows } = await db.query(
    `SELECT ${MEDIA_COLUMNS} FROM social.post_media
     WHERE post_id = ANY($1::uuid[]) ORDER BY position, created_at`,
    [postIds]
  );
  return rows;
}

// Ảnh rác: upload xong mà quá N giờ vẫn chưa gắn bài nào
async function findOrphanMedia(olderThanHours = 24, db = pool) {
  const { rows } = await db.query(
    `SELECT id, storage_path AS "storagePath" FROM social.post_media
     WHERE post_id IS NULL AND created_at < now() - ($1::int * interval '1 hour')
     LIMIT 500`,
    [olderThanHours]
  );
  return rows;
}

async function deleteMediaByIds(ids, db = pool) {
  if (ids.length === 0) return 0;
  const result = await db.query(`DELETE FROM social.post_media WHERE id = ANY($1::uuid[])`, [ids]);
  return result.rowCount;
}

module.exports = {
  insertMedia,
  findUsableMedia,
  attachMedia,
  detachMediaExcept,
  listMediaByPostIds,
  findOrphanMedia,
  deleteMediaByIds,
};
