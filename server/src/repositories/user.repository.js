const { prisma } = require("../lib/prisma");

const publicUserSelect = {
  id: true,
  email: true,
  fullName: true,
  role: true,
  avatarUrl: true,
  loginAttempts: true,
  loginLockedUntil: true,
  createdAt: true,
};

async function findByEmail(email, includePassword = false, db = prisma) {
  return db.user.findUnique({
    where: { email: email.trim().toLowerCase() },
    select: {
      ...publicUserSelect,
      ...(includePassword ? { passwordHash: true, googleId: true } : {}),
    },
  });
}

async function findById(id, db = prisma) {
  return db.user.findUnique({
    where: { id },
    select: {
      ...publicUserSelect,
      studentProfile: true,
      recruiterProfile: true,
    },
  });
}

async function findByGoogleId(googleId, db = prisma) {
  return db.user.findUnique({
    where: { googleId },
    select: publicUserSelect,
  });
}

async function createUser(data, db = prisma) {
  return db.user.create({
    data,
    select: publicUserSelect,
  });
}

async function updateUser(id, data, db = prisma) {
  return db.user.update({
    where: { id },
    data,
    select: publicUserSelect,
  });
}

async function incrementLoginAttempts(id, currentAttempts = 0, db = prisma) {
  const attempts = currentAttempts + 1;
  const lockedUntil = attempts >= 5 ? new Date(Date.now() + 15 * 60 * 1000) : null;
  return db.user.update({
    where: { id },
    data: {
      loginAttempts: attempts,
      loginLockedUntil: lockedUntil,
    },
    select: publicUserSelect,
  });
}

async function resetLoginAttempts(id, db = prisma) {
  return db.user.update({
    where: { id },
    data: {
      loginAttempts: 0,
      loginLockedUntil: null,
    },
    select: publicUserSelect,
  });
}

module.exports = {
  findByEmail,
  findById,
  findByGoogleId,
  createUser,
  updateUser,
  incrementLoginAttempts,
  resetLoginAttempts,
  publicUserSelect,
};
