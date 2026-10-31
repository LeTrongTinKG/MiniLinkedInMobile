const skillRepository = require("../repositories/skill.repository");
const { createGithubReader, GithubError } = require("./skills/githubReader");
const { extractSuggestions, RULES } = require("./skills/extractRules");
const { createCommitScanner, attachCommits } = require("./skills/commitScan");
const { confidenceFromEvidence, annotateSuggestion } = require("./skills/confidence");
const { SCAN_LIMIT } = require("./skills/scanQuota");
const { ApiError } = require("../middleware/error");

/**
 * Skill có bằng chứng (ADR-0005, ADR-0007): quét repo GitHub của chính người dùng,
 * chấm độ tin cậy theo commit, giới hạn số lần quét, skill chỉ vào hồ sơ khi được duyệt.
 */

const GITHUB_ERRORS = {
  RATE_LIMITED: [429, "GitHub đang giới hạn lượt gọi, thử lại sau ít phút"],
  NOT_FOUND: [404, "Không tìm thấy tài khoản GitHub đã liên kết"],
  GITHUB_UNAVAILABLE: [502, "Không đọc được GitHub lúc này, thử lại sau"],
};

function requireUser(userId) {
  if (!userId) throw new ApiError(401, "UNAUTHORIZED", "Yêu cầu đăng nhập");
}

function githubFailure(error) {
  const [status, message] = GITHUB_ERRORS[error.code] ?? GITHUB_ERRORS.GITHUB_UNAVAILABLE;
  return new ApiError(status, error.code === "NOT_FOUND" ? "GITHUB_NOT_FOUND" : error.code, message);
}

async function openScan(userId, repo) {
  const gate = await repo.beginScan(userId);
  if (gate.ok) return gate.scan;
  if (gate.code === "QUOTA_EXCEEDED") {
    throw new ApiError(429, "QUOTA_EXCEEDED", `Đã hết ${SCAN_LIMIT} lần quét trong tháng này`, {
      resetsAt: gate.resetsAt.toISOString(),
    });
  }
  throw new ApiError(409, "SCAN_ALREADY_RUNNING", "Đang quét rồi, đợi lần này xong");
}

async function scanGithub(
  userId,
  repo = skillRepository,
  reader = createGithubReader(),
  scanner = createCommitScanner(),
) {
  requireUser(userId);
  const githubId = await repo.findGithubId(userId);
  if (!githubId) {
    throw new ApiError(400, "GITHUB_NOT_LINKED", "Hãy đăng nhập bằng GitHub một lần để liên kết tài khoản");
  }

  const scan = await openScan(userId, repo);
  try {
    const sources = await reader.readOwnRepos(githubId);
    if (sources.length === 0) {
      throw new ApiError(422, "NO_REPOS", "Không thấy repo công khai nào để quét");
    }
    const login = typeof reader.loginFor === "function" ? await reader.loginFor(githubId) : null;
    const byRepo = login ? await scanner.commitsByRepo({ login, sources, rules: RULES }) : new Map();
    // shortcut: skill đã từ chối thì không đề xuất lại kể cả khi có repo mới; Atom đề xuất lại khi bằng chứng đổi.
    const owned = await repo.listSkills(userId);
    const decided = await repo.listSuggestions(userId, ["accepted", "rejected"]);
    const suggestions = attachCommits(extractSuggestions({
      sources,
      existingNames: [...owned, ...decided].map((item) => item.skillName),
    }), byRepo);
    for (const suggestion of suggestions) {
      await repo.upsertPending(userId, suggestion.name, suggestion.evidence);
    }
    await repo.finishScan(scan.id, "succeeded");
    return { repoCount: sources.length, suggestions: (await repo.listSuggestions(userId, ["pending"])).map(annotateSuggestion) };
  } catch (error) {
    await repo.finishScan(scan.id, "failed").catch(() => {});
    if (error instanceof ApiError) throw error;
    if (error instanceof GithubError) throw githubFailure(error);
    throw error;
  }
}

async function listSuggestions(userId, repo = skillRepository) {
  requireUser(userId);
  return (await repo.listSuggestions(userId, ["pending"])).map(annotateSuggestion);
}

async function listMySkills(userId, repo = skillRepository) {
  requireUser(userId);
  return repo.listSkills(userId);
}

