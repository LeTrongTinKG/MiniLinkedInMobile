const store = { jobs: [], users: [], cvs: [], applications: [], appIdCounter: 0 };

function clone(item) {
  return item ? { ...item } : null;
}

function studentView(user) {
  if (!user) return null;
  return {
    id: user.id,
    fullName: user.fullName,
    email: user.email,
    avatarUrl: user.avatarUrl,
    studentProfile: user.studentProfile,
  };
}

function cvView(cv) {
  return cv ? { id: cv.id, fileName: cv.fileName, fileUrl: cv.fileUrl } : null;
}

function jobSummary(job) {
  if (!job) return null;
  return {
    id: job.id,
    title: job.title,
    companyName: job.companyName,
    companyLogoUrl: job.companyLogoUrl,
    location: job.location,
    workMode: job.workMode,
    level: job.level,
    salaryMin: job.salaryMin,
    salaryMax: job.salaryMax,
    status: job.status,
  };
}

function matchApp(where) {
  if (where.id) return store.applications.find((a) => a.id === where.id);
  if (where.jobId_studentId) {
    const { jobId, studentId } = where.jobId_studentId;
    return store.applications.find((a) => a.jobId === jobId && a.studentId === studentId);
  }
  return null;
}

function filterApps(where = {}) {
  return store.applications.filter((a) => {
    if (where.jobId && a.jobId !== where.jobId) return false;
    if (where.studentId && a.studentId !== where.studentId) return false;
    if (where.status && a.status !== where.status) return false;
    return true;
  });
}

const prisma = {
  job: {
    async findUnique({ where: { id } }) {
      return clone(store.jobs.find((j) => j.id === id));
    },
  },
  cv: {
    async findUnique({ where: { id } }) {
      return clone(store.cvs.find((c) => c.id === id));
    },
    async findFirst({ where = {} }) {
      return clone(
        store.cvs.find(
          (c) =>
            (!where.userId || c.userId === where.userId) &&
            (where.isDefault === undefined || c.isDefault === where.isDefault)
        )
      );
    },
  },
  application: {
    async findUnique({ where }) {
      const found = matchApp(where);
      if (!found) return null;
      const job = store.jobs.find((j) => j.id === found.jobId);
      return {
        ...found,
        job: job
          ? {
              id: job.id,
              recruiterId: job.recruiterId,
              title: job.title,
              companyName: job.companyName,
              location: job.location,
            }
          : null,
        student: studentView(store.users.find((u) => u.id === found.studentId)),
        cv: cvView(store.cvs.find((c) => c.id === found.cvId)),
      };
    },
    async create({ data }) {
      const record = {
        id: `app-${++store.appIdCounter}`,
        jobId: data.jobId,
        studentId: data.studentId,
        cvId: data.cvId,
        matchScore: data.matchScore,
        matchedSkills: data.matchedSkills || [],
        missingSkills: data.missingSkills || [],
        status: data.status || "submitted",
        createdAt: new Date(),
        updatedAt: new Date(),
      };
      store.applications.push(record);
      return { ...record, cv: cvView(store.cvs.find((c) => c.id === record.cvId)) };
    },
    async findMany({ where = {}, orderBy = [], skip = 0, take = 10 }) {
      const filtered = filterApps(where);
      if (Array.isArray(orderBy) && orderBy.length > 0) {
        filtered.sort((a, b) => {
          for (const rule of orderBy) {
            if (rule.matchScore) {
              const diff = (b.matchScore ?? 0) - (a.matchScore ?? 0);
              if (diff !== 0) return rule.matchScore === "asc" ? -diff : diff;
            }
            if (rule.createdAt) {
              const diff = b.createdAt.getTime() - a.createdAt.getTime();
              if (diff !== 0) return rule.createdAt === "asc" ? -diff : diff;
            }
          }
          return 0;
        });
      }
      return filtered.slice(skip, skip + take).map((app) => ({
        ...app,
        student: studentView(store.users.find((u) => u.id === app.studentId)),
        cv: cvView(store.cvs.find((c) => c.id === app.cvId)),
        job: jobSummary(store.jobs.find((j) => j.id === app.jobId)),
      }));
    },
    async count({ where = {} }) {
      return filterApps(where).length;
    },
    async update({ where: { id }, data: { status } }) {
      const idx = store.applications.findIndex((a) => a.id === id);
      if (idx === -1) return null;
      store.applications[idx].status = status;
      store.applications[idx].updatedAt = new Date();
      return { ...store.applications[idx] };
    },
  },
};

function installPrismaMock() {
  require.cache[require.resolve("../src/lib/prisma")] = { exports: { prisma } };
}

module.exports = { store, prisma, installPrismaMock };
