const { prisma } = require("../lib/prisma");

async function findProfileByUserId(userId, db = prisma) {
  const user = await db.user.findUnique({
    where: { id: userId },
    select: {
      id: true,
      email: true,
      fullName: true,
      role: true,
      avatarUrl: true,
      studentProfile: true,
      recruiterProfile: true,
    },
  });
  return user;
}

async function upsertProfile(userId, data, db = prisma) {
  const { fullName, headline, about, location, school, major, isPrivate = true } = data;

  if (fullName !== undefined) {
    await db.user.update({
      where: { id: userId },
      data: { fullName: fullName.trim() },
    });
  }

  const studentProfile = await db.studentProfile.upsert({
    where: { userId },
    create: {
      userId,
      headline: headline?.trim() || null,
      about: about?.trim() || null,
      location: location?.trim() || null,
      school: school?.trim() || null,
      major: major?.trim() || null,
    },
    update: {
      headline: headline !== undefined ? headline.trim() : undefined,
      about: about !== undefined ? about.trim() : undefined,
      location: location !== undefined ? location.trim() : undefined,
      school: school !== undefined ? school.trim() : undefined,
      major: major !== undefined ? major.trim() : undefined,
    },
  });

  return {
    ...studentProfile,
    isPrivate: Boolean(isPrivate),
  };
}

module.exports = {
  findProfileByUserId,
  upsertProfile,
};
