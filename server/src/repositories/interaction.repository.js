const { prisma } = require("../lib/prisma");

/**
 * Truy vấn DB cho cảm xúc + bình luận.
 * Quan hệ 1-N có khoá ngoại: Job 1—N Reaction/Comment, User 1—N Reaction/Comment.
 */

const commentSelect = {
  id: true,
  content: true,
  createdAt: true,
  updatedAt: true,
  user: { select: { id: true, fullName: true, avatarUrl: true } },
};

const jobExists = async (jobId) =>
  (await prisma.job.findUnique({ where: { id: jobId }, select: { id: true } })) !== null;

// Đếm cảm xúc theo (jobId, type) cho nhiều job
const countReactionsByJob = (jobIds) =>
  prisma.reaction.groupBy({
    by: ["jobId", "type"],
    where: { jobId: { in: jobIds } },
    _count: { _all: true },
  });

const findUserReactions = (userId, jobIds) =>
  prisma.reaction.findMany({
    where: { userId, jobId: { in: jobIds } },
    select: { jobId: true, type: true },
  });

const countCommentsByJob = (jobIds) =>
  prisma.comment.groupBy({
    by: ["jobId"],
    where: { jobId: { in: jobIds } },
    _count: { _all: true },
  });

const upsertReaction = (userId, jobId, type) =>
  prisma.reaction.upsert({
    where: { userId_jobId: { userId, jobId } },
    create: { userId, jobId, type },
    update: { type },
  });

// deleteMany: chưa thả cảm xúc mà gọi xoá vẫn không lỗi
const deleteReaction = (userId, jobId) => prisma.reaction.deleteMany({ where: { userId, jobId } });

const findCommentsByJob = (jobId, { skip, take }) =>
  prisma.comment.findMany({
    where: { jobId },
    select: commentSelect,
    // id làm tie-breaker để phân trang ổn định khi trùng createdAt
    orderBy: [{ createdAt: "desc" }, { id: "desc" }],
    skip,
    take,
  });

const countCommentsOfJob = (jobId) => prisma.comment.count({ where: { jobId } });

const createComment = (userId, jobId, content) =>
  prisma.comment.create({ data: { userId, jobId, content }, select: commentSelect });

const findCommentOwner = (id) =>
  prisma.comment.findUnique({ where: { id }, select: { id: true, userId: true } });

const deleteCommentById = (id) => prisma.comment.delete({ where: { id } });

module.exports = {
  jobExists,
  countReactionsByJob,
  findUserReactions,
  countCommentsByJob,
  upsertReaction,
  deleteReaction,
  findCommentsByJob,
  countCommentsOfJob,
  createComment,
  findCommentOwner,
  deleteCommentById,
};
