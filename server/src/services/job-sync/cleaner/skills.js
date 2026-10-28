// Bước 6: trích kỹ năng từ tiêu đề + mô tả, dùng chung từ điển với phần đọc CV (skillsDictionary.js).
// 4 quy tắc: (1) cụm dài khớp trước, (2) khớp theo ranh giới từ, (3) từ dễ nhầm chỉ nhận ở chỗ chắc chắn,
// (4) chia theo mục: Yêu cầu -> requiredSkills, Ưu tiên -> niceToHave.
const { SKILLS } = require("../../ai/skillsDictionary");

// Kỹ năng thường gặp trong tin tuyển dụng mà từ điển chung chưa có (không sửa file từ điển chung)
const EXTRA_SKILLS = [
  [".net", "dotnet", "asp.net"], ["c#", "csharp"], ["c++"], ["angular", "angularjs"],
  ["next.js", "nextjs"], ["nestjs", "nest.js"], ["django"], ["ruby"], ["scala"], ["rust"],
  ["sql server", "mssql"], ["oracle"], ["jira"], ["figma"],
];

// Từ dễ nhầm với tiếng thường
const AMBIGUOUS = new Set(["go", "rest", "spring", "ml", "node", "combine", "provider", "bloc", "monitoring", "backup", "replication", "expo", "scala", "rust", "ruby"]);

// Nhận dạng đúng dạng riêng: "Go developer", "Go lang"
const AMBIGUOUS_OWN_FORM = {
  go: /\bgo[\s-]?(developer|engineer|lang|backend|programmer)\b/i,
};

// Dòng tiêu đề mục trong mô tả
const NICE_HEADING = /^(ưu tiên|nice[\s-]to[\s-]have|plus|bonus|preferred|là một lợi thế|lợi thế|điểm cộng|advantage)/i;
const REQUIRED_HEADING = /^(yêu cầu|requirements?|qualifications?|what you('ll)? need|you have|you bring|kỹ năng|skills|must have)/i;
const IGNORE_HEADING = /^(quyền lợi|benefits?|phúc lợi|we offer|perks|what we offer|chế độ)/i;
const OTHER_HEADING = /^(mô tả|responsibilit|job description|about|giới thiệu|trách nhiệm|your role|what you('ll)? do)/i;

// Danh sách (alias -> tên chuẩn), cụm dài xếp trước
function buildAliasList() {
  const list = [];
  for (const names of [...SKILLS, ...EXTRA_SKILLS]) {
    for (const alias of names) list.push({ alias: alias.toLowerCase(), skill: names[0] });
  }
  return list.sort((a, b) => b.alias.length - a.alias.length);
}
const ALIASES = buildAliasList();

function escapeRegex(text) {
  return text.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

// Ranh giới từ: ký tự trước/sau không được là chữ, số, + hoặc # (nên "java" không khớp "javascript", "c" không khớp "c++")
const REGEX_CACHE = new Map();
function boundaryRegex(alias) {
  if (!REGEX_CACHE.has(alias)) {
    REGEX_CACHE.set(alias, new RegExp(`(?<![a-z0-9_+#.])${escapeRegex(alias)}(?![a-z0-9_+#])`, "gi"));
  }
  const regex = REGEX_CACHE.get(alias);
  regex.lastIndex = 0;
  return regex;
}

// Tìm kỹ năng trong 1 đoạn chữ. trusted = true nghĩa là chỗ chắc chắn (tiêu đề / mục Yêu cầu) nên nhận cả từ dễ nhầm.
function findSkillsInText(text, trusted) {
  let rest = text.toLowerCase();
  const found = new Set();
  for (const { alias, skill } of ALIASES) {
    // Từ dễ nhầm và chưa ở chỗ chắc chắn: chỉ nhận dạng riêng
    if (AMBIGUOUS.has(alias) && !trusted) {
      const own = AMBIGUOUS_OWN_FORM[alias];
      if (own && own.test(rest)) found.add(skill);
      continue;
    }
    const regex = boundaryRegex(alias);
    if (regex.test(rest)) {
      found.add(skill);
      // Che phần đã khớp để cụm ngắn không khớp lại ("react native" -> không còn "react")
      rest = rest.replace(boundaryRegex(alias), " ");
    }
  }
  return found;
}

// Cắt mô tả thành các mục: [{ kind: "required" | "nice" | "ignore" | "other", text }]
function splitSections(description) {
  const sections = [{ kind: "other", lines: [] }];
  for (const rawLine of String(description || "").split("\n")) {
    const line = rawLine.replace(/^[\s\-*•]+/, "").trim();
    const isHeading = line.length > 0 && line.length <= 60;
    let kind = null;
    if (isHeading && NICE_HEADING.test(line)) kind = "nice";
    else if (isHeading && IGNORE_HEADING.test(line)) kind = "ignore";
    else if (isHeading && REQUIRED_HEADING.test(line)) kind = "required";
    else if (isHeading && OTHER_HEADING.test(line)) kind = "other";
    if (kind) {
      sections.push({ kind, lines: [line] });
    } else {
      sections[sections.length - 1].lines.push(line);
    }
  }
  return sections.map((s) => ({ kind: s.kind, text: s.lines.join("\n") }));
}

// Đầu vào: tiêu đề + mô tả (đã xóa HTML). Đầu ra: { requiredSkills, niceToHave } (tên chuẩn, chữ thường)
function extractSkills(title, description) {
  const required = findSkillsInText(String(title || ""), true);
  const nice = new Set();

  for (const section of splitSections(description)) {
    if (section.kind === "ignore") continue;
    const trusted = section.kind === "required";
    const skills = findSkillsInText(section.text, trusted);
    const target = section.kind === "nice" ? nice : required;
    skills.forEach((s) => target.add(s));
  }

  // Kỹ năng đã bắt buộc thì không lặp ở mục ưu tiên
  required.forEach((s) => nice.delete(s));
  return { requiredSkills: [...required], niceToHave: [...nice] };
}

module.exports = { extractSkills, findSkillsInText, splitSections };
