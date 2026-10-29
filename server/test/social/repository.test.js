// Repository nhận db giả: kiểm tra SQL luôn tham số hóa ($1, $2...) và giá trị truyền đúng chỗ.
const assert = require("node:assert/strict");
const test = require("node:test");
const postRepo = require("../../src/repositories/social/post.repository");
const commentRepo = require("../../src/repositories/social/comment.repository");
const { withTransaction } = require("../../src/lib/social/db");

function fakeDb(rows = []) {
  const calls = [];
  return {
    calls,
    query: async (sql, params) => {
      calls.push({ sql, params });
      return { rows, rowCount: rows.length };
    },
  };
}

test("insertPost: nội dung người dùng đi qua tham số, không nối vào SQL", async () => {
  const db = fakeDb([{ id: "p1" }]);
  const evil = "'); DROP TABLE social.posts; --";
  const row = await postRepo.insertPost({ authorId: "u1", content: evil }, db);

  assert.equal(row.id, "p1");
  assert.ok(!db.calls[0].sql.includes("DROP TABLE"));
  assert.deepEqual(db.calls[0].params, ["u1", evil, null]);
});

test("listPosts: lấy limit + 1 dòng và truyền cursor bằng tham số", async () => {
  const db = fakeDb([]);
  await postRepo.listPosts(
    { viewerId: "u1", authorId: null, cursor: { createdAt: "2026-01-01T00:00:00.000000Z", id: "x" }, limit: 10 },
    db
  );
  const { params } = db.calls[0];
  assert.deepEqual(params, ["u1", null, "2026-01-01T00:00:00.000000Z", "x", 11]);
});

test("findCommentById: không thấy => null", async () => {
  assert.equal(await commentRepo.findCommentById("c1", "u1", fakeDb([])), null);
});

test("withTransaction là hàm (dùng cho thao tác nhiều bước)", () => {
  assert.equal(typeof withTransaction, "function");
});
