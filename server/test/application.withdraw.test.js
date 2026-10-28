const assert = require("node:assert/strict");
const test = require("node:test");
const {
  applicationController,
  authenticate,
  authorize,
  dispatch,
  asStudent,
  USERS,
  seedApp,
  resetStore,
} = require("./application.harness");

test.beforeEach(() => resetStore());

test("PATCH /applications/:id/withdraw từ chối khi thiếu token (401)", async () => {
  const res = await dispatch(
    applicationController.withdrawApplication,
    { headers: {}, params: { id: "app-1" } },
    [authenticate, authorize("student")]
  );
  assert.equal(res.statusCode, 401);
  assert.equal(res.body.error.code, "UNAUTHORIZED");
});

test("PATCH /applications/:id/withdraw từ chối recruiter (403)", async () => {
  seedApp();
  const res = await asStudent(
    applicationController.withdrawApplication,
    { params: { id: "app-1" } },
    USERS.recruiter1
  );
  assert.equal(res.statusCode, 403);
  assert.equal(res.body.error.code, "FORBIDDEN");
});

test("PATCH /applications/:id/withdraw từ chối khi rút đơn của người khác (403)", async () => {
  seedApp();
  const res = await asStudent(
    applicationController.withdrawApplication,
    { params: { id: "app-1" } },
    USERS.student2
  );
  assert.equal(res.statusCode, 403);
  assert.equal(res.body.error.code, "FORBIDDEN");
});

test("PATCH /applications/:id/withdraw 400 khi đã rút", async () => {
  seedApp({ status: "withdrawn" });
  const res = await asStudent(applicationController.withdrawApplication, {
    params: { id: "app-1" },
  });
  assert.equal(res.statusCode, 400);
  assert.equal(res.body.error.code, "ALREADY_WITHDRAWN");
});

test("PATCH /applications/:id/withdraw 400 khi đơn đã accepted", async () => {
  seedApp({ status: "accepted" });
  const res = await asStudent(applicationController.withdrawApplication, {
    params: { id: "app-1" },
  });
  assert.equal(res.statusCode, 400);
  assert.equal(res.body.error.code, "CANNOT_WITHDRAW");
});

test("PATCH /applications/:id/withdraw 400 khi đơn đã rejected", async () => {
  seedApp({ status: "rejected" });
  const res = await asStudent(applicationController.withdrawApplication, {
    params: { id: "app-1" },
  });
  assert.equal(res.statusCode, 400);
  assert.equal(res.body.error.code, "CANNOT_WITHDRAW");
});

test("PATCH /applications/:id/withdraw 404 khi đơn không tồn tại", async () => {
  const res = await asStudent(applicationController.withdrawApplication, {
    params: { id: "missing" },
  });
  assert.equal(res.statusCode, 404);
  assert.equal(res.body.error.code, "APPLICATION_NOT_FOUND");
});

test("PATCH /applications/:id/withdraw rút thành công", async () => {
  const app = seedApp({ status: "submitted" });
  const res = await asStudent(applicationController.withdrawApplication, {
    params: { id: "app-1" },
  });
  assert.equal(res.statusCode, 200);
  assert.equal(res.body.data.status, "withdrawn");
  assert.equal(app.status, "withdrawn");
});

