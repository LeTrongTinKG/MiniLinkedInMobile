const { pool } = require("../../lib/social/db");

// Lưu nội dung bài TRƯỚC khi sửa
async function insertRevision(postId, contentBefore, db = pool) {
  await db.query(
    `INSERT INTO social.post_revisions (post_id, content_before) VALUES ($1, $2)`,
    [postId, contentBefore]
  );
}

async function listRevisions(postId, db = pool) {
  const { rows } = await db.query(
    `SELECT id, content_before AS "contentBefore", edited_at AS "editedAt"
     FROM social.post_revisions WHERE post_id = $1
     ORDER BY edited_at DESC, id DESC`,
    [postId]
  );
  return rows;
}

module.exports = { insertRevision, listRevisions };
