// Controller bài viết: chỉ đọc req -> gọi service -> trả response. Danh tính lấy từ req.user.userId.
const { asyncHandler } = require("../../middleware/error");
const { sendSuccess } = require("../response");
const postService = require("../../services/social/post.service");
const shareService = require("../../services/social/share.service");
const { parseUuid, parsePaging } = require("../../validations/social/common.validation");
const {
  parseCreatePost,
  parseUpdatePost,
  parseShare,
} = require("../../validations/social/post.validation");

const listFeed = asyncHandler(async (req, res) => {
  const { cursor, limit } = parsePaging(req.query);
  const page = await postService.listPosts({
    viewerId: req.user.userId,
    authorId: null,
    cursor,
    limit,
  });
  return sendSuccess(res, page.items, 200, page.meta);
});

const listUserPosts = asyncHandler(async (req, res) => {
  const { cursor, limit } = parsePaging(req.query);
  const page = await postService.listPosts({
    viewerId: req.user.userId,
    authorId: req.params.userId,
    cursor,
    limit,
  });
  return sendSuccess(res, page.items, 200, page.meta);
});

const getPost = asyncHandler(async (req, res) => {
  const postId = parseUuid(req.params.postId, "postId");
  return sendSuccess(res, await postService.getPost(postId, req.user.userId));
});

const createPost = asyncHandler(async (req, res) => {
  const { content, mediaIds } = parseCreatePost(req.body);
  const post = await postService.createPost({ userId: req.user.userId, content, mediaIds });
  return sendSuccess(res, post, 201);
});

const updatePost = asyncHandler(async (req, res) => {
  const post = await postService.updatePost({
    userId: req.user.userId,
    postId: parseUuid(req.params.postId, "postId"),
    changes: parseUpdatePost(req.body),
  });
  return sendSuccess(res, post);
});

const deletePost = asyncHandler(async (req, res) => {
  const result = await postService.deletePost({
    userId: req.user.userId,
    postId: parseUuid(req.params.postId, "postId"),
  });
  return sendSuccess(res, result);
});

const listRevisions = asyncHandler(async (req, res) => {
  const revisions = await postService.listRevisions({
    viewerId: req.user.userId,
    postId: parseUuid(req.params.postId, "postId"),
  });
  return sendSuccess(res, revisions);
});

const sharePost = asyncHandler(async (req, res) => {
  const { content } = parseShare(req.body);
  const post = await shareService.sharePost({
    userId: req.user.userId,
    postId: parseUuid(req.params.postId, "postId"),
    content,
  });
  return sendSuccess(res, post, 201);
});

module.exports = {
  listFeed,
  listUserPosts,
  getPost,
  createPost,
  updatePost,
  deletePost,
  listRevisions,
  sharePost,
};
