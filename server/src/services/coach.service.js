const coachRepository = require("../repositories/coach.repository");
const { ApiError } = require("../middleware/error");
const { classify, INTENTS } = require("./coach/intent");
const { buildAnswer } = require("./coach/answers");
const { skillStates } = require("./coach/progress");
const { canonicalSkill, findRoadmap, reviewedRoadmaps } = require("./coach/roadmaps");
const { createOllamaWriter } = require("./coach/ollamaWriter");

/**
 * Chatbot kỹ năng và lộ trình (ADR-0008): chỉ sinh viên đã đồng ý, chỉ dữ liệu của chính họ,
 * 10 câu mỗi ngày theo giờ Việt Nam. Câu bị từ chối không trừ lượt. Không lưu nội dung câu hỏi.
 */

const DAILY_LIMIT = 10;
const MAX_QUESTION = 300;
const defaultWriter = createOllamaWriter();

function vnDay(now = new Date()) {
  return new Intl.DateTimeFormat("en-CA", { timeZone: "Asia/Ho_Chi_Minh" }).format(now);
}

function nextVnMidnight(now = new Date()) {
  const start = new Date(`${vnDay(now)}T00:00:00+07:00`);
  return new Date(start.getTime() + 24 * 60 * 60 * 1000);
}

function requireUser(userId) {
  if (!userId) throw new ApiError(401, "UNAUTHORIZED", "Yêu cầu đăng nhập");
}

const roleOptions = () => reviewedRoadmaps().map((roadmap) => ({ id: roadmap.id, title: roadmap.title }));

async function getSettings(userId, repo = coachRepository, now = new Date()) {
  requireUser(userId);
  const profile = await repo.findProfile(userId);
  const used = await repo.usedToday(userId, vnDay(now));
  return {
    consent: Boolean(profile?.coachConsentAt),
    targetRole: profile?.targetRole ?? null,
    roles: roleOptions(),
    limit: DAILY_LIMIT,
    remaining: Math.max(DAILY_LIMIT - used, 0),
    resetsAt: nextVnMidnight(now).toISOString(),
  };
}

async function updateSettings(userId, body = {}, repo = coachRepository, now = new Date()) {
  requireUser(userId);
  const { consent, targetRole } = body;
  if (consent !== undefined && typeof consent !== "boolean") {
    throw new ApiError(400, "INVALID_CONSENT", "consent phải là true hoặc false");
  }
  if (targetRole !== undefined && targetRole !== null && !findRoadmap(targetRole)) {
    throw new ApiError(400, "INVALID_TARGET_ROLE", "Vị trí không có trong danh sách lộ trình");
  }
  await repo.saveSettings(userId, {
    consentAt: consent === undefined ? undefined : consent ? now : null,
    targetRole,
  });
  return getSettings(userId, repo, now);
}

function parseRequest(body) {
  const { question, intent, skill, jobId } = body ?? {};
  if (jobId !== undefined && (typeof jobId !== "string" || jobId.length === 0 || jobId.length > 64)) {
    throw new ApiError(400, "INVALID_JOB_ID", "jobId không hợp lệ");
  }
  if (intent !== undefined) {
    if (!INTENTS.includes(intent)) throw new ApiError(400, "INVALID_INTENT", "Loại câu hỏi không hợp lệ");
    if (skill !== undefined && (typeof skill !== "string" || skill.length > 50)) {
      throw new ApiError(400, "INVALID_SKILL", "Tên skill không hợp lệ");
    }
    return { parsed: { intent, skills: skill ? [canonicalSkill(skill)] : [], role: null, steps: [] }, jobId };
  }
  const text = typeof question === "string" ? question.trim() : "";
  if (text.length === 0) throw new ApiError(400, "QUESTION_REQUIRED", "Hãy nhập câu hỏi hoặc chọn câu hỏi mẫu");
  if (text.length > MAX_QUESTION) {
    throw new ApiError(400, "QUESTION_TOO_LONG", `Câu hỏi tối đa ${MAX_QUESTION} ký tự`);
  }
  return { parsed: classify(text), jobId };
}

async function loadContext(userId, profile, parsed, jobId, repo) {
  const [userSkills, cvSkills, job] = await Promise.all([
    repo.listSkills(userId),
    repo.findDefaultCvSkills(userId),
    jobId ? repo.findJob(jobId) : repo.findLatestAppliedJob(userId),
  ]);
  return {
    roadmap: findRoadmap(parsed.role ?? profile.targetRole),
    states: skillStates({ userSkills, cvSkills }),
    job,
  };
}

async function ask(userId, body, { repo = coachRepository, writer = defaultWriter, now = new Date() } = {}) {
  requireUser(userId);
  const { parsed, jobId } = parseRequest(body);
  const profile = await repo.findProfile(userId);
  if (!profile?.coachConsentAt) {
    throw new ApiError(403, "COACH_CONSENT_REQUIRED", "Hãy bật đồng ý cho chatbot đọc dữ liệu kỹ năng trong Hồ sơ");
  }
  const day = vnDay(now);
  const resetsAt = nextVnMidnight(now).toISOString();

  if (parsed.refuse) {
    const answer = buildAnswer({ roadmap: findRoadmap(profile.targetRole) }, parsed);
    const used = await repo.usedToday(userId, day);
    return { answer: answer.text, sources: [], mode: "rules", refused: true, remaining: Math.max(DAILY_LIMIT - used, 0), resetsAt };
  }

  const count = await repo.takeQuota(userId, day, DAILY_LIMIT);
  if (count === null) {
    throw new ApiError(429, "QUOTA_EXCEEDED", `Bạn đã hỏi đủ ${DAILY_LIMIT} câu hôm nay`, { resetsAt });
  }

  const ctx = await loadContext(userId, profile, parsed, jobId, repo);
  const answer = buildAnswer(ctx, parsed);
  const written = answer.needsRole ? { text: answer.text, mode: "rules" } : await writer.rewrite(answer.text);
  return {
    answer: written.text,
    sources: answer.sources,
    mode: written.mode,
    refused: false,
    remaining: DAILY_LIMIT - count,
    resetsAt,
  };
}

module.exports = { DAILY_LIMIT, vnDay, nextVnMidnight, getSettings, updateSettings, ask, warmUp: () => defaultWriter.warmUp() };
