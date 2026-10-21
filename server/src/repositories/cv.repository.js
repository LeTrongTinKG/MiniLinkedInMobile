const { prisma } = require("../lib/prisma");

const cvSelectFields = {
  id: true,
  userId: true,
  fileName: true,
  fileUrl: true,
  extractedSkills: true,
  isDefault: true,
  createdAt: true,
  updatedAt: true,
};

async function createCv(data, db = prisma) {
  return db.cv.create({
    data,
    select: cvSelectFields,
  });
}

async function findByUserId(userId, db = prisma) {
  return db.cv.findMany({
    where: { userId },
    orderBy: [
      { isDefault: "desc" },
      { createdAt: "desc" },
    ],
    select: cvSelectFields,
  });
}

async function findById(id, db = prisma) {
  return db.cv.findUnique({
    where: { id },
    select: {
      ...cvSelectFields,
      _count: {
        select: {
          applications: true,
        },
      },
    },
  });
}

async function countByUserId(userId, db = prisma) {
  return db.cv.count({
    where: { userId },
  });
}

async function findFirstByUserId(userId, excludeId = null, db = prisma) {
  const where = { userId };
  if (excludeId) {
    where.id = { not: excludeId };
  }
  return db.cv.findFirst({
    where,
    orderBy: { createdAt: "desc" },
    select: cvSelectFields,
  });
}

async function setDefaultCv(userId, cvId, db = prisma) {
  return db.$transaction(async (tx) => {
    // 1. Chuyển tất cả CV của user về false
    await tx.cv.updateMany({
      where: { userId },
      data: { isDefault: false },
    });

    // 2. Đặt CV chỉ định thành true
    return tx.cv.update({
      where: { id: cvId },
      data: { isDefault: true },
      select: cvSelectFields,
    });
  });
}

async function updateCvDefault(cvId, isDefault, db = prisma) {
  return db.cv.update({
    where: { id: cvId },
    data: { isDefault },
    select: cvSelectFields,
  });
}

async function deleteCv(id, db = prisma) {
  return db.cv.delete({
    where: { id },
  });
}

module.exports = {
  createCv,
  findByUserId,
  findById,
  countByUserId,
  findFirstByUserId,
  setDefaultCv,
  updateCvDefault,
  deleteCv,
  cvSelectFields,
};
