const test = require("node:test");
const assert = require("node:assert/strict");
const { createCommitScanner } = require("../src/services/skills/commitScan");

const rules = [{
  name: "Dart",
  signals: { extensions: [".dart"], files: [], dependencies: {}, keywords: [], keywords_case_sensitive: [] },
}];

function listed(sha, date) {
  return { sha, author: { login: "minh" }, parents: [{}], commit: { author: { date } } };
}

test("đọc commit của đúng người và dừng khi đã đủ ngưỡng", async () => {
  const calls = [];
  const fetchImpl = async (url) => {
    calls.push(url);
    if (url.includes("/commits?")) {
      const dates = ["2026-01-01", "2026-01-02", "2026-01-03", "2026-01-10", "2026-01-20", "2026-02-01"];
      return { ok: true, status: 200, headers: new Map(), json: async () => dates.map((day, i) => listed(`c${i}`, `${day}T00:00:00Z`)) };
    }
    return {
      ok: true,
      status: 200,
      headers: new Map(),
      json: async () => ({ files: [{ filename: "lib/main.dart", additions: 50 }] }),
    };
  };
  const { commitsByRepo } = createCommitScanner({ fetchImpl, token: "" });
  const byRepo = await commitsByRepo({
    login: "minh",
    sources: [{ repo: "me/app", dependencies: {} }],
    rules,
  });
  const score = byRepo.get("me/app");
  assert.equal(score.validCommitCount, 5);
  assert.equal(score.linesAuthored, 250);
  assert.ok(score.skillNames.includes("Dart"));
  assert.equal(calls.length, 6);
});

test("GitHub hết lượt thì báo RATE_LIMITED, không trả điểm dở", async () => {
  const fetchImpl = async () => ({ ok: false, status: 403, headers: new Map([["x-ratelimit-remaining", "0"]]), json: async () => ({}) });
  const { commitsByRepo } = createCommitScanner({ fetchImpl, token: "" });
  await assert.rejects(
    commitsByRepo({ login: "minh", sources: [{ repo: "me/app", dependencies: {} }], rules }),
    { code: "RATE_LIMITED" },
  );
});
