const test = require("node:test");
const assert = require("node:assert/strict");
const { createGithubReader, MAX_REPOS } = require("../src/services/skills/githubReader");

const ok = (body) => ({ ok: true, status: 200, headers: new Map(), json: async () => body });
const fail = (status, remaining) => ({
  ok: false,
  status,
  headers: new Map([["x-ratelimit-remaining", remaining]]),
  json: async () => ({}),
});

const b64 = (text) => Buffer.from(text).toString("base64");

function fakeGithub(routes) {
  const calls = [];
  const fetchImpl = async (url) => {
    const path = url.replace("https://api.github.com", "");
    calls.push(path);
    const hit = Object.keys(routes).find((p) => path.startsWith(p));
    return hit ? routes[hit] : fail(404, "50");
  };
  return { fetchImpl, calls };
}

const repoRow = (name, extra = {}) => ({
  full_name: `me/${name}`,
  html_url: `https://github.com/me/${name}`,
  default_branch: "main",
  topics: [],
  ...extra,
});

test("đọc repo của chính tài khoản: bỏ fork, bỏ repo lưu trữ, tối đa 5 repo", async () => {
  const many = Array.from({ length: 8 }, (_, i) => repoRow(`r${i}`));
  const { fetchImpl } = fakeGithub({
    "/user/42": ok({ login: "me" }),
    "/users/me/repos": ok([repoRow("fork", { fork: true }), repoRow("old", { archived: true }), ...many]),
    "/repos/": ok({}),
  });
  const sources = await createGithubReader({ fetchImpl, token: "" }).readOwnRepos("42");
  assert.equal(sources.length, MAX_REPOS);
  assert.ok(sources.every((s) => !["me/fork", "me/old"].includes(s.repo)));
});

test("đọc pubspec.yaml và README ở gốc repo", async () => {
  const { fetchImpl } = fakeGithub({
    "/user/42": ok({ login: "me" }),
    "/users/me/repos": ok([repoRow("app", { topics: ["flutter"] })]),
    "/repos/me/app/languages": ok({ Dart: 900, Swift: 100 }),
    "/repos/me/app/contents/?": ok([
      { type: "file", name: "pubspec.yaml" },
      { type: "file", name: "README.md" },
      { type: "dir", name: "lib" },
    ]),
    "/repos/me/app/contents/pubspec.yaml": ok({ content: b64("dependencies:\n  flutter:\n    sdk: flutter\n") }),
    "/repos/me/app/contents/README.md": ok({ content: b64("A Flutter app") }),
  });
  const [source] = await createGithubReader({ fetchImpl, token: "" }).readOwnRepos("42");
  assert.equal(source.repo, "me/app");
  assert.deepEqual(source.rootFiles, ["pubspec.yaml", "README.md"]);
  assert.deepEqual(source.dependencies.pub, ["flutter"]);
  assert.equal(source.text, "A Flutter app");
  assert.deepEqual(source.topics, ["flutter"]);
});

test("GitHub hết lượt gọi thì báo RATE_LIMITED", async () => {
  const { fetchImpl } = fakeGithub({ "/user/42": fail(403, "0") });
  await assert.rejects(createGithubReader({ fetchImpl, token: "" }).readOwnRepos("42"), { code: "RATE_LIMITED" });
});

test("mất mạng thì báo GITHUB_UNAVAILABLE", async () => {
  const fetchImpl = async () => {
    throw new Error("network down");
  };
  await assert.rejects(createGithubReader({ fetchImpl, token: "" }).readOwnRepos("42"), {
    code: "GITHUB_UNAVAILABLE",
  });
});
