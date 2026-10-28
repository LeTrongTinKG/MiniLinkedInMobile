const assert = require("node:assert/strict");
const test = require("node:test");
const {
  applicationController,
  authenticate,
  authorize,
  dispatch,
  asStudent,
  USERS,
  resetStore,
  store,
} = require("./application.harness");

test.beforeEach(() => resetStore());

test("POST /applications từ chối khi thiếu token (401)", async () => {
  const res = await dispatch(
    applicationController.applyJob,
    { headers: {}, body: { jobId: "job-1" } },
    [authenticate, authorize("student")]
  );
  assert.equal(res.statusCode, 401);
  assert.equal(res.body.error.code, "UNAUTHORIZED");
});

test("POST /applications từ chối recruiter (403)", async () => {
  const res = await asStudent(applicationController.applyJob, { body: { jobId: "job-1" } }, {
    id: "recruiter-1",
    email: "recruiter1@company.com",
    role: "recruiter",
  });
  assert.equal(res.statusCode, 403);
  assert.equal(res.body.error.code, "FORBIDDEN");
});

test("POST /applications 400 khi thiếu jobId", async () => {
  const res = await asStudent(applicationController.applyJob, { body: {} });
  assert.equal(res.statusCode, 400);
  assert.equal(res.body.error.code, "INVALID_INPUT");
});

test("POST /applications 404 khi job không tồn tại", async () => {
  const res = await asStudent(applicationController.applyJob, { body: { jobId: "missing" } });
  assert.equal(res.statusCode, 404);
  assert.equal(res.body.error.code, "JOB_NOT_FOUND");
});

test("POST /applications 400 khi job đã đóng", async () => {
  const res = await asStudent(applicationController.applyJob, { body: { jobId: "job-closed" } });
  assert.equal(res.statusCode, 400);
  assert.equal(res.body.error.code, "JOB_CLOSED");
});

test("POST /applications 400 khi sinh viên chưa có CV", async () => {
  const res = await asStudent(
    applicationController.applyJob,
    { body: { jobId: "job-1" } },
    { id: "student-no-cv", email: "nocv@school.edu.vn", role: "student" }
  );
  assert.equal(res.statusCode, 400);
  assert.equal(res.body.error.code, "NO_CV_FOUND");
});

test("POST /applications 403 khi dùng CV của sinh viên khác", async () => {
  const res = await asStudent(applicationController.applyJob, {
    body: { jobId: "job-1", cvId: "cv-sv2" },
  });
  assert.equal(res.statusCode, 403);
  assert.equal(res.body.error.code, "FORBIDDEN");
});

test("POST /applications nộp thành công với CV chỉ định", async () => {
  const res = await asStudent(applicationController.applyJob, {
    body: { jobId: "job-1", cvId: "cv-1" },
  });
  assert.equal(res.statusCode, 201);
  assert.equal(res.body.data.jobId, "job-1");
  assert.equal(res.body.data.studentId, "student-1");
  assert.equal(res.body.data.cvId, "cv-1");
  assert.equal(res.body.data.status, "submitted");
  assert.equal(typeof res.body.data.matchScore, "number");
});

test("POST /applications dùng CV mặc định khi không truyền cvId", async () => {
  const res = await asStudent(applicationController.applyJob, { body: { jobId: "job-1" } });
  assert.equal(res.statusCode, 201);
  assert.equal(res.body.data.cvId, "cv-1");
});

test("POST /applications 409 khi ứng tuyển lần 2 vào cùng job", async () => {
  const body = { jobId: "job-1", cvId: "cv-1" };
  const first = await asStudent(applicationController.applyJob, { body });
  assert.equal(first.statusCode, 201);
  const second = await asStudent(applicationController.applyJob, {
    body: { jobId: "job-1", cvId: "cv-2" },
  });
  assert.equal(second.statusCode, 409);
  assert.equal(second.body.error.code, "ALREADY_APPLIED");
});

test("POST /applications lưu matchScore null khi AI lỗi", async () => {
  const aiClient = require("../src/services/ai/aiClient");
  const original = aiClient.match;
  aiClient.match = async () => {
    throw new Error("AI Match Timeout");
  };
  try {
    const res = await asStudent(applicationController.applyJob, {
      body: { jobId: "job-1", cvId: "cv-1" },
    });
    assert.equal(res.statusCode, 201);
    assert.equal(res.body.data.matchScore, null);
    assert.equal(store.applications[0].matchScore, null);
  } finally {
    aiClient.match = original;
  }
});

test("GET /applications/my từ chối khi thiếu token (401)", async () => {
  const res = await dispatch(applicationController.getMyApplications, { headers: {} }, [
    authenticate,
    authorize("student"),
  ]);
  assert.equal(res.statusCode, 401);
  assert.equal(res.body.error.code, "UNAUTHORIZED");
});

test("GET /applications/my trả đơn của sinh viên đang đăng nhập", async () => {
  store.applications = [
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
  const res = await asStudent(applicationController.getMyApplications, {});
  assert.equal(res.statusCode, 200);
  assert.equal(res.body.data.length, 1);
  assert.equal(res.body.data[0].job.title, "Flutter Fresher Developer");
});

test("GET /applications/my từ chối recruiter (403)", async () => {
  const res = await asStudent(applicationController.getMyApplications, {}, USERS.recruiter1);
  assert.equal(res.statusCode, 403);
});
