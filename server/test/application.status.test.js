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

test("PATCH /recruiter/applications/:id/status từ chối khi thiếu token (401)", async () => {
  const res = await dispatch(
    applicationController.updateApplicationStatus,
    { headers: {}, params: { id: "app-1" }, body: { status: "accepted" } },
    [authenticate, authorize("recruiter")]
  );
  assert.equal(res.statusCode, 401);
  assert.equal(res.body.error.code, "UNAUTHORIZED");
});

test("PATCH /recruiter/applications/:id/status từ chối recruiter khác (403)", async () => {
  seedApp();
  const res = await asRecruiter(
    applicationController.updateApplicationStatus,
    { params: { id: "app-1" }, body: { status: "accepted" } },
    USERS.recruiter2
  );
  assert.equal(res.statusCode, 403);
  assert.equal(res.body.error.code, "FORBIDDEN");
});

test("PATCH /recruiter/applications/:id/status 400 khi status không hợp lệ", async () => {
  seedApp();
  const res = await asRecruiter(applicationController.updateApplicationStatus, {
    params: { id: "app-1" },
    body: { status: "invalid_status" },
  });
  assert.equal(res.statusCode, 400);
  assert.equal(res.body.error.code, "INVALID_STATUS");
});

test("PATCH /recruiter/applications/:id/status 400 CANNOT_UPDATE_WITHDRAWN", async () => {
  seedApp({ status: "withdrawn" });
  const res = await asRecruiter(applicationController.updateApplicationStatus, {
    params: { id: "app-1" },
    body: { status: "accepted" },
  });
  assert.equal(res.statusCode, 400);
  assert.equal(res.body.error.code, "CANNOT_UPDATE_WITHDRAWN");
});

test("PATCH /recruiter/applications/:id/status 400 CANNOT_UPDATE_FINALIZED khi accepted", async () => {
  seedApp({ status: "accepted" });
  const res = await asRecruiter(applicationController.updateApplicationStatus, {
    params: { id: "app-1" },
    body: { status: "rejected" },
  });
  assert.equal(res.statusCode, 400);
  assert.equal(res.body.error.code, "CANNOT_UPDATE_FINALIZED");
});

test("PATCH /recruiter/applications/:id/status 400 CANNOT_UPDATE_FINALIZED khi rejected", async () => {
  seedApp({ status: "rejected" });
  const res = await asRecruiter(applicationController.updateApplicationStatus, {
    params: { id: "app-1" },
    body: { status: "accepted" },
  });
  assert.equal(res.statusCode, 400);
  assert.equal(res.body.error.code, "CANNOT_UPDATE_FINALIZED");
});

test("PATCH /recruiter/applications/:id/status 400 khi chuyển shortlisted -> viewed", async () => {
  seedApp({ status: "shortlisted" });
  const res = await asRecruiter(applicationController.updateApplicationStatus, {
    params: { id: "app-1" },
    body: { status: "viewed" },
  });
  assert.equal(res.statusCode, 400);
  assert.equal(res.body.error.code, "INVALID_STATUS_TRANSITION");
});

test("PATCH /recruiter/applications/:id/status duyệt submitted -> accepted", async () => {
  const app = seedApp({ status: "submitted" });
  const res = await asRecruiter(applicationController.updateApplicationStatus, {
    params: { id: "app-1" },
    body: { status: "accepted" },
  });
  assert.equal(res.statusCode, 200);
  assert.equal(res.body.data.status, "accepted");
  assert.equal(app.status, "accepted");
});

test("PATCH /recruiter/applications/:id/status duyệt viewed -> shortlisted", async () => {
  seedApp({ status: "viewed" });
  const res = await asRecruiter(applicationController.updateApplicationStatus, {
    params: { id: "app-1" },
    body: { status: "shortlisted" },
  });
  assert.equal(res.statusCode, 200);
  assert.equal(res.body.data.status, "shortlisted");
});
