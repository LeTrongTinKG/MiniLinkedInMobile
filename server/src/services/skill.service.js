const skillRepository = require("../repositories/skill.repository");
const { createGithubReader, GithubError } = require("./skills/githubReader");
const { extractSuggestions } = require("./skills/extractRules");
const { ApiError } = require("../middleware/error");

/**
 * Skill có bằng chứng (ADR-0005): quét repo GitHub của chính người dùng, đề xuất skill
 * kèm repo + dấu hiệu; skill chỉ vào hồ sơ khi người dùng bấm đồng ý.
 */

const GITHUB_ERRORS = {
  RATE_LIMITED: [429, "GitHub đang giới hạn lượt gọi, thử lại sau ít phút"],
  NOT_FOUND: [404, "Không tìm thấy tài khoản GitHub đã liên kết"],
  GITHUB_UNAVAILABLE: [502, "Không đọc được GitHub lúc này, thử lại sau"],
};

function requireUser(userId) {
  if (!userId) throw new ApiError(401, "UNAUTHORIZED", "Yêu cầu đăng nhập");
}

async function scanGithub(userId, repo = skillRepository, reader = createGithubReader()) {
  requireUser(userId);
  const githubId = await repo.findGithubId(userId);
  if (!githubId) {
    throw new ApiError(400, "GITHUB_NOT_LINKED", "Hãy đăng nhập bằng GitHub một lần để liên kết tài khoản");
  }

  let sources;
  try {
    sources = await reader.readOwnRepos(githubId);
  } catch (error) {
    if (!(error instanceof GithubError)) throw error;
    const [status, message] = GITHUB_ERRORS[error.code] ?? GITHUB_ERRORS.GITHUB_UNAVAILABLE;
    throw new ApiError(status, error.code === "NOT_FOUND" ? "GITHUB_NOT_FOUND" : error.code, message);
  }

  // shortcut: skill đã từ chối thì không đề xuất lại kể cả khi có repo mới; Atom đề xuất lại khi bằng chứng đổi.
  const owned = await repo.listSkills(userId);
  const decided = await repo.listSuggestions(userId, ["accepted", "rejected"]);
  const suggestions = extractSuggestions({
    sources,
    existingNames: [...owned, ...decided].map((s) => s.skillName),
  });
  for (const s of suggestions) {
    await repo.upsertPending(userId, s.name, s.evidence);
  }

  return {
    repoCount: sources.length,
    suggestions: await repo.listSuggestions(userId, ["pending"]),
  };
}

async function listSuggestions(userId, repo = skillRepository) {
  requireUser(userId);
  return repo.listSuggestions(userId, ["pending"]);
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
  if (!suggestion) {
    throw new ApiError(404, "SUGGESTION_NOT_FOUND", "Không tìm thấy đề xuất");
  }
  if (suggestion.userId !== userId) {
    throw new ApiError(403, "FORBIDDEN", "Bạn không có quyền với đề xuất này");
  }
  if (suggestion.status !== "pending") {
    throw new ApiError(409, "SUGGESTION_DECIDED", "Đề xuất này đã được duyệt rồi");
  }
  return accept ? repo.acceptSuggestion(suggestion) : repo.rejectSuggestion(suggestion.id);
}

module.exports = { scanGithub, listSuggestions, listMySkills, decideSuggestion };
