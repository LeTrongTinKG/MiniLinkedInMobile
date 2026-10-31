// Mức tin cậy do tín hiệu quyết định, không do nút "Thêm vào hồ sơ". Chép từ Atom: _skill_confidence.
// evidenced = có hoạt động mã nguồn đáng kể + một tín hiệu độc lập (thư viện ở repo đã có commit, hoặc commit mạnh ở repo thứ hai).
const { EVIDENCE_BAR } = require("./scoreCommits");

function signalKind(signal) {
  const kind = String(signal).split(":")[0];
  if (kind === "dependency" || kind === "file") return "manifest_dependency";
  if (kind === "language") return "language_stat";
  if (kind === "topic") return "topic";
  return "readme_keyword";
}

function strongCommit(commits) {
  if (!commits) return false;
  const span = new Date(commits.lastCommitAt).getTime() - new Date(commits.firstCommitAt).getTime();
  return commits.validCommitCount >= EVIDENCE_BAR.minCommits
    && commits.linesAuthored >= EVIDENCE_BAR.minLines
    && span >= EVIDENCE_BAR.minSpanDays * 24 * 60 * 60 * 1000;
}

function confidenceFromEvidence(evidence) {
  const rows = Array.isArray(evidence) ? evidence : [];
  if (rows.length === 0) return { confidence: "self_claimed", reason: "no_signals" };

  const strong = rows.filter((row) => strongCommit(row.commits));
  const strongRepos = new Set(strong.map((row) => row.repo));
  const support = rows.some((row) =>
    (row.signals ?? []).some((signal) => signalKind(signal) === "manifest_dependency")
    && (row.commits?.validCommitCount ?? 0) >= 1);
  if (strong.length >= 1 && (support || strongRepos.size >= 2)) {
    return { confidence: "evidenced", reason: "evidenced" };
  }
  if (strong.length >= 1) return { confidence: "self_claimed", reason: "strong_no_independent" };
  if (rows.some((row) => row.commits)) return { confidence: "self_claimed", reason: "strong_below_threshold" };
  if (rows.some((row) => (row.signals ?? []).some((signal) => signalKind(signal) === "manifest_dependency"))) {
    return { confidence: "self_claimed", reason: "supporting_only" };
  }
  return { confidence: "self_claimed", reason: "weak_only" };
}

function annotateSuggestion(suggestion) {
  const level = confidenceFromEvidence(suggestion.evidence);
  return { ...suggestion, confidence: level.confidence, confidenceReason: level.reason };
}

module.exports = { confidenceFromEvidence, annotateSuggestion };
