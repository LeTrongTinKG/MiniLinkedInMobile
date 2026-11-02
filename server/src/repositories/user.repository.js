const { prisma } = require("../lib/prisma");

// Danh sách trường trả ra ngoài cho Client (KHÔNG chứa loginAttempts, loginLockedUntil, passwordHash, googleId, githubId, tokenVersion)
const clientUserSelect = {
  id: true,
  email: true,
  fullName: true,
  role: true,
  avatarUrl: true,
  createdAt: true,
};

// Danh sách trường dùng nội bộ trong Server
const internalUserSelect = {
  ...clientUserSelect,
  passwordHash: true,
  googleId: true,
  githubId: true,
  loginAttempts: true,
  loginLockedUntil: true,
};

async function findByEmail(email, isInternal = false, db = prisma) {
  return db.user.findUnique({
    where: { email: email.trim().toLowerCase() },
    select: isInternal ? internalUserSelect : clientUserSelect,
  });
}

async function findById(id, db = prisma) {
  return db.user.findUnique({
    where: { id },
    select: {
      ...clientUserSelect,
      studentProfile: true,
      recruiterProfile: true,
    },
  });
}

async function findByGoogleId(googleId, db = prisma) {
  return db.user.findUnique({
    where: { googleId },
    select: clientUserSelect,
  });
}

async function findByGitHubId(githubId, db = prisma) {
  return db.user.findUnique({
    where: { githubId },
    select: clientUserSelect,
  });
}

async function createUser(data, db = prisma) {
  return db.user.create({
    data,
    select: clientUserSelect,
  });
}

async function updateUser(id, data, db = prisma) {
  return db.user.update({
    where: { id },
    data,
    select: clientUserSelect,
  });
}

async function incrementLoginAttempts(id, db = prisma) {
  const updated = await db.user.update({
    where: { id },
    data: {
      loginAttempts: { increment: 1 },
    },
    select: {
      id: true,
      loginAttempts: true,
      loginLockedUntil: true,
    },
  });

  if (updated.loginAttempts >= 5) {
    const lockedUntil = new Date(Date.now() + 15 * 60 * 1000);
    return db.user.update({
      where: { id },
      data: {
        loginLockedUntil: lockedUntil,
      },
      select: {
        id: true,
        loginAttempts: true,
        loginLockedUntil: true,
      },
    });
  }

  return updated;
}

async function resetLoginAttempts(id, db = prisma) {
  return db.user.update({
    where: { id },
    data: {
      loginAttempts: 0,
      loginLockedUntil: null,
    },
    select: {
      id: true,
      loginAttempts: true,
      loginLockedUntil: true,
    },
  });
}

module.exports = {
  findByEmail,
  findById,
  findByGoogleId,
  findByGitHubId,
  createUser,
  updateUser,
  incrementLoginAttempts,
  resetLoginAttempts,
  clientUserSelect,
  internalUserSelect,
};
