const { prisma } = require("../lib/prisma");

const profileFields = { coachConsentAt: true, targetRole: true, major: true, graduationYear: true, headline: true };

async function findProfile(userId, db = prisma) {
  return db.studentProfile.findUnique({ where: { userId }, select: profileFields });
}

async function saveSettings(userId, { consentAt, targetRole }, db = prisma) {
  const data = {};
  if (consentAt !== undefined) data.coachConsentAt = consentAt;
  if (targetRole !== undefined) data.targetRole = targetRole;
  return db.studentProfile.upsert({
    where: { userId },
    create: { userId, ...data },
    update: data,
    select: profileFields,
  });
}

async function listSkills(userId, db = prisma) {
  return db.userSkill.findMany({ where: { userId }, select: { skillName: true, source: true, confidence: true } });
}

async function findDefaultCvSkills(userId, db = prisma) {
  const cv = await db.cv.findFirst({
    where: { userId },
    orderBy: [{ isDefault: "desc" }, { createdAt: "desc" }],
    select: { extractedSkills: true },
  });
  return cv?.extractedSkills ?? null;
}

async function findJob(jobId, db = prisma) {
  return db.job.findUnique({ where: { id: jobId }, select: { id: true, title: true, requiredSkills: true } });
}

async function findLatestAppliedJob(userId, db = prisma) {
  const application = await db.application.findFirst({
    where: { studentId: userId },
    orderBy: { createdAt: "desc" },
    select: { job: { select: { id: true, title: true, requiredSkills: true } } },
  });
  return application?.job ?? null;
}

async function usedToday(userId, day, db = prisma) {
  const row = await db.coachUsage.findUnique({ where: { userId_day: { userId, day } }, select: { count: true } });
  return row?.count ?? 0;
}

/** Tăng lượt trong một câu SQL; trả số lượt sau khi tăng, hoặc null khi đã chạm trần. */
async function takeQuota(userId, day, limit, db = prisma) {
  const rows = await db.$queryRaw`
    INSERT INTO public.coach_usage ("userId", "day", "count") VALUES (${userId}, ${day}, 1)
    ON CONFLICT ("userId", "day") DO UPDATE SET "count" = coach_usage."count" + 1
    WHERE coach_usage."count" < ${limit}
    RETURNING "count"`;
  return rows.length > 0 ? Number(rows[0].count) : null;
}

module.exports = {
  findProfile,
  saveSettings,
  listSkills,
  findDefaultCvSkills,
  findJob,
  findLatestAppliedJob,
  usedToday,
  takeQuota,
};
