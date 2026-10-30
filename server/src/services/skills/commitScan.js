// Đọc lịch sử commit trên GitHub. Chép từ Atom (commit_signals.ts), bỏ bước đọc lại file khai báo
// vì githubReader đã đọc pubspec.yaml và package.json ở gốc repo.
const { GithubError } = require("./githubReader");
const { scoreAuthorCommits, scanMeetsEvidenceBar } = require("./scoreCommits");

const BUDGET = { maxCalls: 240, maxDetailsPerRepo: 20, listPageSize: 100, callTimeoutMs: 8000 };

function pathRules(rules) {
  return rules.map((rule) => ({
    name: rule.name,
    extensions: rule.signals.extensions ?? [],
    files: rule.signals.files ?? [],
    dependencies: Object.values(rule.signals.dependencies ?? {}).flat(),
  }));
}

function codeFor(response) {
  if (response.status === 404) return "NOT_FOUND";
  const remaining = response.headers.get("x-ratelimit-remaining");
  if (response.status === 429 || (response.status === 403 && remaining === "0")) return "RATE_LIMITED";
  return "GITHUB_UNAVAILABLE";
}

function createCommitScanner({ fetchImpl = fetch, token = process.env.GITHUB_READ_TOKEN } = {}) {
  const headers = { Accept: "application/vnd.github+json", "User-Agent": "minilinkedin" };
  if (token) headers.Authorization = `Bearer ${token}`;

  async function get(budget, path) {
    if (budget.used >= BUDGET.maxCalls) throw new GithubError("RATE_LIMITED");
    budget.used += 1;
    let response;
    try {
      response = await fetchImpl(`https://api.github.com${path}`, {
        headers,
        signal: AbortSignal.timeout(BUDGET.callTimeoutMs),
      });
    } catch {
      throw new GithubError("GITHUB_UNAVAILABLE");
    }
    if (!response.ok) throw new GithubError(codeFor(response));
    return response.json();
  }

  async function scoreRepo(budget, source, login, skills) {
    const encoded = source.repo.split("/").map(encodeURIComponent).join("/");
    const deps = Object.values(source.dependencies ?? {}).flat();
    const body = await get(
      budget,
      `/repos/${encoded}/commits?author=${encodeURIComponent(login)}&per_page=${BUDGET.listPageSize}`,
    );
    if (!Array.isArray(body)) throw new GithubError("GITHUB_UNAVAILABLE");
    const wanted = login.toLowerCase();
    const candidates = body.filter((item) => {
      const author = item.author?.login?.toLowerCase();
      const parents = Array.isArray(item.parents) ? item.parents.length : 1;
      return item.sha && author === wanted && parents <= 1 && item.commit?.author?.date;
    });
    const detailed = [];
    let stoppedEarly = false;
    for (const item of candidates) {
      if (detailed.length >= BUDGET.maxDetailsPerRepo) {
        stoppedEarly = true;
        break;
      }
      const provisional = scoreAuthorCommits({
        login, commits: detailed, skills, repoDependencies: deps, reachedRoot: false,
      });
      if (provisional && scanMeetsEvidenceBar(provisional)) {
        stoppedEarly = true;
        break;
      }
      const payload = await get(budget, `/repos/${encoded}/commits/${item.sha}`);
      detailed.push({
        sha: item.sha,
        authorLogin: item.author?.login ?? null,
        date: item.commit?.author?.date ?? "",
        parentCount: 1,
        files: (payload.files ?? [])
          .filter((file) => typeof file.filename === "string")
          .map((file) => ({ filename: file.filename, additions: file.additions ?? 0 })),
      });
    }
    const reachedRoot = body.length < BUDGET.listPageSize && detailed.length === candidates.length && !stoppedEarly;
    return scoreAuthorCommits({
      login,
      commits: detailed.filter((commit) => commit.date !== ""),
      skills,
      repoDependencies: deps,
      reachedRoot,
    });
  }

  // Map repo -> điểm commit. Ném GithubError nếu GitHub chặn giữa chừng (lượt quét không tính).
  async function commitsByRepo({ login, sources, rules }) {
    const skills = pathRules(rules);
    const budget = { used: 0 };
    const byRepo = new Map();
    for (const source of sources) {
      const score = await scoreRepo(budget, source, login, skills);
      if (score) byRepo.set(source.repo, score);
    }
    return byRepo;
  }

  return { commitsByRepo };
}

function attachCommits(suggestions, byRepo) {
  return suggestions.map((suggestion) => ({
    ...suggestion,
    evidence: suggestion.evidence.map((item) => {
      const score = byRepo.get(item.repo);
      const named = score?.skillNames.some((name) => name.toLowerCase() === suggestion.name.toLowerCase());
      if (!named) return item;
      return {
        ...item,
        commits: {
          validCommitCount: score.validCommitCount,
          linesAuthored: score.linesAuthored,
          firstCommitAt: score.firstCommitAt,
          lastCommitAt: score.lastCommitAt,
        },
      };
    }),
  }));
}

module.exports = { createCommitScanner, attachCommits, BUDGET };
