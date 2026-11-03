const { roadmapProgress, has } = require("./progress");
const { canonicalSkill, reviewedRoadmaps } = require("./roadmaps");
const { voiceHint } = require("./knowledge");

/**
 * Câu trả lời bằng quy tắc (ADR-0008). Mọi con số và tên skill đều lấy từ dữ liệu người dùng
 * hoặc lộ trình đã duyệt; model (nếu bật) chỉ được viết lại câu này.
 */

const EVIDENCE_BAR = "ít nhất 5 commit, 200 dòng thêm, trải 14 ngày, tối đa 3 commit mỗi ngày được tính";

function refusal(roadmap) {
  const role = roadmap ? roadmap.title : "Mobile (Flutter)";
  return `Mình chỉ trả lời về kỹ năng và lộ trình học của bạn trên Atom. Bạn thử hỏi: "Tôi còn thiếu skill gì để theo hướng ${role}?"`;
}

function roleList() {
  return reviewedRoadmaps().map((roadmap) => roadmap.title).join(", ");
}

function describe(state) {
  if (state.state === "evidenced") return `${state.label} (GitHub, có hoạt động mã nguồn đáng kể)`;
  if (state.state === "cv") return `${state.label} (từ CV)`;
  return `${state.label} (bạn tự khai, chưa có commit đủ ngưỡng)`;
}

const list = (items) => (items.length > 0 ? items.join(", ") : "chưa có");
const stepName = (step) => `bước ${step.number} (${step.title})`;

function stepsWith(roadmap, name) {
  return roadmap.steps.filter((step) => step.groups.some((group) => group.includes(name)));
}

function roadmapSkills(roadmap) {
  return [...new Set(roadmap.steps.flatMap((step) => step.groups.flat()))];
}

function missingSkills({ roadmap, states }) {
  const names = roadmapSkills(roadmap);
  const owned = names.filter((name) => has(states, name)).map((name) => describe(states.get(name)));
  const unverified = names.filter((name) => states.get(name)?.state === "unverified");
  const missing = roadmapProgress(roadmap, states).missingGroups
    .filter((group) => !(group.length === 1 && unverified.includes(group[0])))
    .map((group) => group.join(" hoặc "));
  return [
    `Theo lộ trình ${roadmap.title}, bạn đã có: ${list(owned)}.`,
    unverified.length > 0 ? `Chưa có bằng chứng: ${unverified.map((n) => describe(states.get(n))).join(", ")}.` : "",
    `Còn thiếu: ${list([...new Set(missing)])}.`,
  ].filter(Boolean).join(" ");
}

function evidenceStatus({ states }) {
  const all = [...states.values()];
  if (all.length === 0) return "Hồ sơ của bạn chưa có skill nào. Hãy tải CV hoặc quét GitHub ở mục Kỹ năng.";
  const pick = (state) => all.filter((item) => item.state === state).map((item) => item.label);
  return [
    `Có hoạt động mã nguồn đáng kể trên GitHub: ${list(pick("evidenced"))}.`,
    `Có trong CV: ${list(pick("cv"))}.`,
    `Bạn tự khai, chưa có commit đủ ngưỡng: ${list(pick("unverified"))}.`,
  ].join(" ");
}

function skillStatus({ roadmap, states, skills }) {
  return skills.map((name) => {
    const state = states.get(name);
    const where = roadmap ? stepsWith(roadmap, name).map(stepName) : [];
    const place = where.length > 0 ? ` Skill này nằm ở ${where.join(", ")} của lộ trình ${roadmap.title}.` : "";
    if (!state) return `Hồ sơ của bạn chưa có ${name}.${place}`;
    if (state.state === "evidenced") return `${state.label}: có hoạt động mã nguồn đáng kể trên GitHub (${EVIDENCE_BAR}).${place}`;
    if (state.state === "cv") return `${state.label} có trong CV của bạn nhưng chưa có bằng chứng commit.${place}`;
    return `${state.label} bạn đã thêm nhưng chưa có commit đủ ngưỡng (${EVIDENCE_BAR}).${place}`;
  }).join(" ");
}

function skillInRoadmap({ roadmap, skills, job }) {
  const required = new Set((job?.requiredSkills ?? []).map(canonicalSkill));
  return skills.map((name) => {
    const where = stepsWith(roadmap, name).map(stepName);
    const inRoadmap = where.length > 0
      ? `${name} nằm ở ${where.join(", ")} của lộ trình ${roadmap.title}.`
      : `${name} không có trong lộ trình ${roadmap.title}.`;
    return required.has(name) ? `${inRoadmap} Job "${job.title}" có yêu cầu ${name}.` : inRoadmap;
  }).join(" ");
}

function howEvidence({ roadmap, skills, states }) {
  const name = skills[0];
  if (!name) return `Commit đều vào repo GitHub của chính bạn (${EVIDENCE_BAR}), rồi bấm Quét GitHub ở mục Kỹ năng.`;
  const label = states.get(name)?.label ?? name;
  const step = roadmap ? stepsWith(roadmap, name)[0] : null;
  const proof = step ? ` Gợi ý theo lộ trình: ${step.proof}` : "";
  return `Để ${label} có bằng chứng: commit đều vào một repo GitHub của bạn có dùng ${label} (${EVIDENCE_BAR}), rồi bấm Quét GitHub ở mục Kỹ năng.${proof}`;
}

