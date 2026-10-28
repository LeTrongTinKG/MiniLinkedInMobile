// Test nghiệp vụ bài viết: repository được thay bằng hàm giả (mock), không chạm DB thật.
const assert = require("node:assert/strict");
const test = require("node:test");
const { mock } = require("node:test");
const dbLib = require("../../src/lib/social/db");
const postRepo = require("../../src/repositories/social/post.repository");
const mediaRepo = require("../../src/repositories/social/media.repository");
const reactionRepo = require("../../src/repositories/social/reaction.repository");
const revisionRepo = require("../../src/repositories/social/revision.repository");
const postService = require("../../src/services/social/post.service");
const shareService = require("../../src/services/social/share.service");

const ME = "user-me";
const OTHER = "user-other";

// Một dòng bài giả như DB trả về
function fakePost(over = {}) {
  return {
    id: "post-1",
    content: "nội dung cũ",
    authorId: ME,
    authorName: "Tôi",
    authorAvatarUrl: null,
    sharedPostId: null,
    editedAt: null,
    deletedAt: null,
    createdAt: new Date(),
    cursorTs: "2026-01-01T00:00:00.000000Z",
    commentCount: 0,
    shareCount: 0,
    myReaction: null,
    ...over,
  };
}

// Thay các hàm đọc phụ (ảnh, cảm xúc) bằng hàm trả rỗng + transaction giả
function mockCommon() {
  mock.method(dbLib, "withTransaction", async (fn) => fn({ fake: true }));
  mock.method(postRepo, "findPostsByIds", async () => []);
  mock.method(mediaRepo, "listMediaByPostIds", async () => []);
  mock.method(reactionRepo, "countByTargets", async () => []);
}

test.afterEach(() => mock.restoreAll());

test("sửa bài của người khác => 403 NOT_POST_OWNER, không ghi gì", async () => {
  mockCommon();
  mock.method(postRepo, "lockPost", async () => fakePost({ authorId: OTHER }));
  const revision = mock.method(revisionRepo, "insertRevision", async () => {});
  const update = mock.method(postRepo, "updatePostContent", async () => {});

  await assert.rejects(
    postService.updatePost({ userId: ME, postId: "post-1", changes: { content: "hack" } }),
    (err) => err.statusCode === 403 && err.code === "NOT_POST_OWNER"
  );
  assert.equal(revision.mock.callCount(), 0);
  assert.equal(update.mock.callCount(), 0);
});

test("xóa bài của người khác => 403 NOT_POST_OWNER", async () => {
  mock.method(postRepo, "findPostById", async () => fakePost({ authorId: OTHER }));
  const del = mock.method(postRepo, "softDeletePost", async () => {});

  await assert.rejects(
    postService.deletePost({ userId: ME, postId: "post-1" }),
    (err) => err.statusCode === 403 && err.code === "NOT_POST_OWNER"
  );
  assert.equal(del.mock.callCount(), 0);
});

test("xóa bài của mình => xóa mềm", async () => {
  mock.method(postRepo, "findPostById", async () => fakePost());
  const del = mock.method(postRepo, "softDeletePost", async () => {});
  await postService.deletePost({ userId: ME, postId: "post-1" });
  assert.equal(del.mock.callCount(), 1);
});

test("sửa bài: lưu nội dung cũ vào revision và đặt edited_at", async () => {
  mockCommon();
  mock.method(postRepo, "lockPost", async () => fakePost());
  mock.method(postRepo, "findPostById", async () => fakePost({ content: "nội dung mới" }));
  const revision = mock.method(revisionRepo, "insertRevision", async () => {});
  const update = mock.method(postRepo, "updatePostContent", async () => {});

  const dto = await postService.updatePost({
    userId: ME,
    postId: "post-1",
    changes: { content: "nội dung mới" },
  });

  assert.deepEqual(revision.mock.calls[0].arguments.slice(0, 2), ["post-1", "nội dung cũ"]);
  assert.deepEqual(update.mock.calls[0].arguments.slice(0, 2), ["post-1", "nội dung mới"]);
  assert.equal(dto.content, "nội dung mới");
  assert.equal(dto.isMine, true);
});

test("sửa bài thành trống (không chữ, không ảnh) => 400 POST_EMPTY", async () => {
  mockCommon();
  mock.method(postRepo, "lockPost", async () => fakePost());

  await assert.rejects(
    postService.updatePost({ userId: ME, postId: "post-1", changes: { content: "" } }),
    (err) => err.statusCode === 400 && err.code === "POST_EMPTY"
  );
});

test("đăng bài trống => 400 POST_EMPTY", async () => {
  await assert.rejects(
    postService.createPost({ userId: ME, content: "", mediaIds: [] }),
    (err) => err.code === "POST_EMPTY"
  );
});

test("đăng bài với ảnh không phải của mình => 404 MEDIA_NOT_FOUND", async () => {
  mockCommon();
  mock.method(mediaRepo, "findUsableMedia", async () => []);
  await assert.rejects(
    postService.createPost({ userId: ME, content: "hi", mediaIds: ["m1"] }),
    (err) => err.statusCode === 404 && err.code === "MEDIA_NOT_FOUND"
  );
});

test("share của share => trỏ về bài gốc đầu tiên, không lồng", async () => {
  mockCommon();
  // A là bài gốc, B là bài chia sẻ của A. Người dùng chia sẻ B.
  const store = {
    A: fakePost({ id: "A", authorId: OTHER }),
    B: fakePost({ id: "B", authorId: OTHER, sharedPostId: "A" }),
    NEW: fakePost({ id: "NEW", sharedPostId: "A", content: "hay quá" }),
  };
  mock.method(postRepo, "findPostById", async (id) => store[id] || null);
  mock.method(postRepo, "findPostsByIds", async (ids) => ids.map((id) => store[id]).filter(Boolean));
  const insert = mock.method(postRepo, "insertPost", async () => ({ id: "NEW" }));

  const dto = await shareService.sharePost({ userId: ME, postId: "B", content: "hay quá" });

  assert.equal(insert.mock.calls[0].arguments[0].sharedPostId, "A");
  assert.equal(dto.sharedPost.id, "A");
  assert.equal(dto.sharedPost.sharedPost, undefined); // không lồng thêm tầng nào
});

test("bài chia sẻ có bài gốc đã xóa => placeholder", async () => {
  mockCommon();
  const share = fakePost({ id: "S", sharedPostId: "A" });
  mock.method(postRepo, "findPostById", async () => share);
  mock.method(postRepo, "findPostsByIds", async () => [fakePost({ id: "A", deletedAt: new Date() })]);

  const dto = await postService.getPost("S", ME);
  assert.equal(dto.sharedPost.isDeleted, true);
  assert.match(dto.sharedPost.message, /không còn tồn tại/);
});
