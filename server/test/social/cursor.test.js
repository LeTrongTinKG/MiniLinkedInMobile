const assert = require("node:assert/strict");
const test = require("node:test");
const { dispatch } = require("../helpers");
const { encodeCursor, decodeCursor, buildPage } = require("../../src/utils/social/cursor");
const postController = require("../../src/controllers/social/post.controller");

const ID = "11111111-1111-4111-8111-111111111111";
const TS = "2026-01-01T10:20:30.123456Z";

test("cursor mã hóa rồi giải mã ra đúng giá trị", () => {
  const cursor = decodeCursor(encodeCursor(TS, ID));
  assert.deepEqual(cursor, { createdAt: TS, id: ID });
});

test("không có cursor => null (trang đầu)", () => {
  assert.equal(decodeCursor(undefined), null);
  assert.equal(decodeCursor(""), null);
});

test("cursor bậy => 400 INVALID_CURSOR", () => {
  const bad = [
    "khong-phai-base64!!",
    Buffer.from("abc").toString("base64"),
    Buffer.from(`${TS}|khong-phai-uuid`).toString("base64"),
    Buffer.from(`'; DROP TABLE x;--|${ID}`).toString("base64"),
    "a".repeat(500),
  ];
  for (const value of bad) {
    assert.throws(
      () => decodeCursor(value),
      (err) => err.statusCode === 400 && err.code === "INVALID_CURSOR"
    );
  }
});

test("GET /posts với cursor lỗi => response 400", async () => {
  const req = { user: { userId: "u1" }, query: { cursor: "bay-ba" }, params: {}, body: {} };
  const res = await dispatch(postController.listFeed, req);
  assert.equal(res.statusCode, 400);
  assert.equal(res.body.error.code, "INVALID_CURSOR");
});

test("buildPage: dư 1 dòng => hasMore và có nextCursor", () => {
  const rows = [1, 2, 3].map((n) => ({ id: ID, cursorTs: TS, n }));
  const page = buildPage(rows, 2);
  assert.equal(page.items.length, 2);
  assert.equal(page.meta.hasMore, true);
  assert.ok(page.meta.nextCursor);
  assert.equal(buildPage(rows.slice(0, 2), 2).meta.nextCursor, null);
});
