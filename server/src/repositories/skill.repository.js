const { prisma } = require("../lib/prisma");

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
    select: { id: true, skillName: true, source: true, evidence: true, createdAt: true },
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

async function acceptSuggestion(suggestion, db = prisma) {
  const { userId, skillName, evidence } = suggestion;
  const [skill] = await db.$transaction([
    db.userSkill.upsert({
      where: { userId_skillName: { userId, skillName } },
      create: { userId, skillName, source: "github", evidence },
      update: { source: "github", evidence },
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
  acceptSuggestion,
  rejectSuggestion,
};
