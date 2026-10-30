const assert = require("node:assert/strict");
const test = require("node:test");

process.env.JWT_SECRET = "test-secret-with-more-than-thirty-two-characters";
process.env.NODE_ENV = "test";
process.env.AI_MODE = "mock";

let jobs = [];
let users = [];
let cvs = [];
let applications = [];
let appIdCounter = 0;

const prisma = {
  userSkill: {
    async findMany() {
      return [];
    },
  },
  job: {
    async findUnique({ where: { id } }) {
      const found = jobs.find((j) => j.id === id);
      return found ? { ...found } : null;
    },
  },
  cv: {
    async findUnique({ where: { id } }) {
      const found = cvs.find((c) => c.id === id);
      return found ? { ...found } : null;
    },
    async findFirst({ where = {} }) {
      let filtered = [...cvs];
      if (where.userId) {
        filtered = filtered.filter((c) => c.userId === where.userId);
      }
      if (where.isDefault !== undefined) {
        filtered = filtered.filter((c) => c.isDefault === where.isDefault);
      }
      return filtered[0] ? { ...filtered[0] } : null;
    },
  },
  application: {
    async findUnique({ where }) {
      if (where.id) {
        const found = applications.find((a) => a.id === where.id);
        if (!found) return null;
        const job = jobs.find((j) => j.id === found.jobId);
        const student = users.find((u) => u.id === found.studentId);
        const cv = cvs.find((c) => c.id === found.cvId);
        return {
          ...found,
          job: job ? { id: job.id, recruiterId: job.recruiterId, title: job.title, companyName: job.companyName, location: job.location } : null,
          student: student ? {
            id: student.id,
            fullName: student.fullName,
            email: student.email,
            avatarUrl: student.avatarUrl,
            studentProfile: student.studentProfile,
          } : null,
          cv: cv ? { id: cv.id, fileName: cv.fileName, fileUrl: cv.fileUrl } : null,
        };
      }
      if (where.jobId_studentId) {
        const { jobId, studentId } = where.jobId_studentId;
        const found = applications.find((a) => a.jobId === jobId && a.studentId === studentId);
        return found ? { ...found } : null;
      }
      return null;
    },
    async create({ data }) {
      const record = {
        id: `app-${++appIdCounter}`,
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
      applications.push(record);
      const cv = cvs.find((c) => c.id === record.cvId);
      return {
        ...record,
        cv: cv ? { id: cv.id, fileName: cv.fileName, fileUrl: cv.fileUrl } : null,
      };
    },
    async findMany({ where = {}, orderBy = [], skip = 0, take = 10 }) {
      let filtered = [...applications];
      if (where.jobId) {
        filtered = filtered.filter((a) => a.jobId === where.jobId);
      }
      if (where.studentId) {
        filtered = filtered.filter((a) => a.studentId === where.studentId);
      }
      if (where.status) {
        filtered = filtered.filter((a) => a.status === where.status);
      }

      // Sắp xếp theo orderBy
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

      const sliced = filtered.slice(skip, skip + take);
      return sliced.map((app) => {
        const student = users.find((u) => u.id === app.studentId);
        const cv = cvs.find((c) => c.id === app.cvId);
        const job = jobs.find((j) => j.id === app.jobId);
        return {
          ...app,
          student: student
            ? {
                id: student.id,
                fullName: student.fullName,
                email: student.email,
                avatarUrl: student.avatarUrl,
                studentProfile: student.studentProfile,
              }
            : null,
          cv: cv ? { id: cv.id, fileName: cv.fileName, fileUrl: cv.fileUrl } : null,
          job: job
            ? {
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
              }
            : null,
        };
      });
    },
    async count({ where = {} }) {
      let filtered = [...applications];
      if (where.jobId) filtered = filtered.filter((a) => a.jobId === where.jobId);
      if (where.studentId) filtered = filtered.filter((a) => a.studentId === where.studentId);
      if (where.status) filtered = filtered.filter((a) => a.status === where.status);
      return filtered.length;
    },
    async update({ where: { id }, data: { status } }) {
      const idx = applications.findIndex((a) => a.id === id);
      if (idx === -1) return null;
      applications[idx].status = status;
      applications[idx].updatedAt = new Date();
      return { ...applications[idx] };
    },
  },
};

require.cache[require.resolve("../src/lib/prisma")] = {
  exports: { prisma },
};

const applicationController = require("../src/controllers/application.controller");
const { authenticate, authorize } = require("../src/middleware/auth");
const { generateAccessToken } = require("../src/utils/token");
const { createMockRes, dispatch } = require("./helpers");

test.beforeEach(() => {
  appIdCounter = 0;
  users = [
    {
      id: "student-1",
      email: "student1@school.edu.vn",
      role: "student",
      fullName: "Nguyễn Văn Sinh Viên",
      avatarUrl: "https://example.com/avatar-sv.png",
      studentProfile: {
        school: "Đại học Bách Khoa",
        major: "Công nghệ Thông tin",
        headline: "Fresher Flutter Dev",
        location: "TP. Hồ Chí Minh",
        graduationYear: 2026,
      },
    },
    {
      id: "student-2",
      email: "student2@school.edu.vn",
      role: "student",
      fullName: "Trần Thị Sinh Viên 2",
      avatarUrl: "https://example.com/avatar-sv2.png",
      studentProfile: {
        school: "Đại học KHTN",
        major: "Kỹ thuật Phần mềm",
        headline: "Junior Mobile Developer",
        location: "TP. Hồ Chí Minh",
        graduationYear: 2025,
      },
    },
    {
      id: "recruiter-1",
      email: "recruiter1@company.com",
      role: "recruiter",
      fullName: "Lê Tuyển Dụng",
      avatarUrl: null,
    },
    {
      id: "recruiter-2",
      email: "recruiter2@other.com",
      role: "recruiter",
      fullName: "Phạm Nhà Tuyển Dụng Khác",
      avatarUrl: null,
    },
  ];

  jobs = [
    {
      id: "job-1",
      recruiterId: "recruiter-1",
      title: "Flutter Fresher Developer",
      companyName: "Tech Solutions",
      companyLogoUrl: null,
      location: "TP. Hồ Chí Minh",
      workMode: "hybrid",
      level: "fresher",
      salaryMin: 10000000,
      salaryMax: 15000000,
      description: "Lập trình ứng dụng Flutter cho khách hàng quốc tế",
      requiredSkills: ["Flutter", "Dart"],
      niceToHave: ["Node.js", "Git"],
      status: "open",
      createdAt: new Date("2026-10-01T00:00:00Z"),
      updatedAt: new Date("2026-10-01T00:00:00Z"),
    },
    {
      id: "job-closed",
      recruiterId: "recruiter-1",
      title: "Backend Node.js Intern (Closed)",
      companyName: "Tech Solutions",
      location: "Hà Nội",
      workMode: "remote",
      level: "intern",
      description: "Vị trí đã đóng",
      requiredSkills: ["Node.js"],
      niceToHave: [],
      status: "closed",
      createdAt: new Date("2026-09-01T00:00:00Z"),
      updatedAt: new Date("2026-09-01T00:00:00Z"),
    },
  ];

  cvs = [
    {
      id: "cv-1",
      userId: "student-1",
      fileName: "NguyenVanA_Flutter_CV.pdf",
      fileUrl: "https://storage.supabase.co/cvs/cv-1.pdf",
      extractedSkills: { skills: ["Flutter", "Dart", "Git"] },
      isDefault: true,
      createdAt: new Date("2026-10-02T00:00:00Z"),
      updatedAt: new Date("2026-10-02T00:00:00Z"),
    },
    {
      id: "cv-2",
      userId: "student-1",
      fileName: "NguyenVanA_Backend_CV.pdf",
      fileUrl: "https://storage.supabase.co/cvs/cv-2.pdf",
      extractedSkills: { skills: ["Node.js", "Express", "PostgreSQL"] },
      isDefault: false,
      createdAt: new Date("2026-10-03T00:00:00Z"),
      updatedAt: new Date("2026-10-03T00:00:00Z"),
    },
    {
      id: "cv-sv2",
      userId: "student-2",
      fileName: "TranThiB_CV.pdf",
      fileUrl: "https://storage.supabase.co/cvs/cv-sv2.pdf",
      extractedSkills: { skills: ["Flutter"] },
      isDefault: true,
      createdAt: new Date("2026-10-04T00:00:00Z"),
      updatedAt: new Date("2026-10-04T00:00:00Z"),
    },
  ];

  applications = [];
});

// --- NHÓM TEST: ỨNG TUYỂN (POST /api/v1/applications) ---

test("POST /api/v1/applications từ chối khi không có Access Token (401 UNAUTHORIZED)", async () => {
  const req = { headers: {}, body: { jobId: "job-1" } };
  const res = await dispatch(applicationController.applyJob, req, [
    authenticate,
    authorize("student"),
  ]);

  assert.equal(res.statusCode, 401);
  assert.equal(res.body.error.code, "UNAUTHORIZED");
});

test("POST /api/v1/applications từ chối khi user là recruiter (403 FORBIDDEN)", async () => {
  const token = generateAccessToken({
    id: "recruiter-1",
    email: "recruiter1@company.com",
    role: "recruiter",
  });

  const req = {
    headers: { authorization: `Bearer ${token}` },
    body: { jobId: "job-1" },
  };

  const res = await dispatch(applicationController.applyJob, req, [
    authenticate,
    authorize("student"),
  ]);

  assert.equal(res.statusCode, 403);
  assert.equal(res.body.error.code, "FORBIDDEN");
});

test("POST /api/v1/applications trả về 400 khi thiếu jobId", async () => {
  const token = generateAccessToken({
    id: "student-1",
    email: "student1@school.edu.vn",
    role: "student",
  });

  const req = {
    headers: { authorization: `Bearer ${token}` },
    body: {},
  };

  const res = await dispatch(applicationController.applyJob, req, [
    authenticate,
    authorize("student"),
  ]);

  assert.equal(res.statusCode, 400);
  assert.equal(res.body.error.code, "INVALID_INPUT");
});

test("POST /api/v1/applications trả về 404 khi jobId không tồn tại", async () => {
  const token = generateAccessToken({
    id: "student-1",
    email: "student1@school.edu.vn",
    role: "student",
  });

  const req = {
    headers: { authorization: `Bearer ${token}` },
    body: { jobId: "non-existent-job" },
  };

  const res = await dispatch(applicationController.applyJob, req, [
    authenticate,
    authorize("student"),
  ]);

  assert.equal(res.statusCode, 404);
  assert.equal(res.body.error.code, "JOB_NOT_FOUND");
});

test("POST /api/v1/applications trả về 400 khi Job đã đóng (status = closed)", async () => {
  const token = generateAccessToken({
    id: "student-1",
    email: "student1@school.edu.vn",
    role: "student",
  });

  const req = {
    headers: { authorization: `Bearer ${token}` },
    body: { jobId: "job-closed" },
  };

  const res = await dispatch(applicationController.applyJob, req, [
    authenticate,
    authorize("student"),
  ]);

  assert.equal(res.statusCode, 400);
  assert.equal(res.body.error.code, "JOB_CLOSED");
});

test("POST /api/v1/applications trả về 409 EXTERNAL_JOB_APPLY kèm applyUrl khi job nguồn ngoài (không có recruiter)", async () => {
  jobs.push({
    id: "job-external",
    recruiterId: null,
    title: "Junior Dev",
    companyName: "Acme",
    status: "open",
    source: "jsearch",
    applyUrl: "https://vn.linkedin.com/jobs/view/1",
    requiredSkills: [],
    niceToHave: [],
  });
  const token = generateAccessToken({ id: "student-1", email: "student1@school.edu.vn", role: "student" });

  const res = await dispatch(
    applicationController.applyJob,
    { headers: { authorization: `Bearer ${token}` }, body: { jobId: "job-external" } },
    [authenticate, authorize("student")]
  );

  assert.equal(res.statusCode, 409);
  assert.equal(res.body.error.code, "EXTERNAL_JOB_APPLY");
  assert.equal(res.body.error.applyUrl, "https://vn.linkedin.com/jobs/view/1");
});

test("POST /api/v1/applications nộp đơn thành công với CV chỉ định và lưu đúng matchScore", async () => {
  const token = generateAccessToken({
    id: "student-1",
    email: "student1@school.edu.vn",
    role: "student",
  });

  const req = {
    headers: { authorization: `Bearer ${token}` },
    body: { jobId: "job-1", cvId: "cv-1" },
  };

  const res = await dispatch(applicationController.applyJob, req, [
    authenticate,
    authorize("student"),
  ]);

  assert.equal(res.statusCode, 201);
  assert.ok(res.body.data);
  assert.equal(res.body.data.jobId, "job-1");
  assert.equal(res.body.data.studentId, "student-1");
  assert.equal(res.body.data.cvId, "cv-1");
  assert.equal(res.body.data.status, "submitted");
  assert.equal(typeof res.body.data.matchScore, "number");
  assert.equal(applications.length, 1);
});

test("POST /api/v1/applications nộp đơn thành công khi không truyền cvId (tự động dùng CV mặc định)", async () => {
  const token = generateAccessToken({
    id: "student-1",
    email: "student1@school.edu.vn",
    role: "student",
  });

  const req = {
    headers: { authorization: `Bearer ${token}` },
    body: { jobId: "job-1" }, // Không truyền cvId
  };

  const res = await dispatch(applicationController.applyJob, req, [
    authenticate,
    authorize("student"),
  ]);

  assert.equal(res.statusCode, 201);
  assert.ok(res.body.data);
  assert.equal(res.body.data.cvId, "cv-1"); // Tự động lấy cv-1 là CV mặc định
});

test("POST /api/v1/applications trả về 400 khi không truyền cvId và sinh viên chưa có CV nào", async () => {
  const token = generateAccessToken({
    id: "student-no-cv",
    email: "nocv@school.edu.vn",
    role: "student",
  });

  const req = {
    headers: { authorization: `Bearer ${token}` },
    body: { jobId: "job-1" },
  };

  const res = await dispatch(applicationController.applyJob, req, [
    authenticate,
    authorize("student"),
  ]);

  assert.equal(res.statusCode, 400);
  assert.equal(res.body.error.code, "NO_CV_FOUND");
});

test("POST /api/v1/applications ứng tuyển 2 lần trả 409 ALREADY_APPLIED (Tiêu chuẩn 1)", async () => {
  const token = generateAccessToken({
    id: "student-1",
    email: "student1@school.edu.vn",
    role: "student",
  });

  const req1 = {
    headers: { authorization: `Bearer ${token}` },
    body: { jobId: "job-1", cvId: "cv-1" },
  };

  // Nộp lần 1 -> 201 Created
  const res1 = await dispatch(applicationController.applyJob, req1, [
    authenticate,
    authorize("student"),
  ]);
  assert.equal(res1.statusCode, 201);

  // Nộp lần 2 vào cùng Job -> 409 Conflict
  const req2 = {
    headers: { authorization: `Bearer ${token}` },
    body: { jobId: "job-1", cvId: "cv-2" },
  };
  const res2 = await dispatch(applicationController.applyJob, req2, [
    authenticate,
    authorize("student"),
  ]);

  assert.equal(res2.statusCode, 409);
  assert.equal(res2.body.error.code, "ALREADY_APPLIED");
  assert.equal(res2.body.error.message, "Bạn đã ứng tuyển vào công việc này rồi");
});

test("POST /api/v1/applications từ chối khi nộp bằng CV của sinh viên khác (403 FORBIDDEN)", async () => {
  const token = generateAccessToken({
    id: "student-1",
    email: "student1@school.edu.vn",
    role: "student",
  });

  // student-1 cố tình nộp bằng cv-sv2 của student-2
  const req = {
    headers: { authorization: `Bearer ${token}` },
    body: { jobId: "job-1", cvId: "cv-sv2" },
  };

  const res = await dispatch(applicationController.applyJob, req, [
    authenticate,
    authorize("student"),
  ]);

  assert.equal(res.statusCode, 403);
  assert.equal(res.body.error.code, "FORBIDDEN");
});

// --- NHÓM TEST: DANH SÁCH ỨNG VIÊN CHO RECRUITER (GET /api/v1/recruiter/jobs/:jobId/applications) ---

test("GET /api/v1/recruiter/jobs/:jobId/applications từ chối với 403 FORBIDDEN khi không phải chủ job (Tiêu chuẩn 3)", async () => {
  // recruiter-2 cố tình xem danh sách ứng viên của job-1 (do recruiter-1 tạo)
  const token = generateAccessToken({
    id: "recruiter-2",
    email: "recruiter2@other.com",
    role: "recruiter",
  });

  const req = {
    headers: { authorization: `Bearer ${token}` },
    params: { jobId: "job-1" },
  };

  const res = await dispatch(applicationController.getJobApplications, req, [
    authenticate,
    authorize("recruiter"),
  ]);

  assert.equal(res.statusCode, 403);
  assert.equal(res.body.error.code, "FORBIDDEN");
  assert.equal(
    res.body.error.message,
    "Bạn không có quyền xem danh sách ứng viên của công việc này"
  );
});

test("GET /api/v1/recruiter/jobs/:jobId/applications từ chối sinh viên truy cập (403 FORBIDDEN)", async () => {
  const token = generateAccessToken({
    id: "student-1",
    email: "student1@school.edu.vn",
    role: "student",
  });

  const req = {
    headers: { authorization: `Bearer ${token}` },
    params: { jobId: "job-1" },
  };

  const res = await dispatch(applicationController.getJobApplications, req, [
    authenticate,
    authorize("recruiter"),
  ]);

  assert.equal(res.statusCode, 403);
  assert.equal(res.body.error.code, "FORBIDDEN");
});

test("GET /api/v1/recruiter/jobs/:jobId/applications trả về 404 khi Job không tồn tại", async () => {
  const token = generateAccessToken({
    id: "recruiter-1",
    email: "recruiter1@company.com",
    role: "recruiter",
  });

  const req = {
    headers: { authorization: `Bearer ${token}` },
    params: { jobId: "non-existent-job" },
  };

  const res = await dispatch(applicationController.getJobApplications, req, [
    authenticate,
    authorize("recruiter"),
  ]);

  assert.equal(res.statusCode, 404);
  assert.equal(res.body.error.code, "JOB_NOT_FOUND");
});

test("GET /api/v1/recruiter/jobs/:jobId/applications trả về danh sách ứng viên giảm dần theo matchScore (Tiêu chuẩn 2)", async () => {
  // Chuẩn bị 3 đơn nộp với matchScore khác nhau
  applications = [
    {
      id: "app-low",
      jobId: "job-1",
      studentId: "student-2",
      cvId: "cv-sv2",
      matchScore: 50,
      matchedSkills: ["Flutter"],
      missingSkills: ["Dart"],
      status: "submitted",
      createdAt: new Date("2026-10-10T08:00:00Z"),
      updatedAt: new Date("2026-10-10T08:00:00Z"),
    },
    {
      id: "app-high",
      jobId: "job-1",
      studentId: "student-1",
      cvId: "cv-1",
      matchScore: 100,
      matchedSkills: ["Flutter", "Dart"],
      missingSkills: [],
      status: "submitted",
      createdAt: new Date("2026-10-10T09:00:00Z"),
      updatedAt: new Date("2026-10-10T09:00:00Z"),
    },
    {
      id: "app-mid",
      jobId: "job-1",
      studentId: "student-3",
      cvId: "cv-3",
      matchScore: 75,
      matchedSkills: ["Flutter"],
      missingSkills: ["Dart"],
      status: "submitted",
      createdAt: new Date("2026-10-10T10:00:00Z"),
      updatedAt: new Date("2026-10-10T10:00:00Z"),
    },
  ];

  const token = generateAccessToken({
    id: "recruiter-1",
    email: "recruiter1@company.com",
    role: "recruiter",
  });

  const req = {
    headers: { authorization: `Bearer ${token}` },
    params: { jobId: "job-1" },
  };

  const res = await dispatch(applicationController.getJobApplications, req, [
    authenticate,
    authorize("recruiter"),
  ]);

  assert.equal(res.statusCode, 200);
  assert.ok(Array.isArray(res.body.data));
  assert.equal(res.body.data.length, 3);
  assert.equal(res.body.meta.total, 3);

  // Xác minh thứ tự: 100% -> 75% -> 50%
  assert.equal(res.body.data[0].id, "app-high");
  assert.equal(res.body.data[0].matchScore, 100);
  assert.equal(res.body.data[1].id, "app-mid");
  assert.equal(res.body.data[1].matchScore, 75);
  assert.equal(res.body.data[2].id, "app-low");
  assert.equal(res.body.data[2].matchScore, 50);

  // Xác minh có thông tin sinh viên và CV
  assert.ok(res.body.data[0].student);
  assert.equal(res.body.data[0].student.fullName, "Nguyễn Văn Sinh Viên");
  assert.ok(res.body.data[0].cv);
  assert.equal(res.body.data[0].cv.fileName, "NguyenVanA_Flutter_CV.pdf");
});

test("GET /api/v1/recruiter/applications?jobId=... hỗ trợ query params", async () => {
  const token = generateAccessToken({
    id: "recruiter-1",
    email: "recruiter1@company.com",
    role: "recruiter",
  });

  const req = {
    headers: { authorization: `Bearer ${token}` },
    query: { jobId: "job-1" },
  };

  const res = await dispatch(applicationController.getJobApplications, req, [
    authenticate,
    authorize("recruiter"),
  ]);

  assert.equal(res.statusCode, 200);
  assert.ok(res.body.data);
  assert.ok(res.body.meta);
});

// --- NHÓM TEST: SINH VIÊN XEM ĐƠN & RECRUITER DUYỆT ĐƠN ---

test("GET /api/v1/applications/my trả về danh sách các đơn đã nộp của sinh viên", async () => {
  applications = [
    {
      id: "app-1",
      jobId: "job-1",
      studentId: "student-1",
      cvId: "cv-1",
      matchScore: 90,
      status: "submitted",
      createdAt: new Date("2026-10-10T10:00:00Z"),
      updatedAt: new Date("2026-10-10T10:00:00Z"),
    },
  ];

  const token = generateAccessToken({
    id: "student-1",
    email: "student1@school.edu.vn",
    role: "student",
  });

  const req = {
    headers: { authorization: `Bearer ${token}` },
  };

  const res = await dispatch(applicationController.getMyApplications, req, [
    authenticate,
    authorize("student"),
  ]);

  assert.equal(res.statusCode, 200);
  assert.equal(res.body.data.length, 1);
  assert.equal(res.body.data[0].id, "app-1");
  assert.ok(res.body.data[0].job);
  assert.equal(res.body.data[0].job.title, "Flutter Fresher Developer");
});

test("PATCH /api/v1/recruiter/applications/:id/status duyệt đơn thành công khi là chủ job", async () => {
  applications = [
    {
      id: "app-1",
      jobId: "job-1",
      studentId: "student-1",
      cvId: "cv-1",
      status: "submitted",
      createdAt: new Date(),
      updatedAt: new Date(),
    },
  ];

  const token = generateAccessToken({
    id: "recruiter-1",
    email: "recruiter1@company.com",
    role: "recruiter",
  });

  const req = {
    headers: { authorization: `Bearer ${token}` },
    params: { id: "app-1" },
    body: { status: "accepted" },
  };

  const res = await dispatch(applicationController.updateApplicationStatus, req, [
    authenticate,
    authorize("recruiter"),
  ]);

  assert.equal(res.statusCode, 200);
  assert.equal(res.body.data.status, "accepted");
  assert.equal(applications[0].status, "accepted");
});

test("PATCH /api/v1/recruiter/applications/:id/status từ chối với 403 khi recruiter khác cố duyệt đơn", async () => {
  applications = [
    {
      id: "app-1",
      jobId: "job-1",
      studentId: "student-1",
      cvId: "cv-1",
      status: "submitted",
      createdAt: new Date(),
      updatedAt: new Date(),
    },
  ];

  const token = generateAccessToken({
    id: "recruiter-2", // Không phải chủ của job-1
    email: "recruiter2@other.com",
    role: "recruiter",
  });

  const req = {
    headers: { authorization: `Bearer ${token}` },
    params: { id: "app-1" },
    body: { status: "accepted" },
  };

  const res = await dispatch(applicationController.updateApplicationStatus, req, [
    authenticate,
    authorize("recruiter"),
  ]);

  assert.equal(res.statusCode, 403);
  assert.equal(res.body.error.code, "FORBIDDEN");
  assert.equal(applications[0].status, "submitted"); // Trạng thái không bị đổi
});

test("PATCH /api/v1/recruiter/applications/:id/status trả về 400 khi status không hợp lệ", async () => {
  applications = [
    {
      id: "app-1",
      jobId: "job-1",
      studentId: "student-1",
      cvId: "cv-1",
      status: "submitted",
      createdAt: new Date(),
      updatedAt: new Date(),
    },
  ];

  const token = generateAccessToken({
    id: "recruiter-1",
    email: "recruiter1@company.com",
    role: "recruiter",
  });

  const req = {
    headers: { authorization: `Bearer ${token}` },
    params: { id: "app-1" },
    body: { status: "invalid_status" },
  };

  const res = await dispatch(applicationController.updateApplicationStatus, req, [
    authenticate,
    authorize("recruiter"),
  ]);

  assert.equal(res.statusCode, 400);
  assert.equal(res.body.error.code, "INVALID_STATUS");
});


// --- NHÓM TEST BỔ SUNG: RÚT ĐƠN & XEM CHI TIẾT ỨNG VIÊN ---

test("PATCH /api/v1/applications/:id/withdraw rút đơn thành công và đổi status thành withdrawn", async () => {
  applications = [
    {
      id: "app-1",
      jobId: "job-1",
      studentId: "student-1",
      cvId: "cv-1",
      status: "submitted",
      createdAt: new Date(),
      updatedAt: new Date(),
    },
  ];

  const token = generateAccessToken({
    id: "student-1",
    email: "student1@school.edu.vn",
    role: "student",
  });

  const req = {
    headers: { authorization: `Bearer ${token}` },
    params: { id: "app-1" },
  };

  const res = await dispatch(applicationController.withdrawApplication, req, [
    authenticate,
    authorize("student"),
  ]);

  assert.equal(res.statusCode, 200);
  assert.equal(res.body.data.status, "withdrawn");
  assert.equal(applications[0].status, "withdrawn");
});

test("PATCH /api/v1/applications/:id/withdraw từ chối khi sinh viên cố rút đơn của người khác (403 FORBIDDEN)", async () => {
  applications = [
    {
      id: "app-1",
      jobId: "job-1",
      studentId: "student-1",
      cvId: "cv-1",
      status: "submitted",
      createdAt: new Date(),
      updatedAt: new Date(),
    },
  ];

  const token = generateAccessToken({
    id: "student-2",
    email: "student2@school.edu.vn",
    role: "student",
  });

  const req = {
    headers: { authorization: `Bearer ${token}` },
    params: { id: "app-1" },
  };

  const res = await dispatch(applicationController.withdrawApplication, req, [
    authenticate,
    authorize("student"),
  ]);

  assert.equal(res.statusCode, 403);
  assert.equal(res.body.error.code, "FORBIDDEN");
});

test("PATCH /api/v1/applications/:id/withdraw từ chối khi đơn đã ở trạng thái withdrawn (400 ALREADY_WITHDRAWN)", async () => {
  applications = [
    {
      id: "app-1",
      jobId: "job-1",
      studentId: "student-1",
      cvId: "cv-1",
      status: "withdrawn",
      createdAt: new Date(),
      updatedAt: new Date(),
    },
  ];

  const token = generateAccessToken({
    id: "student-1",
    email: "student1@school.edu.vn",
    role: "student",
  });

  const req = {
    headers: { authorization: `Bearer ${token}` },
    params: { id: "app-1" },
  };

  const res = await dispatch(applicationController.withdrawApplication, req, [
    authenticate,
    authorize("student"),
  ]);

  assert.equal(res.statusCode, 400);
  assert.equal(res.body.error.code, "ALREADY_WITHDRAWN");
});

test("PATCH /api/v1/applications/:id/withdraw từ chối khi đơn đã có kết quả accepted/rejected (400 CANNOT_WITHDRAW)", async () => {
  applications = [
    {
      id: "app-1",
      jobId: "job-1",
      studentId: "student-1",
      cvId: "cv-1",
      status: "accepted",
      createdAt: new Date(),
      updatedAt: new Date(),
    },
  ];

  const token = generateAccessToken({
    id: "student-1",
    email: "student1@school.edu.vn",
    role: "student",
  });

  const req = {
    headers: { authorization: `Bearer ${token}` },
    params: { id: "app-1" },
  };

  const res = await dispatch(applicationController.withdrawApplication, req, [
    authenticate,
    authorize("student"),
  ]);

  assert.equal(res.statusCode, 400);
  assert.equal(res.body.error.code, "CANNOT_WITHDRAW");
});

test("PATCH /api/v1/applications/:id/withdraw trả về 404 khi ID không tồn tại", async () => {
  const token = generateAccessToken({
    id: "student-1",
    email: "student1@school.edu.vn",
    role: "student",
  });

  const req = {
    headers: { authorization: `Bearer ${token}` },
    params: { id: "non-existent-app" },
  };

  const res = await dispatch(applicationController.withdrawApplication, req, [
    authenticate,
    authorize("student"),
  ]);

  assert.equal(res.statusCode, 404);
  assert.equal(res.body.error.code, "APPLICATION_NOT_FOUND");
});

test("GET /api/v1/recruiter/applications/:id trả về chi tiết ứng viên và tự động đổi submitted -> viewed", async () => {
  applications = [
    {
      id: "app-1",
      jobId: "job-1",
      studentId: "student-1",
      cvId: "cv-1",
      status: "submitted",
      matchScore: 85,
      matchedSkills: ["Flutter"],
      missingSkills: ["Dart"],
      createdAt: new Date(),
      updatedAt: new Date(),
    },
  ];

  const token = generateAccessToken({
    id: "recruiter-1",
    email: "recruiter1@company.com",
    role: "recruiter",
  });

  const req = {
    headers: { authorization: `Bearer ${token}` },
    params: { id: "app-1" },
  };

  const res = await dispatch(applicationController.getRecruiterApplicationDetail, req, [
    authenticate,
    authorize("recruiter"),
  ]);

  assert.equal(res.statusCode, 200);
  assert.ok(res.body.data);
  assert.equal(res.body.data.id, "app-1");
  assert.equal(res.body.data.status, "viewed"); // Tự động chuyển submitted -> viewed
  assert.equal(applications[0].status, "viewed"); // DB đã được cập nhật
  assert.ok(res.body.data.student);
  assert.equal(res.body.data.student.fullName, "Nguyễn Văn Sinh Viên");
  assert.ok(res.body.data.cv);
  assert.equal(res.body.data.cv.fileName, "NguyenVanA_Flutter_CV.pdf");
});

test("GET /api/v1/recruiter/applications/:id giữ nguyên status nếu đơn đã là viewed hoặc accepted", async () => {
  applications = [
    {
      id: "app-1",
      jobId: "job-1",
      studentId: "student-1",
      cvId: "cv-1",
      status: "accepted",
      createdAt: new Date(),
      updatedAt: new Date(),
    },
  ];

  const token = generateAccessToken({
    id: "recruiter-1",
    email: "recruiter1@company.com",
    role: "recruiter",
  });

  const req = {
    headers: { authorization: `Bearer ${token}` },
    params: { id: "app-1" },
  };

  const res = await dispatch(applicationController.getRecruiterApplicationDetail, req, [
    authenticate,
    authorize("recruiter"),
  ]);

  assert.equal(res.statusCode, 200);
  assert.equal(res.body.data.status, "accepted");
  assert.equal(applications[0].status, "accepted");
});

test("GET /api/v1/recruiter/applications/:id từ chối với 403 khi recruiter không phải là chủ sở hữu Job", async () => {
  applications = [
    {
      id: "app-1",
      jobId: "job-1",
      studentId: "student-1",
      cvId: "cv-1",
      status: "submitted",
      createdAt: new Date(),
      updatedAt: new Date(),
    },
  ];

  const token = generateAccessToken({
    id: "recruiter-2",
    email: "recruiter2@other.com",
    role: "recruiter",
  });

  const req = {
    headers: { authorization: `Bearer ${token}` },
    params: { id: "app-1" },
  };

  const res = await dispatch(applicationController.getRecruiterApplicationDetail, req, [
    authenticate,
    authorize("recruiter"),
  ]);

  assert.equal(res.statusCode, 403);
  assert.equal(res.body.error.code, "FORBIDDEN");
});

test("GET /api/v1/recruiter/applications/:id trả về 404 khi đơn không tồn tại", async () => {
  const token = generateAccessToken({
    id: "recruiter-1",
    email: "recruiter1@company.com",
    role: "recruiter",
  });

  const req = {
    headers: { authorization: `Bearer ${token}` },
    params: { id: "non-existent-app" },
  };

  const res = await dispatch(applicationController.getRecruiterApplicationDetail, req, [
    authenticate,
    authorize("recruiter"),
  ]);

  assert.equal(res.statusCode, 404);
  assert.equal(res.body.error.code, "APPLICATION_NOT_FOUND");
});
