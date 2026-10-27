const assert = require("node:assert/strict");
const test = require("node:test");
const repo = require("../src/repositories/recruiter-application.repository");
const { getAllApplications } = require("../src/services/recruiter-application.service");

const recruiter = { userId: "rec-1", role: "recruiter" };

test("getAllApplications: chỉ recruiter mới được xem (student bị 403)", async () => {
  await assert.rejects(
    () => getAllApplications({ userId: "stu-1", role: "student" }, {}),
    (err) => err.statusCode === 403 || err.status === 403
  );
});

test("getAllApplications: lọc theo recruiter đang đăng nhập và trả meta phân trang", async () => {
  const origFind = repo.findApplicationsByRecruiterId;
  const origCount = repo.countApplicationsByRecruiterId;
  let received;
  repo.findApplicationsByRecruiterId = async (p) => ((received = p), [{ id: "a1" }]);
  repo.countApplicationsByRecruiterId = async () => 1;
  try {
    const result = await getAllApplications(recruiter, { status: "submitted", page: "1", limit: "5" });
    assert.equal(received.recruiterId, "rec-1");
    assert.equal(received.status, "submitted");
    assert.deepEqual(result.pagination, { page: 1, limit: 5, total: 1 });
    assert.equal(result.items.length, 1);
  } finally {
    repo.findApplicationsByRecruiterId = origFind;
    repo.countApplicationsByRecruiterId = origCount;
  }
});
