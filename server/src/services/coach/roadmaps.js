const fs = require("fs");
const path = require("path");
const { SKILLS } = require("../ai/skillsDictionary");

/**
 * Lộ trình đã duyệt (ADR-0008): mỗi file markdown có front matter `status: reviewed`
 * và một bảng 5 cột: Bước | Skill cần có | Học gì | Bằng chứng nên có | Thời gian gợi ý.
 */

const ROADMAP_DIR = path.join(__dirname, "roadmaps");

const ALIAS_TO_NAME = new Map(SKILLS.flatMap((names) => names.map((alias) => [alias, names[0]])));

/** Tên chuẩn trong từ điển ("Provider" -> "state management"); không có thì trả chữ thường. */
function canonicalSkill(name) {
  const key = String(name ?? "").trim().toLowerCase();
  return ALIAS_TO_NAME.get(key) ?? key;
}

function parseFrontMatter(text) {
  const match = text.match(/^---\n([\s\S]*?)\n---/);
  if (!match) return {};
  return Object.fromEntries(
    match[1].split("\n").map((line) => {
      const at = line.indexOf(":");
      return [line.slice(0, at).trim(), line.slice(at + 1).trim()];
    }),
  );
}

// "`bloc` hoặc `state management` (Riverpod)" -> một nhóm có 2 lựa chọn; dấu phẩy tách nhóm.
function parseSkillCell(cell) {
  return cell
    .split(",")
    .map((part) => [...part.matchAll(/`([^`]+)`/g)].map((m) => canonicalSkill(m[1])))
    .filter((group) => group.length > 0);
}

function parseSteps(text) {
  return text
    .split("\n")
    .filter((line) => /^\|\s*\d+\./.test(line))
    .map((line) => {
      const [title, skills, learn, proof, time] = line.split("|").slice(1, 6).map((cell) => cell.trim());
      return {
        number: Number(title.match(/^(\d+)/)[1]),
        title: title.replace(/^\d+\.\s*/, ""),
        groups: parseSkillCell(skills),
        learn: learn.replace(/`/g, ""),
        proof: proof.replace(/`/g, ""),
        weeks: Number(time.match(/(\d+)/)?.[1] ?? 0),
      };
    });
}

function parseRoadmap(text) {
  const meta = parseFrontMatter(text);
  return { id: meta.role, title: meta.title, status: meta.status, steps: parseSteps(text) };
}

function loadRoadmaps(dir = ROADMAP_DIR) {
  return fs
    .readdirSync(dir)
    .filter((file) => file.endsWith(".md"))
    .map((file) => parseRoadmap(fs.readFileSync(path.join(dir, file), "utf8")))
    .filter((roadmap) => roadmap.status === "reviewed" && roadmap.id && roadmap.steps.length > 0);
}

let cache = null;
function reviewedRoadmaps() {
  cache ??= loadRoadmaps();
  return cache;
}

function findRoadmap(id) {
  return reviewedRoadmaps().find((roadmap) => roadmap.id === id) ?? null;
}

module.exports = { canonicalSkill, parseRoadmap, loadRoadmaps, reviewedRoadmaps, findRoadmap };
