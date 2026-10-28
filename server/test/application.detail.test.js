const assert = require("node:assert/strict");
const test = require("node:test");
const {
  applicationController,
  authenticate,
  authorize,
  dispatch,
  asRecruiter,
  USERS,
  seedApp,
  resetStore,
} = require("./application.harness");

test.beforeEach(() => resetStore());

test("GET /recruiter/applications/:id từ chối khi thiếu token (401)", async () => {
  const res = await dispatch(
    applicationController.getRecruiterApplicationDetail,
    { headers: {}, params: { id: "app-1" } },
    [authenticate, authorize("recruiter")]
  );
  assert.equal(res.statusCode, 401);
  assert.equal(res.body.error.code, "UNAUTHORIZED");
});

test("GET /recruiter/applications/:id từ chối recruiter không phải chủ job (403)", async () => {
  seedApp();
  const res = await asRecruiter(
    applicationController.getRecruiterApplicationDetail,
    { params: { id: "app-1" } },
    USERS.recruiter2
  );
  assert.equal(res.statusCode, 403);
  assert.equal(res.body.error.code, "FORBIDDEN");
});

test("GET /recruiter/applications/:id 404 khi đơn không tồn tại", async () => {
  const res = await asRecruiter(applicationController.getRecruiterApplicationDetail, {
    params: { id: "missing" },
  });
  assert.equal(res.statusCode, 404);
  assert.equal(res.body.error.code, "APPLICATION_NOT_FOUND");
});

test("GET /recruiter/applications/:id tự chuyển submitted -> viewed", async () => {
  const app = seedApp({ status: "submitted" });
  const res = await asRecruiter(applicationController.getRecruiterApplicationDetail, {
    params: { id: "app-1" },
  });
  assert.equal(res.statusCode, 200);
  assert.equal(res.body.data.id, "app-1");
  assert.equal(res.body.data.status, "viewed");
  assert.equal(app.status, "viewed");
  assert.equal(res.body.data.student.fullName, "Nguyễn Văn Sinh Viên");
  assert.equal(res.body.data.cv.fileName, "NguyenVanA_Flutter_CV.pdf");
});

test("GET /recruiter/applications/:id giữ viewed khi đã xem", async () => {
  seedApp({ status: "viewed" });
  const res = await asRecruiter(applicationController.getRecruiterApplicationDetail, {
    params: { id: "app-1" },
  });
  assert.equal(res.statusCode, 200);
  assert.equal(res.body.data.status, "viewed");
});

test("GET /recruiter/applications/:id giữ shortlisted", async () => {
  seedApp({ status: "shortlisted" });
  const res = await asRecruiter(applicationController.getRecruiterApplicationDetail, {
    params: { id: "app-1" },
  });
  assert.equal(res.statusCode, 200);
  assert.equal(res.body.data.status, "shortlisted");
});

test("GET /recruiter/applications/:id giữ accepted", async () => {
  seedApp({ status: "accepted" });
  const res = await asRecruiter(applicationController.getRecruiterApplicationDetail, {
    params: { id: "app-1" },
  });
  assert.equal(res.statusCode, 200);
  assert.equal(res.body.data.status, "accepted");
});
