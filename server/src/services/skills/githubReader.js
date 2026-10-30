// Đọc repo công khai trên GitHub để lấy dấu hiệu skill. Chép từ Atom: _shared/read_repo.ts.
// Chỉ đọc file gốc của repo: ngôn ngữ, chủ đề, tên file, pubspec.yaml, package.json, README.
const { parsePubspec, parsePackageJson } = require("./extractRules");

// Không có token: GitHub cho 60 lượt/giờ mỗi IP; một lần quét tối đa 2 + 5 × 5 = 27 lượt.
const MAX_REPOS = 5;
const TIMEOUT_MS = 8000;
const MANIFESTS = { "pubspec.yaml": "pub", "package.json": "npm" };

class GithubError extends Error {
  constructor(code) {
    super(code);
    this.code = code;
  }
}

function errorFor(response) {
  if (response.status === 404) return new GithubError("NOT_FOUND");
  const remaining = response.headers.get("x-ratelimit-remaining");
  if (response.status === 429 || (response.status === 403 && remaining === "0")) {
    return new GithubError("RATE_LIMITED");
  }
  return new GithubError("GITHUB_UNAVAILABLE");
}

function createGithubReader({ fetchImpl = fetch, token = process.env.GITHUB_READ_TOKEN } = {}) {
  const headers = { Accept: "application/vnd.github+json", "User-Agent": "minilinkedin" };
  if (token) headers.Authorization = `Bearer ${token}`;

  async function get(path, { allow404 = false } = {}) {
    let response;
    try {
      response = await fetchImpl(`https://api.github.com${path}`, {
        headers,
        signal: AbortSignal.timeout(TIMEOUT_MS),
      });
    } catch {
      throw new GithubError("GITHUB_UNAVAILABLE");
    }
    if (allow404 && response.status === 404) return null;
    if (!response.ok) throw errorFor(response);
    return response.json();
  }

  // githubId lấy từ lúc đăng nhập GitHub nên chắc chắn là tài khoản của chính người dùng.
  async function loginForId(githubId) {
    const user = await get(`/user/${encodeURIComponent(githubId)}`);
    if (typeof user?.login !== "string") throw new GithubError("GITHUB_UNAVAILABLE");
    return user.login;
  }

  async function listOwnRepos(login) {
    const repos = await get(`/users/${encodeURIComponent(login)}/repos?type=owner&sort=pushed&per_page=30`);
    if (!Array.isArray(repos)) throw new GithubError("GITHUB_UNAVAILABLE");
    return repos.filter((r) => !r.fork && !r.archived && typeof r.full_name === "string").slice(0, MAX_REPOS);
  }

  async function readRepo(repo) {
    const encoded = repo.full_name.split("/").map(encodeURIComponent).join("/");
    const branch = encodeURIComponent(repo.default_branch || "HEAD");
    const languageBytes = (await get(`/repos/${encoded}/languages`, { allow404: true })) ?? {};
    const root = (await get(`/repos/${encoded}/contents/?ref=${branch}`, { allow404: true })) ?? [];
    const rootFiles = (Array.isArray(root) ? root : [])
      .filter((item) => item?.type === "file" && typeof item.name === "string")
      .map((item) => item.name);
    const dependencies = {};
    let text = "";
    for (const name of rootFiles) {
      const ecosystem = MANIFESTS[name];
      const isReadme = name.toLowerCase().startsWith("readme");
      if (!ecosystem && !isReadme) continue;
      const file = await get(`/repos/${encoded}/contents/${encodeURIComponent(name)}?ref=${branch}`, {
        allow404: true,
      });
      if (typeof file?.content !== "string") continue;
      const decoded = Buffer.from(file.content.replace(/\n/g, ""), "base64").toString("utf8");
      if (ecosystem === "pub") dependencies.pub = parsePubspec(decoded);
      if (ecosystem === "npm") dependencies.npm = parsePackageJson(decoded);
      if (isReadme) text = decoded.slice(0, 4000);
    }
    return {
      repo: repo.full_name,
      url: repo.html_url,
      languageBytes,
      topics: Array.isArray(repo.topics) ? repo.topics : [],
      rootFiles,
      dependencies,
      text,
    };
  }

  async function readOwnRepos(githubId) {
    const login = await loginForId(githubId);
    const repos = await listOwnRepos(login);
    const sources = [];
    for (const repo of repos) sources.push(await readRepo(repo));
    return sources;
  }

  return { readOwnRepos };
}

module.exports = { createGithubReader, GithubError, MAX_REPOS };
