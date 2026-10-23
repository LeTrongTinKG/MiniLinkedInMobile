const interactionRepository = require("../repositories/interaction.repository");
const { ApiError } = require("../middleware/error");

/**
 * Nghiệp vụ cảm xúc + bình luận. targetType hiện chỉ có "job" nên targetId chính là jobId.
 */

async function assertJobExists(jobId) {
  if (!(await interactionRepository.jobExists(jobId))) {
    throw new ApiError(404, "TARGET_NOT_FOUND", "Không tìm thấy tin tuyển dụng");
  }
}

async function getSummaries(userId, jobIds) {
  const [reactionGroups, mine, commentGroups] = await Promise.all([
    interactionRepository.countReactionsByJob(jobIds),
    interactionRepository.findUserReactions(userId, jobIds),
    interactionRepository.countCommentsByJob(jobIds),
  ]);

  return jobIds.map((id) => {
    const counts = {};
    for (const g of reactionGroups) {
      if (g.jobId === id) counts[g.type] = g._count._all;
    }
    const total = Object.values(counts).reduce((sum, n) => sum + n, 0);
    const top = Object.entries(counts)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 3)
      .map(([type]) => type);
    const myReaction = mine.find((m) => m.jobId === id)?.type ?? null;
    const commentCount = commentGroups.find((g) => g.jobId === id)?._count._all ?? 0;

    return { targetType: "job", targetId: id, total, counts, top, myReaction, commentCount };
  });
}

async function setReaction(userId, jobId, type) {
  await assertJobExists(jobId);
  await interactionRepository.upsertReaction(userId, jobId, type);
  const [summary] = await getSummaries(userId, [jobId]);
  return summary;
}

async function removeReaction(userId, jobId) {
  await interactionRepository.deleteReaction(userId, jobId);
  const [summary] = await getSummaries(userId, [jobId]);
  return summary;
}

const toApiComment = (c, userId) => ({
  id: c.id,
  content: c.content,
  createdAt: c.createdAt,
  updatedAt: c.updatedAt,
  author: c.user,
  isMine: c.user.id === userId,
});

async function listComments(userId, jobId, { page, limit }) {
  const [rows, total] = await Promise.all([
    interactionRepository.findCommentsByJob(jobId, { skip: (page - 1) * limit, take: limit }),
    interactionRepository.countCommentsOfJob(jobId),
  ]);
  return { items: rows.map((c) => toApiComment(c, userId)), meta: { page, limit, total } };
}

async function createComment(userId, jobId, content) {
  await assertJobExists(jobId);
  const c = await interactionRepository.createComment(userId, jobId, content);
  return toApiComment(c, userId);
}

async function deleteComment(userId, commentId) {
  const c = await interactionRepository.findCommentOwner(commentId);
  if (!c) throw new ApiError(404, "COMMENT_NOT_FOUND", "Không tìm thấy bình luận");
  if (c.userId !== userId) {
    throw new ApiError(403, "FORBIDDEN", "Bạn chỉ xoá được bình luận của mình");
  }
  await interactionRepository.deleteCommentById(commentId);
  return { id: commentId };
}

module.exports = {
  getSummaries,
  setReaction,
  removeReaction,
  listComments,
  createComment,
  deleteComment,
};
