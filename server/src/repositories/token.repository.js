const { prisma } = require("../lib/prisma");

async function createRefreshToken({ token, userId, expiresAt }, db = prisma) {
  return db.refreshToken.create({
    data: { token, userId, expiresAt },
  });
}

async function findRefreshToken(token, db = prisma) {
  return db.refreshToken.findUnique({
    where: { token },
    include: {
      user: {
        select: {
          id: true,
          email: true,
          fullName: true,
          role: true,
          avatarUrl: true,
          createdAt: true,
        },
      },
    },
  });
}

async function deleteRefreshToken(token, db = prisma) {
  return db.refreshToken.deleteMany({
    where: { token },
  });
}

async function deleteUserRefreshTokens(userId, db = prisma) {
  return db.refreshToken.deleteMany({
    where: { userId },
  });
}

module.exports = {
  createRefreshToken,
  findRefreshToken,
  deleteRefreshToken,
  deleteUserRefreshTokens,
};