async function decideSuggestion(userId, suggestionId, accept, repo = skillRepository) {
  requireUser(userId);
  if (typeof suggestionId !== "string" || suggestionId.trim().length === 0) {
    throw new ApiError(400, "INVALID_SUGGESTION_ID", "ID đề xuất không hợp lệ");
  }
  const suggestion = await repo.findSuggestionById(suggestionId.trim());
  if (!suggestion) throw new ApiError(404, "SUGGESTION_NOT_FOUND", "Không tìm thấy đề xuất");
  if (suggestion.userId !== userId) throw new ApiError(403, "FORBIDDEN", "Bạn không có quyền với đề xuất này");
  if (suggestion.status !== "pending") throw new ApiError(409, "SUGGESTION_DECIDED", "Đề xuất này đã được duyệt rồi");
  if (!accept) return repo.rejectSuggestion(suggestion.id);
  return repo.acceptSuggestion(suggestion, confidenceFromEvidence(suggestion.evidence));
}

async function addSelfClaimedSkill(userId, skillName, repo = skillRepository) {
  requireUser(userId);
  if (!skillName || typeof skillName !== "string" || skillName.trim().length === 0) {
    throw new ApiError(400, "INVALID_SKILL_NAME", "Tên kỹ năng không được để trống");
  }
  return repo.addSelfClaimed(userId, skillName.trim());
}

async function deleteSkill(userId, skillName, repo = skillRepository) {
  requireUser(userId);
  if (!skillName || typeof skillName !== "string" || skillName.trim().length === 0) {
    throw new ApiError(400, "INVALID_SKILL_NAME", "Tên kỹ năng không hợp lệ");
  }
  return repo.deleteSkill(userId, skillName.trim());
}

async function scanCustomRepo(userId, repoUrl, repo = skillRepository, reader = createGithubReader()) {
  requireUser(userId);
  if (!repoUrl || typeof repoUrl !== "string") {
    throw new ApiError(400, "INVALID_REPO_URL", "Vui lòng cung cấp link GitHub repo hợp lệ");
  }
  const match = repoUrl.trim().match(/(?:https?:\/\/github\.com\/)?([^/\s]+)\/([^/\s#?]+)/i);
  if (!match) {
    throw new ApiError(400, "INVALID_REPO_URL", "Định dạng repo không đúng (ví dụ: owner/repo hoặc https://github.com/owner/repo)");
  }
  const fullName = `${match[1]}/${match[2].replace(/\.git$/i, "")}`;
  try {
    const source = await reader.readSingleRepo(fullName);
    const owned = await repo.listSkills(userId);
    const decided = await repo.listSuggestions(userId, ["accepted", "rejected"]);
    const suggestions = extractSuggestions({
      sources: [source],
      existingNames: [...owned, ...decided].map((item) => item.skillName),
    });
    for (const suggestion of suggestions) {
      await repo.upsertPending(userId, suggestion.name, suggestion.evidence);
    }
    return {
      repo: fullName,
      suggestions: (await repo.listSuggestions(userId, ["pending"])).map(annotateSuggestion),
    };
  } catch (error) {
    if (error instanceof ApiError) throw error;
    if (error instanceof GithubError) throw githubFailure(error);
    throw error;
  }
}

async function endorseSkill(endorserId, targetUserId, skillName, repo = skillRepository) {
  requireUser(endorserId);
  if (endorserId === targetUserId) {
    throw new ApiError(400, "CANNOT_ENDORSE_SELF", "Không thể tự xác nhận kỹ năng của chính mình");
  }
  const callerSkills = await repo.listSkills(endorserId);
  const hasCred = callerSkills.some((s) => s.skillName.toLowerCase() === skillName.toLowerCase() && (s.confidence === "evidenced" || s.confidence === "endorsed"));
  if (!hasCred) {
    throw new ApiError(403, "ENDORSE_REQUIRES_EVIDENCE", "Bạn cần có kỹ năng này ở mức 'Có bằng chứng' để xác nhận cho người khác");
  }
  return repo.endorseSkill(endorserId, targetUserId, skillName);
}

module.exports = {
  scanGithub,
  listSuggestions,
  listMySkills,
  decideSuggestion,
  addSelfClaimedSkill,
  deleteSkill,
  scanCustomRepo,
  endorseSkill,
};
