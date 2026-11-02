const { prisma } = require("../lib/prisma");
const { studentSelect, cvSelect, jobSummarySelect } = require("./application.repository");

const buildWhere = ({ recruiterId, status }) => ({
  job: { recruiterId },
  ...(status ? { status } : {}),
});

/**
 * Đơn ứng tuyển vào mọi job của một nhà tuyển dụng (điểm match cao xếp trước)
 */
async function findApplicationsByRecruiterId({ recruiterId, status, skip = 0, limit = 10 }, db = prisma) {
  return db.application.findMany({
    where: buildWhere({ recruiterId, status }),
    orderBy: [{ matchScore: "desc" }, { createdAt: "desc" }],
    skip,
    take: limit,
    include: {
      student: { select: studentSelect },
      cv: { select: cvSelect },
      job: { select: jobSummarySelect },
    },
  });
}

async function countApplicationsByRecruiterId({ recruiterId, status }, db = prisma) {
  return db.application.count({ where: buildWhere({ recruiterId, status }) });
}

module.exports = { findApplicationsByRecruiterId, countApplicationsByRecruiterId };
