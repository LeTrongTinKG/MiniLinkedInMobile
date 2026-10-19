const { prisma } = require("../lib/prisma");

// Danh sách trường trả ra ngoài cho Client (KHÔNG chứa loginAttempts, loginLockedUntil, passwordHash, googleId, tokenVersion)
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
  tokenVersion: true,
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

async function incrementLoginAttempts(id, currentAttempts = 0, db = prisma) {
  const attempts = currentAttempts + 1;
  const lockedUntil = attempts >= 5 ? new Date(Date.now() + 15 * 60 * 1000) : null;
  return db.user.update({
    where: { id },
    data: {
      loginAttempts: attempts,
      loginLockedUntil: lockedUntil,
    },
    select: {
      id: true,
      loginAttempts: true,
      loginLockedUntil: true,
    },
  });
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
  createUser,
  updateUser,
  incrementLoginAttempts,
  resetLoginAttempts,
  clientUserSelect,
  internalUserSelect,
};
