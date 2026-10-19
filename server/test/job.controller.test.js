const assert = require("node:assert/strict");
const test = require("node:test");
const jwt = require("jsonwebtoken");

process.env.JWT_SECRET = "test-secret-with-more-than-thirty-two-characters";

let jobs = [];
let users = [];
let idCounter = 0;

const prisma = {
  job: {
    async findMany({ where = {}, skip = 0, take = 10, orderBy }) {
      let filtered = [...jobs];

      if (where.status) {
        filtered = filtered.filter((j) => j.status === where.status);
      }

      if (where.recruiterId) {
        filtered = filtered.filter((j) => j.recruiterId === where.recruiterId);
      }

      if (where.AND && Array.isArray(where.AND)) {
        for (const condition of where.AND) {
          if (condition.OR) {
            filtered = filtered.filter((j) =>
              condition.OR.some((c) => {
                if (c.title) return j.title.toLowerCase().includes(c.title.contains.toLowerCase());
                if (c.description) return j.description.toLowerCase().includes(c.description.contains.toLowerCase());
                if (c.companyName) return j.companyName.toLowerCase().includes(c.companyName.contains.toLowerCase());
                return false;
              })
            );
          }
          if (condition.requiredSkills?.hasSome) {
            const required = condition.requiredSkills.hasSome.map((s) => s.toLowerCase());
            filtered = filtered.filter((j) =>
              j.requiredSkills.some((s) => required.includes(s.toLowerCase()))
            );
          }
          if (condition.level) {
            filtered = filtered.filter((j) => j.level === condition.level);
          }
          if (condition.workMode) {
            filtered = filtered.filter((j) => j.workMode === condition.workMode);
          }
          if (condition.location?.contains) {
            filtered = filtered.filter((j) =>
              j.location.toLowerCase().includes(condition.location.contains.toLowerCase())
            );
          }
        }
      }

      // Sort
      filtered.sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime());

      // Pagination
      const sliced = filtered.slice(skip, skip + take);

      return sliced.map((job) => {
        const recruiterUser = users.find((u) => u.id === job.recruiterId);
        return {
          ...job,
          recruiter: recruiterUser
            ? {
                id: recruiterUser.id,
                fullName: recruiterUser.fullName,
                avatarUrl: recruiterUser.avatarUrl,
                recruiterProfile: recruiterUser.recruiterProfile,
              }
            : null,
          _count: {
            applications: job.applicationsCountMock ?? 0,
          },
        };
      });
    },

    async count({ where = {} }) {
      const all = await prisma.job.findMany({ where, skip: 0, take: 9999 });
      return all.length;
    },

    async findUnique({ where: { id } }) {
      const job = jobs.find((j) => j.id === id);
      if (!job) return null;

      const recruiterUser = users.find((u) => u.id === job.recruiterId);
      return {
        ...job,
        recruiter: recruiterUser
          ? {
              id: recruiterUser.id,
              fullName: recruiterUser.fullName,
              avatarUrl: recruiterUser.avatarUrl,
              recruiterProfile: recruiterUser.recruiterProfile,
            }
          : null,
        _count: {
          applications: job.applicationsCountMock ?? 0,
        },
      };
    },
  },
  user: {
    async findUnique({ where: { id } }) {
      const u = users.find((item) => item.id === id);
      return u ? { tokenVersion: u.tokenVersion } : null;
    },
  },
};

// Mock prisma dependency trong repository
require.cache[require.resolve("../src/lib/prisma")] = {
  exports: { prisma },
};

const userRepository = require("../src/repositories/user.repository");
userRepository.findTokenVersion = async (userId) => {
  const u = users.find((item) => item.id === userId);
  return u ? { tokenVersion: u.tokenVersion } : null;
};

const jobController = require("../src/controllers/job.controller");
const { authenticate, authorize } = require("../src/middleware/auth");
const { errorHandler } = require("../src/middleware/error");
const { generateAccessToken } = require("../src/utils/token");