function projectFor({ roadmap, skills, states }) {
  const name = skills[0] ?? roadmapProgress(roadmap, states).current?.groups[0]?.[0];
  const step = name ? stepsWith(roadmap, name)[0] : null;
  if (!step) return `Lộ trình ${roadmap.title} chưa có dự án gợi ý cho ${name ?? "skill này"}.`;
  return `Dự án gợi ý cho ${name} (${stepName(step)}): ${step.proof}`;
}

function jobGap({ job, states, skills }) {
  if (!job) return "Bạn chưa mở job nào và chưa ứng tuyển job nào. Mở một job rồi hỏi lại nhé.";
  const required = [...new Set((job.requiredSkills ?? []).map(canonicalSkill))];
  const missing = required.filter((name) => !has(states, name));
  const asked = skills.map((name) =>
    required.includes(name) ? `Job "${job.title}" có yêu cầu ${name}.` : `Job "${job.title}" không yêu cầu ${name}.`);
  return [
    ...asked,
    `Job "${job.title}" yêu cầu: ${list(required)}.`,
    `Bạn còn thiếu: ${list(missing)}.`,
    "Nộp hay chưa là quyết định của bạn.",
  ].join(" ");
}

function currentStep({ roadmap, states, steps }) {
  const progress = roadmapProgress(roadmap, states);
  if (!progress.current) return `Bạn đã có đủ skill cho mọi bước của lộ trình ${roadmap.title}.`;
  const done = progress.doneNumbers.length > 0 ? `Bạn đã xong bước ${progress.doneNumbers.join(", ")}. ` : "";
  const parts = [`${done}Bạn đang ở ${stepName(progress.current)}.`];
  const claimed = steps.filter((n) => n !== progress.current.number && !progress.doneNumbers.includes(n));
  for (const number of claimed) {
    const step = roadmap.steps.find((s) => s.number === number);
    if (!step) continue;
    parts.push(`Theo dữ liệu, bạn chưa xong bước ${number}. ${stepName(step)}: ${step.learn}`);
  }
  return parts.join(" ");
}

function nextLearn({ roadmap, states }) {
  const step = roadmapProgress(roadmap, states).current;
  if (!step) return `Bạn đã có đủ skill cho lộ trình ${roadmap.title}. Hãy hoàn thiện 2–3 dự án trên GitHub.`;
  return `Bạn nên học ${stepName(step)}: ${step.learn} Bằng chứng nên có: ${step.proof}`;
}

function timeLeft({ roadmap, states }) {
  const progress = roadmapProgress(roadmap, states);
  if (!progress.current) return `Bạn đã có đủ skill cho lộ trình ${roadmap.title}.`;
  return `Từ ${stepName(progress.current)} đến hết lộ trình ${roadmap.title} còn khoảng ${progress.weeksLeft} tuần, nếu học 1–2 giờ mỗi ngày.`;
}

const NEEDS_ROADMAP = new Set(["missing_skills", "current_step", "next_learn", "project_for", "time_left", "skill_in_roadmap"]);
const BUILDERS = {
  missing_skills: missingSkills, current_step: currentStep, next_learn: nextLearn,
  evidence_status: evidenceStatus, skill_status: skillStatus, how_evidence: howEvidence,
  job_gap: jobGap, project_for: projectFor, time_left: timeLeft, skill_in_roadmap: skillInRoadmap,
};

function sourcesFor(ctx, intent) {
  const sources = [];
  if (ctx.roadmap && (NEEDS_ROADMAP.has(intent) || intent === "skill_status")) sources.push(`Lộ trình ${ctx.roadmap.title}`);
  if (ctx.job && ["job_gap", "skill_in_roadmap"].includes(intent)) sources.push(`Job "${ctx.job.title}"`);
  if (intent !== "job_gap" || ctx.job) sources.push("Skill trong hồ sơ và CV của bạn");
  return sources;
}

/** ctx = { roadmap, states, job }, parsed = kết quả classify(). Trả { text, sources, skills }. */
function buildAnswer(ctx, parsed) {
  if (parsed.refuse) return { text: refusal(ctx.roadmap), sources: [], refused: true };
  if (parsed.intent === "unknown_role") return { text: `Hiện chỉ có lộ trình: ${roleList()}.`, sources: [] };
  if (NEEDS_ROADMAP.has(parsed.intent) && !ctx.roadmap) {
    return { text: `Bạn chưa chọn vị trí muốn theo. Hãy chọn một trong: ${roleList()}.`, sources: [], needsRole: true };
  }
  const text = withVoice(
    BUILDERS[parsed.intent]({ ...ctx, skills: parsed.skills ?? [], steps: parsed.steps ?? [] }),
    ctx,
    parsed.intent,
  );
  return { text, sources: sourcesFor(ctx, parsed.intent) };
}

const VOICE_INTENTS = new Set(["missing_skills", "current_step", "next_learn", "how_evidence", "project_for", "time_left"]);

function withVoice(text, ctx, intent) {
  if (!VOICE_INTENTS.has(intent) || !ctx.roadmap) return text;
  const step = roadmapProgress(ctx.roadmap, ctx.states).current?.number;
  const hint = voiceHint(ctx.roadmap.id, step);
  if (!hint) return text;
  const joined = `${text} ${hint}`;
  return joined.split(/\s+/).length <= 140 ? joined : text;
}

module.exports = { buildAnswer, refusal };
