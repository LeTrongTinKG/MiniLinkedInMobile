const test = require("node:test");
const assert = require("node:assert/strict");
const { confidenceFromEvidence } = require("../src/services/skills/confidence");
const { monthWindow, SCAN_LIMIT } = require("../src/services/skills/scanQuota");
const { ignoredGeneratedPath, scoreAuthorCommits } = require("../src/services/skills/scoreCommits");
const { mergeMatchSkills } = require("../src/utils/application.util");

const dart = { name: "Dart", extensions: [".dart"], files: [], dependencies: [] };
const strong = {
  validCommitCount: 5,
  linesAuthored: 200,
  firstCommitAt: "2026-01-01T00:00:00Z",
  lastCommitAt: "2026-01-20T00:00:00Z",
};

function commit(partial) {
  return {
    authorLogin: "minh",
    parentCount: 1,
    files: [{ filename: "lib/main.dart", additions: 40 }],
    ...partial,
  };
}

test("bỏ file sinh tự động, file khóa, và commit không phải của mình", () => {
  assert.equal(ignoredGeneratedPath("vendor/lib/foo.dart"), true);
  assert.equal(ignoredGeneratedPath("pubspec.lock"), true);
  assert.equal(ignoredGeneratedPath("lib/main.g.dart"), true);
  assert.equal(ignoredGeneratedPath("lib/main.dart"), false);
  const score = scoreAuthorCommits({
    login: "Minh",
    repoDependencies: [],
    skills: [dart],
    commits: [
      commit({ sha: "1", date: "2026-01-01T00:00:00Z", authorLogin: "other" }),
      commit({ sha: "2", date: "2026-01-02T00:00:00Z", parentCount: 2 }),
      commit({ sha: "3", date: "2026-01-03T00:00:00Z", files: [{ filename: "lib/main.dart", additions: 0 }] }),
      commit({ sha: "4", date: "2026-01-04T00:00:00Z" }),
    ],
  });
  assert.equal(score.validCommitCount, 1);
  assert.deepEqual(score.skillNames, ["Dart"]);
});

test("commit đầu hơn 1000 dòng chỉ bị bỏ khi đã đọc tới gốc", () => {
  const commits = [
    commit({ sha: "root", date: "2026-01-01T00:00:00Z", files: [{ filename: "lib/main.dart", additions: 1001 }] }),
    commit({ sha: "a", date: "2026-01-02T00:00:00Z", files: [{ filename: "lib/main.dart", additions: 10 }] }),
  ];
  const atRoot = scoreAuthorCommits({ login: "minh", repoDependencies: [], skills: [dart], commits, reachedRoot: true });
  assert.equal(atRoot.validCommitCount, 1);
  assert.equal(atRoot.linesAuthored, 10);
  const cut = scoreAuthorCommits({ login: "minh", repoDependencies: [], skills: [dart], commits, reachedRoot: false });
  assert.equal(cut.validCommitCount, 2);
});

test("một repo đủ ngưỡng và có thư viện thì mức là evidenced", () => {
  const level = confidenceFromEvidence([
    { repo: "me/app", signals: ["dependency:pub:flutter"], commits: strong },
  ]);
  assert.deepEqual(level, { confidence: "evidenced", reason: "evidenced" });
});

test("commit mạnh nhưng không có tín hiệu độc lập thì vẫn tự khai", () => {
  const level = confidenceFromEvidence([
    { repo: "me/app", signals: ["keyword:dart"], commits: strong },
  ]);
  assert.equal(level.reason, "strong_no_independent");
  assert.equal(level.confidence, "self_claimed");
});

test("hai repo cùng đủ ngưỡng thì evidenced dù không có thư viện", () => {
  const level = confidenceFromEvidence([
    { repo: "me/a", signals: ["language:Dart"], commits: strong },
    { repo: "me/b", signals: ["language:Dart"], commits: strong },
  ]);
  assert.equal(level.confidence, "evidenced");
});

test("chỉ có chữ trong README thì không phải evidenced", () => {
  const level = confidenceFromEvidence([{ repo: "me/a", signals: ["keyword:flutter"] }]);
  assert.equal(level.reason, "weak_only");
});

test("hạn mức là 3 lần, tháng tính theo giờ Việt Nam", () => {
  assert.equal(SCAN_LIMIT, 3);
  const october = monthWindow(new Date("2026-10-31T16:00:00Z"));
  assert.equal(october.start.toISOString(), "2026-09-30T17:00:00.000Z");
  assert.equal(october.resetsAt.toISOString(), "2026-10-31T17:00:00.000Z");
  const november = monthWindow(new Date("2026-10-31T17:00:00Z"));
  assert.equal(november.start.toISOString(), "2026-10-31T17:00:00.000Z");
});

test("chấm job gộp skill CV và skill đã duyệt, không tính trùng", () => {
  assert.deepEqual(mergeMatchSkills(["Flutter", "git"], ["flutter", "Dart"]), ["Flutter", "git", "Dart"]);
  assert.deepEqual(mergeMatchSkills([], ["React"]), ["React"]);
  assert.deepEqual(mergeMatchSkills(null, ["  "]), []);
});
