const { prisma } = require("../lib/prisma");
// shortcut: hạn mức nằm trong repository vì khóa và đếm phải cùng một transaction.
const { SCAN_LIMIT, monthWindow } = require("../services/skills/scanQuota");

const suggestionFields = {
  id: true,
  userId: true,
  skillName: true,
  evidence: true,
  status: true,
  createdAt: true,
};

async function findGithubId(userId, db = prisma) {
  const user = await db.user.findUnique({ where: { id: userId }, select: { githubId: true } });
  return user?.githubId ?? null;
}

async function listSkills(userId, db = prisma) {
  return db.userSkill.findMany({
    where: { userId },
    orderBy: { createdAt: "asc" },
    select: { id: true, skillName: true, source: true, evidence: true, confidence: true, confidenceReason: true, createdAt: true },
  });
}

async function listSuggestions(userId, statuses, db = prisma) {
  return db.skillSuggestion.findMany({
    where: { userId, status: { in: statuses } },
    orderBy: { createdAt: "asc" },
    select: suggestionFields,
  });
}

async function upsertPending(userId, skillName, evidence, db = prisma) {
  return db.skillSuggestion.upsert({
    where: { userId_skillName: { userId, skillName } },
    create: { userId, skillName, evidence },
    update: { evidence },
    select: suggestionFields,
  });
}

async function findSuggestionById(id, db = prisma) {
  return db.skillSuggestion.findUnique({ where: { id }, select: suggestionFields });
}

async function listApprovedNames(userId, db = prisma) {
  const rows = await db.userSkill.findMany({
    where: { userId, source: "github" },
    select: { skillName: true },
  });
  return rows.map((row) => row.skillName);
}

// Lượt đang chạy quá 3 phút coi như chết (request đã đứt), không khóa người dùng mãi.
const STALE_SCAN_MS = 3 * 60 * 1000;

async function beginScan(userId, db = prisma) {
  const { start, resetsAt } = monthWindow();
  return db.$transaction(async (tx) => {
    await tx.$executeRaw`SELECT pg_advisory_xact_lock(hashtext(${`skill-scan:${userId}`}))`;
    await tx.skillScan.updateMany({
      where: { userId, status: "running", createdAt: { lt: new Date(Date.now() - STALE_SCAN_MS) } },
      data: { status: "failed", finishedAt: new Date() },
    });
    const running = await tx.skillScan.count({ where: { userId, status: "running" } });
    if (running > 0) return { ok: false, code: "SCAN_ALREADY_RUNNING" };
    const used = await tx.skillScan.count({
      where: { userId, status: "succeeded", createdAt: { gte: start } },
    });
    if (used >= SCAN_LIMIT) return { ok: false, code: "QUOTA_EXCEEDED", resetsAt };
    const scan = await tx.skillScan.create({ data: { userId, status: "running" }, select: { id: true } });
    return { ok: true, scan };
  });
}

async function finishScan(id, status, db = prisma) {
  return db.skillScan.update({ where: { id }, data: { status, finishedAt: new Date() } });
}

async function acceptSuggestion(suggestion, level, db = prisma) {
  const { userId, skillName, evidence } = suggestion;
  const [skill] = await db.$transaction([
    db.userSkill.upsert({
      where: { userId_skillName: { userId, skillName } },
      create: { userId, skillName, source: "github", evidence, confidence: level.confidence, confidenceReason: level.reason },
      update: { source: "github", evidence, confidence: level.confidence, confidenceReason: level.reason },
    }),
    db.skillSuggestion.update({
      where: { id: suggestion.id },
      data: { status: "accepted", decidedAt: new Date() },
    }),
  ]);
  return skill;
}

async function rejectSuggestion(id, db = prisma) {
  return db.skillSuggestion.update({
    where: { id },
    data: { status: "rejected", decidedAt: new Date() },
    select: suggestionFields,
  });
}

module.exports = {
  findGithubId,
  listSkills,
  listSuggestions,
  upsertPending,
  findSuggestionById,
  listApprovedNames,
  beginScan,
  finishScan,
  acceptSuggestion,
  rejectSuggestion,
};