function createMockRes() {
  return {
    statusCode: 200,
    status(code) {
      this.statusCode = code;
      return this;
    },
    json(body) {
      this.body = body;
      return this;
    },
  };
}

async function dispatch(handler, req, middlewares = []) {
  const res = createMockRes();
  const next = (err) => {
    if (err) {
      errorHandler(err, req, res, () => {});
    }
  };

  for (const mw of middlewares) {
    let nextCalled = false;
    let mwError = null;
    await mw(req, res, (err) => {
      nextCalled = true;
      mwError = err;
    });

    if (mwError) {
      errorHandler(mwError, req, res, () => {});
      return res;
    }

    if (!nextCalled) {
      return res;
    }
  }

  await handler(req, res, next);
  return res;
}

function resetDb() {
  idCounter = 0;
  users = [
    {
      id: "recruiter-1",
      email: "recruiter1@company.com",
      role: "recruiter",
      fullName: "Nguyễn Văn Tuyển",
      avatarUrl: "https://example.com/avatar1.png",
      tokenVersion: 0,
      recruiterProfile: {
        companyName: "Tech Corp",
        companyLogoUrl: "https://example.com/logo.png",
        position: "HR Manager",
      },
    },
    {
      id: "recruiter-2",
      email: "recruiter2@other.com",
      role: "recruiter",
      fullName: "Trần Tuyển Dụng",
      avatarUrl: null,
      tokenVersion: 0,
      recruiterProfile: {
        companyName: "Dev Studio",
        companyLogoUrl: null,
        position: "Tech Lead",
      },
    },
    {
      id: "student-1",
      email: "student1@school.edu.vn",
      role: "student",
      fullName: "Lê Sinh Viên",
      avatarUrl: null,
      tokenVersion: 0,
    },
  ];

  jobs = [
    {
      id: "job-1",
      recruiterId: "recruiter-1",
      title: "Flutter Mobile Developer Intern",
      companyName: "Tech Corp",
      companyLogoUrl: "https://example.com/logo.png",
      location: "Hồ Chí Minh",
      workMode: "hybrid",
      level: "intern",
      salaryMin: 3000000,
      salaryMax: 6000000,
      description: "Tuyển thực tập sinh Flutter phát triển app di động",
      requiredSkills: ["Flutter", "Dart"],
      niceToHave: ["Git", "REST API"],
      status: "open",
      createdAt: new Date("2026-10-15T10:00:00Z"),
      updatedAt: new Date("2026-10-15T10:00:00Z"),
      applicationsCountMock: 5,
    },
    {
      id: "job-2",
      recruiterId: "recruiter-1",
      title: "Node.js Backend Fresher",
      companyName: "Tech Corp",
      companyLogoUrl: "https://example.com/logo.png",
      location: "Hà Nội",
      workMode: "remote",
      level: "fresher",
      salaryMin: 10000000,
      salaryMax: 15000000,
      description: "Xây dựng hệ thống REST API bằng Node.js Express và PostgreSQL",
      requiredSkills: ["Node.js", "Express", "PostgreSQL"],
      niceToHave: ["Docker"],
      status: "open",
      createdAt: new Date("2026-10-16T10:00:00Z"),
      updatedAt: new Date("2026-10-16T10:00:00Z"),
      applicationsCountMock: 12,
    },
    {
      id: "job-3",
      recruiterId: "recruiter-2",
      title: "Junior React Native Engineer",
      companyName: "Dev Studio",
      companyLogoUrl: null,
      location: "Đà Nẵng",
      workMode: "onsite",
      level: "junior",
      salaryMin: 12000000,
      salaryMax: 18000000,
      description: "Phát triển ứng dụng React Native cho đối tác quốc tế",
      requiredSkills: ["React Native", "TypeScript"],
      niceToHave: ["Redux"],
      status: "open",
      createdAt: new Date("2026-10-17T10:00:00Z"),
      updatedAt: new Date("2026-10-17T10:00:00Z"),
      applicationsCountMock: 3,
    },
    {
      id: "job-4",
      recruiterId: "recruiter-1",
      title: "Closed Golang Backend Developer",
      companyName: "Tech Corp",
      companyLogoUrl: "https://example.com/logo.png",
      location: "Hồ Chí Minh",
      workMode: "remote",
      level: "junior",
      salaryMin: 15000000,
      salaryMax: 25000000,
      description: "Job đã đóng không hiển thị ngoài trang public",
      requiredSkills: ["Golang"],
      niceToHave: ["gRPC"],
      status: "closed",
      createdAt: new Date("2026-10-18T10:00:00Z"),
      updatedAt: new Date("2026-10-18T10:00:00Z"),
      applicationsCountMock: 8,
    },
  ];
}

