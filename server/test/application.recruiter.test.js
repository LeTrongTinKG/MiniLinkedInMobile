const assert = require("node:assert/strict");
const test = require("node:test");
const {
  applicationController,
  authenticate,
  authorize,
  dispatch,
  asRecruiter,
  USERS,
  resetStore,
  store,
} = require("./application.harness");

test.beforeEach(() => resetStore());

test("GET /recruiter/jobs/:jobId/applications từ chối khi thiếu token (401)", async () => {
  const res = await dispatch(
    applicationController.getJobApplications,
    { headers: {}, params: { jobId: "job-1" } },
    [authenticate, authorize("recruiter")]
  );
  assert.equal(res.statusCode, 401);
  assert.equal(res.body.error.code, "UNAUTHORIZED");
});

test("GET /recruiter/jobs/:jobId/applications từ chối sinh viên (403)", async () => {
  const res = await asRecruiter(
    applicationController.getJobApplications,
    { params: { jobId: "job-1" } },
    USERS.student1
  );
  assert.equal(res.statusCode, 403);
  assert.equal(res.body.error.code, "FORBIDDEN");
});

test("GET /recruiter/jobs/:jobId/applications từ chối recruiter không phải chủ job (403)", async () => {
  const res = await asRecruiter(
    applicationController.getJobApplications,
    { params: { jobId: "job-1" } },
    USERS.recruiter2
  );
  assert.equal(res.statusCode, 403);
  assert.equal(res.body.error.code, "FORBIDDEN");
});

test("GET /recruiter/jobs/:jobId/applications 404 khi job không tồn tại", async () => {
  const res = await asRecruiter(applicationController.getJobApplications, {
    params: { jobId: "missing" },
  });
  assert.equal(res.statusCode, 404);
  assert.equal(res.body.error.code, "JOB_NOT_FOUND");
});

test("GET /recruiter/jobs/:jobId/applications sắp xếp matchScore giảm dần", async () => {
  store.applications = [
    {
      id: "app-low",
      jobId: "job-1",
      studentId: "student-2",
      cvId: "cv-sv2",
      matchScore: 50,
      status: "submitted",
      createdAt: new Date("2026-10-10T08:00:00Z"),
      updatedAt: new Date(),
    },
    {
      id: "app-high",
      jobId: "job-1",
      studentId: "student-1",
      cvId: "cv-1",
      matchScore: 100,
      status: "submitted",
      createdAt: new Date("2026-10-10T09:00:00Z"),
      updatedAt: new Date(),
    },
    {
      id: "app-mid",
      jobId: "job-1",
      studentId: "student-2",
      cvId: "cv-sv2",
      matchScore: 75,
      status: "submitted",
      createdAt: new Date("2026-10-10T10:00:00Z"),
      updatedAt: new Date(),
    },
  ];
  const res = await asRecruiter(applicationController.getJobApplications, {
    params: { jobId: "job-1" },
  });
  assert.equal(res.statusCode, 200);
  assert.equal(res.body.data.length, 3);
  assert.equal(res.body.data[0].id, "app-high");
  assert.equal(res.body.data[1].id, "app-mid");
  assert.equal(res.body.data[2].id, "app-low");
  assert.equal(res.body.data[0].student.fullName, "Nguyễn Văn Sinh Viên");
  assert.equal(res.body.data[0].cv.fileName, "NguyenVanA_Flutter_CV.pdf");
});

test("GET /recruiter/applications?jobId= hỗ trợ query param", async () => {
  const res = await asRecruiter(applicationController.getJobApplications, {
    query: { jobId: "job-1" },
  });
  assert.equal(res.statusCode, 200);
  assert.ok(res.body.data);
  assert.ok(res.body.meta);
});

