const { canonicalSkill } = require("./roadmaps");

// Câu ra lệnh cho AI nằm trong CV hoặc câu hỏi (ADR-0008, mục chống chèn lệnh). So trên chữ có dấu.
const INSTRUCTION_PATTERN =
  /\b(ai|chatbot|gpt|llm|bot)\b[^.?!\n]{0,30}(hãy|ghi tôi|coi tôi|viết rằng)|bỏ qua (mọi|tất cả|các|hướng dẫn)|ignore (all|previous|the)|system prompt|câu lệnh hệ thống|hướng dẫn trước|từ giờ bạn là|bạn là trợ lý/i;
// Cùng ý trên chữ đã bỏ dấu, cho người gõ không dấu.
const INSTRUCTION_PLAIN = /bo qua (moi|tat ca|cac|huong dan)|ignore (all|previous|the)|system prompt|cau lenh he thong|tu gio ban la|ban la tro ly/;

function cvSkillNames(extracted) {
  if (!extracted) return [];
  const skills = Array.isArray(extracted) ? extracted : extracted.skills ?? [];
  const evidence = Array.isArray(extracted.evidence) ? extracted.evidence : [];
  const tainted = new Set(
    evidence.filter((item) => INSTRUCTION_PATTERN.test(item.quote ?? "")).map((item) => canonicalSkill(item.skill)),
  );
  return skills.map(canonicalSkill).filter((name) => name && !tainted.has(name));
}

/**
 * Trạng thái từng skill của người dùng, theo tên chuẩn:
 * evidenced (GitHub đủ ngưỡng commit) > cv (có trong CV mặc định) > unverified (đã duyệt nhưng tự khai).
 */
function skillStates({ userSkills = [], cvSkills = null }) {
  const states = new Map();
  const put = (name, state, label) => {
    const rank = { evidenced: 3, cv: 2, unverified: 1 };
    const current = states.get(name);
    if (!current || rank[state] > rank[current.state]) states.set(name, { name, state, label });
  };
  for (const name of cvSkillNames(cvSkills)) put(name, "cv", name);
  for (const skill of userSkills) {
    const state = skill.confidence === "evidenced" ? "evidenced" : "unverified";
    put(canonicalSkill(skill.skillName), state, skill.skillName);
  }
  return states;
}

const has = (states, name) => ["evidenced", "cv"].includes(states.get(name)?.state);

function groupDone(states, group) {
  return group.some((name) => has(states, name));
}

/** Bước hiện tại = bước đầu tiên còn nhóm skill chưa có. null khi đã xong cả lộ trình. */
function roadmapProgress(roadmap, states) {
  const done = roadmap.steps.filter((step) => step.groups.every((group) => groupDone(states, group)));
  const current = roadmap.steps.find((step) => !step.groups.every((group) => groupDone(states, group))) ?? null;
  const remaining = current ? roadmap.steps.filter((step) => step.number >= current.number) : [];
  return {
    doneNumbers: done.map((step) => step.number),
    current,
    weeksLeft: remaining.reduce((sum, step) => sum + step.weeks, 0),
    missingGroups: roadmap.steps.flatMap((step) => step.groups.filter((group) => !groupDone(states, group))),
  };
}

module.exports = { INSTRUCTION_PATTERN, INSTRUCTION_PLAIN, cvSkillNames, skillStates, has, roadmapProgress };
