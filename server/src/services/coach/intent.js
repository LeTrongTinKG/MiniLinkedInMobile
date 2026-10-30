const { SKILLS } = require("../ai/skillsDictionary");
const { reviewedRoadmaps } = require("./roadmaps");
const { INSTRUCTION_PATTERN, INSTRUCTION_PLAIN } = require("./progress");

/**
 * Phân loại câu hỏi bằng quy tắc (ADR-0008). Không khớp loại nào thì từ chối, không gọi model.
 * Mẫu viết không dấu vì câu hỏi được bỏ dấu trước khi so.
 */

const INTENTS = [
  "missing_skills", "current_step", "next_learn", "evidence_status", "skill_status",
  "how_evidence", "job_gap", "project_for", "time_left", "skill_in_roadmap",
];

const OTHER_USER = /\b(sinh vien|nguoi dung|nguoi|ban)\s+(khac|kia)\b/;
const OFF_TOPIC = /thoi tiet|chuyen cuoi|cong ty|thu do|chinh tri|(viet|giup).*\bcode\b|\bcode mau\b|doan code/;
// "lương" so trên chữ có dấu vì bỏ dấu sẽ trùng "lượng".
const SALARY = /lương/i;
const OTHER_ROLES = /\b(devops|java|android|ios|tester|qa|game|php|\.net|c#|golang|cloud|security|bao mat|blockchain)\b/;
const ROLE_CONTEXT = /lo trinh|huong|vi tri/;
const ROLE_WORDS = {
  "flutter-mobile": /\b(flutter|mobile)\b/,
  "backend-node": /\b(backend|node|nodejs)\b/,
  "frontend-react": /\b(frontend|react)\b/,
  "data-ai": /\b(data|du lieu|ai|python)\b/,
};
// Tên vị trí cũng là tên skill; khi câu có skill khác thì ưu tiên skill khác.
const ROLE_ANCHORS = new Set(["flutter", "nodejs", "react", "python"]);

// Bí danh dưới 3 ký tự ("go", "ml") dễ trùng chữ tiếng Việt không dấu nên bỏ.
const SKILL_ALIASES = SKILLS.flatMap((names) =>
  names.filter((alias) => alias.length >= 3).map((alias) => [alias, names[0]]),
);

function normalize(text) {
  return String(text ?? "")
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/đ/g, "d");
}

function escapeRegex(text) {
  return text.replace(/[.*+?^${}()|[\]\\/]/g, "\\$&");
}

function mentionedSkills(text) {
  const lower = String(text ?? "").toLowerCase();
  const found = [];
  for (const [alias, name] of SKILL_ALIASES) {
    const pattern = new RegExp(`(^|[^a-z0-9])${escapeRegex(alias)}([^a-z0-9]|$)`);
    if (pattern.test(lower) && !found.includes(name)) found.push(name);
  }
  const specific = found.filter((name) => !ROLE_ANCHORS.has(name));
  return specific.length > 0 ? specific : found;
}

function mentionedRole(plain) {
  if (!ROLE_CONTEXT.test(plain)) return null;
  const known = reviewedRoadmaps().find((roadmap) => ROLE_WORDS[roadmap.id]?.test(plain));
  if (known) return { id: known.id };
  return OTHER_ROLES.test(plain) ? { unknown: true } : null;
}

function stepNumbers(plain) {
  return [...plain.matchAll(/buoc\s*(\d+)/g)].map((m) => Number(m[1]));
}

function pickIntent(plain, skills) {
  if (/\b(job|nop|ung tuyen|tuyen dung|intern)\b/.test(plain)) return "job_gap";
  if (/bao lau|may tuan|khi nao xong|bao gio xong/.test(plain)) return "time_left";
  if (/\bbuoc\b/.test(plain)) return "current_step";
  if (/du an|project/.test(plain)) return "project_for";
  if (/lam sao|lam the nao|cach nao|cach de/.test(plain) && /bang chung|chung minh|duoc tinh/.test(plain)) {
    return "how_evidence";
  }
  if (/thieu|bao nhieu skill|can them|con can/.test(plain)) return "missing_skills";
  if (skills.length > 0 && /lo trinh|giup gi|\bhay\b/.test(plain)) return "skill_in_roadmap";
  if (skills.length > 0) return "skill_status";
  if (/hoc gi|tiep theo|tuan nay|nen hoc|bat dau tu dau/.test(plain)) return "next_learn";
  if (/bang chung|skill nao|ky nang nao|nhung skill|skill cua toi/.test(plain)) return "evidence_status";
  return null;
}

/** Trả { intent, skills, role, steps } hoặc { refuse: "attack" | "off_topic" }. */
function classify(question) {
  const original = String(question ?? "");
  const plain = normalize(original);
  if (INSTRUCTION_PATTERN.test(original) || INSTRUCTION_PLAIN.test(plain)) return { refuse: "attack" };
  if (OTHER_USER.test(plain) || /[Ss]inh viên\s+[A-ZĐ]\b/.test(original)) return { refuse: "attack" };
  if (OFF_TOPIC.test(plain) || SALARY.test(original)) return { refuse: "off_topic" };

  const role = mentionedRole(plain);
  if (role?.unknown) return { intent: "unknown_role", skills: [], role: null, steps: [] };
  const skills = mentionedSkills(original);
  const intent = pickIntent(plain, skills);
  if (!intent) return { refuse: "off_topic" };
  return { intent, skills, role: role?.id ?? null, steps: stepNumbers(plain) };
}

module.exports = { INTENTS, classify, normalize, mentionedSkills };