test.beforeEach(() => {
  resetDb();
});

test("GET /api/v1/jobs trả về danh sách job đang open kèm pagination meta chuẩn", async () => {
  const req = { query: { page: "1", limit: "10" } };
  const res = await dispatch(jobController.getPublicJobs, req);

  assert.equal(res.statusCode, 200);
  assert.ok(Array.isArray(res.body.data));
  // Chỉ 3 job open, job-4 closed bị loại bỏ
  assert.equal(res.body.data.length, 3);
  assert.equal(res.body.meta.totalItems, 3);
  assert.equal(res.body.meta.total, 3);
  assert.equal(res.body.meta.page, 1);
  assert.equal(res.body.meta.limit, 10);
  assert.equal(res.body.meta.totalPages, 1);
  assert.equal(res.body.meta.hasNextPage, false);
  assert.equal(res.body.meta.hasPrevPage, false);

  // Kiểm tra thuộc tính applicationsCount
  assert.equal(res.body.data[0].applicationsCount, 3); // job-3 mới nhất
});

test("GET /api/v1/jobs lọc chính xác theo từ khóa q (title, description, companyName)", async () => {
  const req = { query: { q: "Flutter" } };
  const res = await dispatch(jobController.getPublicJobs, req);

  assert.equal(res.statusCode, 200);
  assert.equal(res.body.data.length, 1);
  assert.equal(res.body.data[0].id, "job-1");
});

test("GET /api/v1/jobs lọc chính xác theo skills (dấu phẩy và mảng query)", async () => {
  // 1. Dạng chuỗi phân tách dấu phẩy
  const reqString = { query: { skills: "Dart,PostgreSQL" } };
  const resString = await dispatch(jobController.getPublicJobs, reqString);

  assert.equal(resString.statusCode, 200);
  assert.equal(resString.body.data.length, 2);
  const ids = resString.body.data.map((j) => j.id);
  assert.ok(ids.includes("job-1"));
  assert.ok(ids.includes("job-2"));

  // 2. Dạng mảng query
  const reqArray = { query: { skills: ["TypeScript"] } };
  const resArray = await dispatch(jobController.getPublicJobs, reqArray);

  assert.equal(resArray.statusCode, 200);
  assert.equal(resArray.body.data.length, 1);
  assert.equal(resArray.body.data[0].id, "job-3");
});

test("GET /api/v1/jobs lọc theo level, workMode và location", async () => {
  const req = {
    query: {
      level: "intern",
      workMode: "hybrid",
      location: "Hồ Chí Minh",
    },
  };
  const res = await dispatch(jobController.getPublicJobs, req);

  assert.equal(res.statusCode, 200);
  assert.equal(res.body.data.length, 1);
  assert.equal(res.body.data[0].id, "job-1");
  assert.equal(res.body.data[0].level, "intern");
  assert.equal(res.body.data[0].workMode, "hybrid");
});

