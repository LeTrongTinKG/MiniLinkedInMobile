// Chia sẻ bài: tạo bài mới trỏ về bài gốc.
const postRepo = require("../../repositories/social/post.repository");
const { ApiError } = require("../../middleware/error");
const postService = require("./post.service");

const postNotFound = () => new ApiError(404, "POST_NOT_FOUND", "Bài viết không tồn tại");

async function sharePost({ userId, postId, content }) {
  const target = await postRepo.findPostById(postId, userId);
  if (!target || target.deletedAt) throw postNotFound();

  // Chia sẻ một bài vốn đã là bài chia sẻ -> trỏ thẳng về bài gốc đầu tiên (không lồng nhau)
  let originalId = target.id;
  if (target.sharedPostId) {
    const root = await postRepo.findPostById(target.sharedPostId, userId);
    if (!root || root.deletedAt) throw postNotFound();
    originalId = root.id;
  }

  const created = await postRepo.insertPost({
    authorId: userId,
    content,
    sharedPostId: originalId,
  });
  return postService.getPost(created.id, userId);
}

module.exports = { sharePost };
