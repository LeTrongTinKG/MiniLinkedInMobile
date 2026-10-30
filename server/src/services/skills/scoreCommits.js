// Chấm commit của đúng tài khoản đã lưu. Chép từ Atom: supabase/functions/_shared/commit_signals.ts.
// Ngưỡng "đáng kể": 5 commit, 200 dòng, 14 ngày (ADR-0011 của Atom, evidence_policy phiên bản 1).

const manifestNames = new Set([
  "pubspec.yaml", "package.json", "requirements.txt", "pyproject.toml", "go.mod",
  "cargo.toml", "gemfile", "composer.json", "pom.xml", "build.gradle", "build.gradle.kts",
]);

const EVIDENCE_BAR = { minCommits: 5, minLines: 200, minSpanDays: 14 };
const MAX_COMMITS_PER_DAY = 3;

function ignoredGeneratedPath(filePath) {
  const lower = filePath.toLowerCase().replaceAll("\\", "/");
  const base = lower.split("/").pop() ?? lower;
  if (["vendor/", "node_modules/", "third_party/", "dist/", "build/", "generated/"].some(
    (dir) => lower.startsWith(dir) || lower.includes(`/${dir}`),
  )) return true;
  return (
    base.endsWith(".lock") || base.endsWith("-lock.json") ||
    ["pubspec.lock", "package-lock.json", "yarn.lock", "cargo.lock", "gemfile.lock", "composer.lock", "poetry.lock"].includes(base) ||
    base.endsWith(".g.dart") || base.endsWith(".freezed.dart") || base.endsWith(".pb.dart") || base.endsWith(".min.js")
  );
}

function dayKey(iso) {
  return new Date(new Date(iso).getTime() + 7 * 60 * 60 * 1000).toISOString().slice(0, 10);
}

function matchesSkill(filename, rule, repoDependencies) {
  const lower = filename.toLowerCase().replaceAll("\\", "/");
  const base = lower.split("/").pop() ?? lower;
  const extensionHit = rule.extensions.some((ext) => lower.endsWith(ext.toLowerCase()));
  const fileHit = rule.files.some((file) => base === file.toLowerCase() || lower.endsWith(`/${file.toLowerCase()}`));
  const dependencyPresent = rule.dependencies.some((name) => repoDependencies.has(name.toLowerCase()));
  if ((extensionHit || fileHit) && (rule.dependencies.length === 0 || dependencyPresent)) return true;
  return manifestNames.has(base) && dependencyPresent;
}

function scoreAuthorCommits(input) {
  const login = input.login.toLowerCase();
  const repoDependencies = new Set(input.repoDependencies.map((name) => name.toLowerCase()));
  const kept = input.commits
    .filter((commit) => commit.authorLogin?.toLowerCase() === login && commit.parentCount <= 1)
    .map((commit) => ({
      ...commit,
      files: commit.files.filter((file) => !ignoredGeneratedPath(file.filename) && file.additions > 0),
    }))
    .filter((commit) => commit.files.length > 0)
    .sort((a, b) => a.date.localeCompare(b.date));

  // Commit đầu khổng lồ chỉ bị bỏ khi đã đọc tới gốc lịch sử. Quét bị cắt thì giữ lại.
  if (input.reachedRoot === true && kept.length > 0 && kept[0].files.reduce((sum, file) => sum + file.additions, 0) > 1000) {
    kept.shift();
  }

  const perDay = new Map();
  const counted = kept.filter((commit) => {
    const day = dayKey(commit.date);
    const used = perDay.get(day) ?? 0;
    if (used >= MAX_COMMITS_PER_DAY) return false;
    perDay.set(day, used + 1);
    return true;
  });

  const bySkill = new Map();
  for (const commit of counted) {
    for (const rule of input.skills) {
      const lines = commit.files
        .filter((file) => matchesSkill(file.filename, rule, repoDependencies))
        .reduce((sum, file) => sum + file.additions, 0);
      if (lines <= 0) continue;
      const current = bySkill.get(rule.name) ?? { lines: 0 };
      current.lines += lines;
      bySkill.set(rule.name, current);
    }
  }
  if (bySkill.size === 0) return null;
  const dates = counted.map((commit) => commit.date).sort();
  return {
    validCommitCount: counted.length,
    linesAuthored: [...bySkill.values()].reduce((sum, item) => sum + item.lines, 0),
    firstCommitAt: dates[0],
    lastCommitAt: dates[dates.length - 1],
    skillNames: [...bySkill.keys()],
  };
}

function scanMeetsEvidenceBar(score) {
  const spanMs = new Date(score.lastCommitAt).getTime() - new Date(score.firstCommitAt).getTime();
  return score.validCommitCount >= EVIDENCE_BAR.minCommits
    && score.linesAuthored >= EVIDENCE_BAR.minLines
    && spanMs >= EVIDENCE_BAR.minSpanDays * 24 * 60 * 60 * 1000;
}

module.exports = { ignoredGeneratedPath, scoreAuthorCommits, scanMeetsEvidenceBar, EVIDENCE_BAR };
