const test = require("node:test");
const assert = require("node:assert/strict");
const skillService = require("../src/services/skill.service");
const { GithubError } = require("../src/services/skills/githubReader");

function fakeRepo({ githubId = "42", skills = [], suggestions = [] } = {}) {
  const calls = { upserts: [], accepted: [], rejected: [], finished: [] };
  return {
    calls,
    findGithubId: async () => githubId,
    listSkills: async () => skills,
    listSuggestions: async (_userId, statuses) => suggestions.filter((s) => statuses.includes(s.status)),
    upsertPending: async (userId, skillName, evidence) => {
      calls.upserts.push({ userId, skillName, evidence });
    },
    findSuggestionById: async (id) => suggestions.find((s) => s.id === id) ?? null,
    beginScan: async () => ({ ok: true, scan: { id: "scan-1" } }),
    finishScan: async (_id, status) => {
      calls.finished.push(status);
    },
    acceptSuggestion: async (s, level) => {
      calls.accepted.push({ id: s.id, ...level });
      return { skillName: s.skillName, source: "github", evidence: s.evidence, ...level };
    },
    rejectSuggestion: async (id) => calls.rejected.push(id),
  };
}

const flutterRepo = {
  repo: "me/app",
  url: "https://github.com/me/app",
  languageBytes: { Dart: 100 },
  dependencies: { pub: ["flutter", "provider"] },
};
const reader = (sources) => ({ readOwnRepos: async () => sources });

test("chưa đăng nhập GitHub lần nào thì không quét được", async () => {
  await assert.rejects(skillService.scanGithub("u1", fakeRepo({ githubId: null }), reader([])), {
    code: "GITHUB_NOT_LINKED",
    statusCode: 400,
  });
});

test("quét GitHub lưu đề xuất kèm bằng chứng, bỏ skill đã có hoặc đã từ chối", async () => {
  const repo = fakeRepo({
    skills: [{ skillName: "Flutter" }],
    suggestions: [{ id: "s1", skillName: "Provider", status: "rejected" }],
  });
  await skillService.scanGithub("u1", repo, reader([flutterRepo]));
  assert.deepEqual(repo.calls.upserts.map((u) => u.skillName), ["Dart"]);
  assert.deepEqual(repo.calls.upserts[0].evidence, [
    { repo: "me/app", url: "https://github.com/me/app", signals: ["language:Dart"] },
  ]);
  assert.deepEqual(repo.calls.finished, ["succeeded"]);
});

test("GitHub giới hạn lượt gọi thì trả 429", async () => {
  const failing = { readOwnRepos: async () => Promise.reject(new GithubError("RATE_LIMITED")) };
  await assert.rejects(skillService.scanGithub("u1", fakeRepo(), failing), { code: "RATE_LIMITED", statusCode: 429 });
});

test("không duyệt được đề xuất của người khác", async () => {
  const repo = fakeRepo({ suggestions: [{ id: "s1", userId: "u2", status: "pending" }] });
  await assert.rejects(skillService.decideSuggestion("u1", "s1", true, repo), { statusCode: 403 });
  assert.deepEqual(repo.calls.accepted, []);
});

test("hết lượt quét thì không gọi GitHub", async () => {
  let called = false;
  const repo = fakeRepo();
  repo.beginScan = async () => ({ ok: false, code: "QUOTA_EXCEEDED", resetsAt: new Date("2026-11-01T00:00:00+07:00") });
  await assert.rejects(
    skillService.scanGithub("u1", repo, { readOwnRepos: async () => { called = true; return []; } }),
    { code: "QUOTA_EXCEEDED", statusCode: 429 },
  );
  assert.equal(called, false);
});

test("không có repo công khai thì lượt quét không tính", async () => {
  const repo = fakeRepo();
  await assert.rejects(skillService.scanGithub("u1", repo, reader([])), { code: "NO_REPOS", statusCode: 422 });
  assert.deepEqual(repo.calls.finished, ["failed"]);
});

test("đề xuất đã duyệt rồi thì không duyệt lại", async () => {
  const repo = fakeRepo({ suggestions: [{ id: "s1", userId: "u1", status: "rejected" }] });
  await assert.rejects(skillService.decideSuggestion("u1", "s1", true, repo), { code: "SUGGESTION_DECIDED" });
});

test("đồng ý thì skill vào hồ sơ kèm bằng chứng; từ chối thì không", async () => {
  const evidence = [{ repo: "me/app", url: "u", signals: ["language:Dart"] }];
  const repo = fakeRepo({
    suggestions: [
      { id: "s1", userId: "u1", status: "pending", skillName: "Dart", evidence },
      { id: "s2", userId: "u1", status: "pending", skillName: "Go", evidence },
    ],
  });
  const skill = await skillService.decideSuggestion("u1", "s1", true, repo);
  assert.deepEqual(skill.evidence, evidence);
  assert.equal(skill.confidence, "self_claimed");
  await skillService.decideSuggestion("u1", "s2", false, repo);
  assert.deepEqual(repo.calls.accepted, [{ id: "s1", confidence: "self_claimed", reason: "weak_only" }]);
  assert.deepEqual(repo.calls.rejected, ["s2"]);
});

test("đề xuất không tồn tại trả 404", async () => {
  await assert.rejects(skillService.decideSuggestion("u1", "nope", true, fakeRepo()), { statusCode: 404 });
});
