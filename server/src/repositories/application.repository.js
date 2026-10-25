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

const cvSelect = {
  id: true,
  fileName: true,
  fileUrl: true,
};

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

/**
 * Tìm đơn ứng tuyển theo cặp Job ID và Student ID (Compound Unique)
 */
async function findByJobAndStudent(jobId, studentId, db = prisma) {
  return db.application.findUnique({
    where: {
      jobId_studentId: {
        jobId,
        studentId,
      },
    },
  });
}

/**
 * Tạo mới đơn ứng tuyển
 */
async function createApplication(data, db = prisma) {
  return db.application.create({
    data,
    include: {
      cv: { select: cvSelect },
    },
  });
}

/**
 * Lấy danh sách ứng viên của một tin tuyển dụng (sắp xếp giảm dần theo matchScore)
 */
async function findApplicationsByJobId({ jobId, status, skip = 0, limit = 10 }, db = prisma) {
  const where = {
    jobId,
    ...(status ? { status } : {}),
  };

  return db.application.findMany({
    where,
    orderBy: [
      { matchScore: "desc" },
      { createdAt: "desc" },
    ],
    skip,
    take: limit,
    include: {
      student: { select: studentSelect },
      cv: { select: cvSelect },
    },
  });
}

/**
 * Đếm tổng số đơn ứng tuyển của một Job
 */
async function countApplicationsByJobId({ jobId, status }, db = prisma) {
  const where = {
    jobId,
    ...(status ? { status } : {}),
  };

  return db.application.count({ where });
}

/**
 * Lấy danh sách đơn ứng tuyển của một sinh viên
 */
async function findApplicationsByStudentId(
  { studentId, status, skip = 0, limit = 10 },
  db = prisma
) {
  const where = {
    studentId,
    ...(status ? { status } : {}),
  };

  return db.application.findMany({
    where,
    orderBy: [{ createdAt: "desc" }],
    skip,
    take: limit,
    include: {
      job: { select: jobSummarySelect },
      cv: { select: cvSelect },
    },
  });
}

/**
 * Đếm tổng số đơn ứng tuyển của sinh viên
 */
async function countApplicationsByStudentId({ studentId, status }, db = prisma) {
  const where = {
    studentId,
    ...(status ? { status } : {}),
  };

  return db.application.count({ where });
}

/**
 * Tìm đơn ứng tuyển theo ID (kèm thông tin Job để kiểm tra quyền sở hữu)
 */
async function findById(id, db = prisma) {
  return db.application.findUnique({
    where: { id },
    include: {
      job: {
        select: {
          id: true,
          recruiterId: true,
          title: true,
        },
      },
    },
  });
}

/**
 * Cập nhật trạng thái đơn ứng tuyển
 */
async function updateStatus(id, status, db = prisma) {
  return db.application.update({
    where: { id },
    data: { status },
  });
}

module.exports = {
  findByJobAndStudent,
  createApplication,
  findApplicationsByJobId,
  countApplicationsByJobId,
  findApplicationsByStudentId,
  countApplicationsByStudentId,
  findById,
  updateStatus,
};