test("GET /api/v1/jobs/:id trả về chi tiết job kèm thông tin recruiter và số lượt ứng tuyển", async () => {
  const req = { params: { id: "job-1" } };
  const res = await dispatch(jobController.getJobDetail, req);

  assert.equal(res.statusCode, 200);
  assert.equal(res.body.data.id, "job-1");
  assert.equal(res.body.data.applicationsCount, 5);
  assert.ok(res.body.data.recruiter);
  assert.equal(res.body.data.recruiter.fullName, "Nguyễn Văn Tuyển");
  assert.equal(res.body.data.recruiter.recruiterProfile.companyName, "Tech Corp");
});

test("GET /api/v1/jobs/:id trả về 404 khi ID không tồn tại", async () => {
  const req = { params: { id: "non-existent-id" } };
  const res = await dispatch(jobController.getJobDetail, req);

  assert.equal(res.statusCode, 404);
  assert.equal(res.body.error.code, "JOB_NOT_FOUND");
  assert.equal(res.body.error.message, "Không tìm thấy job");
});

test("GET /api/v1/recruiter/jobs từ chối khi không có Access Token (401)", async () => {
  const req = { headers: {}, query: {} };
  const res = await dispatch(jobController.getRecruiterJobs, req, [
    authenticate,
    authorize("recruiter"),
  ]);

  assert.equal(res.statusCode, 401);
  assert.equal(res.body.error.code, "UNAUTHORIZED");
});

test("GET /api/v1/recruiter/jobs từ chối khi user có role student (403 FORBIDDEN)", async () => {
  const studentToken = generateAccessToken({
    id: "student-1",
    email: "student1@school.edu.vn",
    role: "student",
    tokenVersion: 0,
  });

  const req = {
    headers: { authorization: `Bearer ${studentToken}` },
    query: {},
  };
  const res = await dispatch(jobController.getRecruiterJobs, req, [
    authenticate,
    authorize("recruiter"),
  ]);

  assert.equal(res.statusCode, 403);
  assert.equal(res.body.error.code, "FORBIDDEN");
});

test("GET /api/v1/recruiter/jobs thành công cho recruiter và trả về danh sách job của chính họ kèm số ứng viên", async () => {
  const recruiterToken = generateAccessToken({
    id: "recruiter-1",
    email: "recruiter1@company.com",
    role: "recruiter",
    tokenVersion: 0,
  });

  // 1. Lấy tất cả job của recruiter-1 (cả open và closed) kèm số ứng viên
  const reqAll = {
    headers: { authorization: `Bearer ${recruiterToken}` },
    query: { page: "1", limit: "10" },
  };
  const resAll = await dispatch(jobController.getRecruiterJobs, reqAll, [
    authenticate,
    authorize("recruiter"),
  ]);

  assert.equal(resAll.statusCode, 200);
  assert.equal(resAll.body.data.length, 3); // job-1, job-2, job-4
  assert.equal(resAll.body.meta.totalItems, 3);
  assert.equal(resAll.body.meta.total, 3);
  const ids = resAll.body.data.map((j) => j.id);
  assert.ok(ids.includes("job-1"));
  assert.ok(ids.includes("job-2"));
  assert.ok(ids.includes("job-4"));
  assert.ok(!ids.includes("job-3")); // job-3 thuộc về recruiter-2

  // Xác nhận trả về kèm số ứng viên (đáp ứng tiêu chí nghiệm thu)
  const job1 = resAll.body.data.find((j) => j.id === "job-1");
  assert.equal(job1.applicationsCount, 5);
  assert.equal(job1.totalApplications, 5);
  assert.equal(job1._count.applications, 5);

  // 2. Lọc theo status = closed
  const reqClosed = {
    headers: { authorization: `Bearer ${recruiterToken}` },
    query: { status: "closed" },
  };
  const resClosed = await dispatch(jobController.getRecruiterJobs, reqClosed, [
    authenticate,
    authorize("recruiter"),
  ]);

  assert.equal(resClosed.statusCode, 200);
  assert.equal(resClosed.body.data.length, 1);
  assert.equal(resClosed.body.data[0].id, "job-4");
  assert.equal(resClosed.body.data[0].applicationsCount, 8);
  assert.equal(resClosed.body.data[0]._count.applications, 8);
});
