// Trích skill bằng quy tắc (ADR-0005). Chép từ Atom: supabase/functions/_shared/extract.ts.
// Chỉ đề xuất skill khi có dấu hiệu cụ thể trong repo; mỗi đề xuất ghi rõ repo nào, dấu hiệu nào.
const RULES = require("./skillRules.json");

const normalizeSkillName = (name) => String(name).trim().replace(/\s+/g, " ").toLowerCase();

function parsePubspec(yaml) {
  const names = [];
  let inDependencies = false;
  for (const line of yaml.split("\n")) {
    if (!inDependencies) {
      if (/^dependencies:\s*$/.test(line)) inDependencies = true;
      continue;
    }
    if (/^\S/.test(line)) break;
    const match = line.match(/^  ([A-Za-z0-9_]+)\s*:/);
    if (match) names.push(match[1]);
  }
  return names;
}

// Chỉ đọc tên thư viện; scripts và phần chữ khác bị bỏ qua.
function parsePackageJson(text) {
  try {
    const data = JSON.parse(text);
    const names = [...Object.keys(data?.dependencies ?? {}), ...Object.keys(data?.devDependencies ?? {})];
    return names.filter((n) => n.length > 0 && n.length <= 200 && /^[@A-Za-z0-9._/-]+$/.test(n));
  } catch {
    return [];
  }
}

function wholeWord(text, word, sensitive) {
  const escaped = word.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  return new RegExp(`(^|[^A-Za-z0-9_])${escaped}([^A-Za-z0-9_]|$)`, sensitive ? "" : "i").test(text);
}

// Ngôn ngữ chiếm từ 10% số byte của repo trở lên mới tính.
function languagesOf(source) {
  const bytes = source.languageBytes ?? {};
  const total = Object.values(bytes).reduce((sum, v) => sum + v, 0);
  if (total <= 0) return [];
  return Object.entries(bytes).filter(([, v]) => v / total >= 0.1).map(([name]) => name);
}

function signalsFor(rule, source) {
  const s = rule.signals;
  const found = [];
  for (const lang of languagesOf(source)) if (s.languages.includes(lang)) found.push(`language:${lang}`);
  for (const [eco, names] of Object.entries(source.dependencies ?? {})) {
    const known = new Set((s.dependencies[eco] ?? []).map((n) => n.toLowerCase()));
    for (const n of names) if (known.has(n.toLowerCase())) found.push(`dependency:${eco}:${n.toLowerCase()}`);
  }
  const topics = s.topics.map((t) => t.toLowerCase());
  for (const t of source.topics ?? []) if (topics.includes(t.toLowerCase())) found.push(`topic:${t.toLowerCase()}`);
  for (const f of source.rootFiles ?? []) if (s.files.includes(f)) found.push(`file:${f}`);
  const text = source.text ?? "";
  for (const k of s.keywords) if (wholeWord(text, k, false)) found.push(`keyword:${k.toLowerCase()}`);
  for (const k of s.keywords_case_sensitive) if (wholeWord(text, k, true)) found.push(`keyword:${k}`);
  // Từ khóa dưới 3 ký tự (vd "Go") quá dễ trùng, không đủ làm bằng chứng.
  return [...new Set(found)].filter((x) => !(x.startsWith("keyword:") && x.length - 8 < 3));
}

const rank = { dependency: 4, language: 3, topic: 2, file: 2, keyword: 1 };
const best = (s) => Math.max(...s.evidence.flatMap((e) => e.signals.map((x) => rank[x.split(":")[0]] ?? 0)));

/**
 * sources: [{ repo, url, languageBytes, topics, rootFiles, dependencies, text }]
 * Trả tối đa 20 đề xuất: { name, evidence: [{ repo, url, signals }] }.
 */
function extractSuggestions({ sources, existingNames = [], rules = RULES }) {
  const owned = new Set(existingNames.map(normalizeSkillName));
  const found = new Map();
  for (const source of sources) {
    for (const rule of rules) {
      const signals = signalsFor(rule, source);
      if (signals.length === 0) continue;
      const current = found.get(rule.id) ?? { rule, name: rule.name, evidence: [] };
      current.evidence.push({ repo: source.repo, url: source.url, signals });
      found.set(rule.id, current);
    }
  }
  return [...found.values()]
    .filter(({ rule }) => [rule.name, ...rule.aliases].every((n) => !owned.has(normalizeSkillName(n))))
    .sort((a, b) => b.evidence.length - a.evidence.length || best(b) - best(a) || a.name.localeCompare(b.name))
    .slice(0, 20)
    .map(({ name, evidence }) => ({ name, evidence }));
}

module.exports = { extractSuggestions, parsePubspec, parsePackageJson, normalizeSkillName, RULES };
