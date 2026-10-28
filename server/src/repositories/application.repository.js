const { prisma } = require("../lib/prisma");

const studentSelect = {
  id: true,
  fullName: true,
  email: true,
  avatarUrl: true,
  studentProfile: {
    select: {
      school: true,
      major: true,
      headline: true,
      location: true,
      graduationYear: true,
    },
  },
};

const cvSelect = { id: true, fileName: true, fileUrl: true };

const jobSummarySelect = {
  id: true,
  title: true,
  companyName: true,
  companyLogoUrl: true,
  location: true,
  workMode: true,
  level: true,
  salaryMin: true,
  salaryMax: true,
  status: true,
};

const candidateInclude = {
  student: { select: studentSelect },
  cv: { select: cvSelect },
  job: { select: jobSummarySelect },
};

function withStatus(base, status) {
  return status ? { ...base, status } : base;
}

async function findByJobAndStudent(jobId, studentId, db = prisma) {
  return db.application.findUnique({
    where: { jobId_studentId: { jobId, studentId } },
  });
}

async function createApplication(data, db = prisma) {
  return db.application.create({
    data,
    include: { cv: { select: cvSelect } },
  });
}

async function findApplicationsByJobId({ jobId, status, skip = 0, limit = 10 }, db = prisma) {
  return db.application.findMany({
    where: withStatus({ jobId }, status),
    orderBy: [{ matchScore: "desc" }, { createdAt: "desc" }],
    skip,
    take: limit,
    include: candidateInclude,
  });
}

async function countApplicationsByJobId({ jobId, status }, db = prisma) {
  return db.application.count({ where: withStatus({ jobId }, status) });
}

async function findApplicationsByStudentId(
  { studentId, status, skip = 0, limit = 10 },
  db = prisma
) {
  return db.application.findMany({
    where: withStatus({ studentId }, status),
    orderBy: [{ createdAt: "desc" }],
    skip,
    take: limit,
    include: { job: { select: jobSummarySelect }, cv: { select: cvSelect } },
  });
}

async function countApplicationsByStudentId({ studentId, status }, db = prisma) {
  return db.application.count({ where: withStatus({ studentId }, status) });
}

async function findById(id, db = prisma) {
  return db.application.findUnique({
    where: { id },
    include: { job: { select: { id: true, recruiterId: true, title: true } } },
  });
}

async function findDetailById(id, db = prisma) {
  return db.application.findUnique({
    where: { id },
    include: {
      student: { select: studentSelect },
      cv: { select: cvSelect },
      job: {
        select: {
          id: true,
          recruiterId: true,
          title: true,
          companyName: true,
          location: true,
        },
      },
    },
  });
}

async function updateStatus(id, status, db = prisma) {
  return db.application.update({ where: { id }, data: { status } });
}

module.exports = {
  studentSelect,
  cvSelect,
  jobSummarySelect,
  findByJobAndStudent,
  createApplication,
  findApplicationsByJobId,
  countApplicationsByJobId,
  findApplicationsByStudentId,
  countApplicationsByStudentId,
  findById,
  findDetailById,
  updateStatus,
};
