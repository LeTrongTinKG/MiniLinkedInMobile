const assert = require("node:assert/strict");
const test = require("node:test");
const { mock } = require("node:test");
const postRepo = require("../../src/repositories/social/post.repository");
const commentRepo = require("../../src/repositories/social/comment.repository");
const reactionRepo = require("../../src/repositories/social/reaction.repository");
const commentService = require("../../src/services/social/comment.service");

const ME = "user-me";
const OTHER = "user-other";

function fakeComment(over = {}) {
  return {
    id: "c1",
    postId: "p1",
    parentId: null,
    content: "xin chào",
    authorId: ME,
    authorName: "Tôi",
    authorAvatarUrl: null,
    postAuthorId: OTHER,
    replyCount: 0,
    myReaction: null,
    editedAt: null,
    createdAt: new Date(),
    deletedAt: null,
    ...over,
  };
}

test.afterEach(() => mock.restoreAll());

function mockStore(store) {
  mock.method(postRepo, "findPostById", async () => ({ id: "p1", deletedAt: null }));
  mock.method(reactionRepo, "countByTargets", async () => []);
  mock.method(commentRepo, "findCommentById", async (id) => store[id] || null);
}

test("reply vào bình luận gốc => parentId là bình luận gốc", async () => {
  mockStore({ root: fakeComment({ id: "root" }), new1: fakeComment({ id: "new1", parentId: "root" }) });
  const insert = mock.method(commentRepo, "insertComment", async () => ({ id: "new1" }));

  await commentService.createComment({ userId: ME, postId: "p1", content: "rep", parentId: "root" });
  assert.equal(insert.mock.calls[0].arguments[0].parentId, "root");
});

test("reply vào reply => tự gắn về bình luận gốc (chỉ 2 cấp)", async () => {
  mockStore({
    root: fakeComment({ id: "root" }),
    reply: fakeComment({ id: "reply", parentId: "root" }),
    new2: fakeComment({ id: "new2", parentId: "root" }),
  });
  const insert = mock.method(commentRepo, "insertComment", async () => ({ id: "new2" }));

  const dto = await commentService.createComment({
    userId: ME,
    postId: "p1",
    content: "rep của rep",
    parentId: "reply",
  });
  assert.equal(insert.mock.calls[0].arguments[0].parentId, "root");
  assert.equal(dto.parentId, "root");
});

test("sửa bình luận của người khác => 403 NOT_COMMENT_OWNER", async () => {
  mockStore({ c1: fakeComment({ authorId: OTHER }) });
  await assert.rejects(
    commentService.updateComment({ userId: ME, commentId: "c1", content: "x" }),
    (err) => err.statusCode === 403 && err.code === "NOT_COMMENT_OWNER"
  );
});

test("xóa bình luận: người lạ bị chặn, chủ bài được xóa", async () => {
  mockStore({ c1: fakeComment({ authorId: OTHER, postAuthorId: ME }) });
  const del = mock.method(commentRepo, "softDeleteComment", async () => {});

  await commentService.deleteComment({ userId: ME, commentId: "c1" }); // ME là chủ bài
  assert.equal(del.mock.callCount(), 1);

  await assert.rejects(
    commentService.deleteComment({ userId: "stranger", commentId: "c1" }),
    (err) => err.code === "NOT_COMMENT_OWNER"
  );
  assert.equal(del.mock.callCount(), 1);
});

test("bình luận không tồn tại => 404 COMMENT_NOT_FOUND", async () => {
  mockStore({});
  await assert.rejects(
    commentService.deleteComment({ userId: ME, commentId: "nope" }),
    (err) => err.statusCode === 404 && err.code === "COMMENT_NOT_FOUND"
  );
});
