const test = require("node:test");
const assert = require("node:assert/strict");
const { extractSuggestions, parsePubspec, parsePackageJson } = require("../src/services/skills/extractRules");

const pubspec = `name: todo
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.0
`;

const repo = (name, dartBytes = 95) => ({
  repo: `me/${name}`,
  url: `https://github.com/me/${name}`,
  languageBytes: { Dart: dartBytes, Other: 100 - dartBytes },
  dependencies: { pub: parsePubspec(pubspec) },
  text: "",
});

test("repo Flutter đề xuất Flutter, Provider, Dart, kèm repo và dấu hiệu", () => {
  const result = extractSuggestions({ sources: [repo("todo")] });
  assert.deepEqual(result.map((s) => s.name).sort(), ["Dart", "Flutter", "Provider"]);
  const provider = result.find((s) => s.name === "Provider");
  assert.deepEqual(provider.evidence, [
    { repo: "me/todo", url: "https://github.com/me/todo", signals: ["dependency:pub:provider"] },
  ]);
});

test("mọi đề xuất đều có ít nhất một bằng chứng", () => {
  const result = extractSuggestions({ sources: [repo("a"), repo("b")] });
  assert.ok(result.length > 0);
  for (const s of result) {
    assert.ok(s.evidence.length > 0);
    for (const e of s.evidence) assert.ok(e.signals.length > 0);
  }
});

test("skill đã có trong hồ sơ (khác hoa thường) không đề xuất lại", () => {
  const result = extractSuggestions({ sources: [repo("todo")], existingNames: ["flutter"] });
  assert.deepEqual(result.map((s) => s.name).sort(), ["Dart", "Provider"]);
});

test("chữ react trong câu thường không phải skill React", () => {
  const result = extractSuggestions({ sources: [{ repo: "me/x", text: "we react quickly to issues" }] });
  assert.equal(result.some((s) => s.name === "React"), false);
});

test("từ khóa quá ngắn (Go) không đủ làm bằng chứng", () => {
  const result = extractSuggestions({ sources: [{ repo: "me/x", text: "Let's Go to the park" }] });
  assert.equal(result.some((s) => s.name === "Go"), false);
});

test("ngôn ngữ dưới 10% số byte không tính", () => {
  const result = extractSuggestions({ sources: [{ repo: "me/x", languageBytes: { Dart: 5, Other: 95 } }] });
  assert.equal(result.some((s) => s.name === "Dart"), false);
});

test("cùng thư viện ở hai repo là một đề xuất với hai bằng chứng", () => {
  const result = extractSuggestions({ sources: [repo("a"), repo("b")] });
  const provider = result.find((s) => s.name === "Provider");
  assert.deepEqual(provider.evidence.map((e) => e.repo), ["me/a", "me/b"]);
});

test("package.json chỉ đọc tên thư viện, bỏ qua scripts", () => {
  const names = parsePackageJson(
    JSON.stringify({
      scripts: { build: "echo react && rm -rf /" },
      dependencies: { react: "^18.0.0" },
      devDependencies: { typescript: "^5.0.0" },
    })
  );
  assert.deepEqual(names.sort(), ["react", "typescript"]);
  assert.deepEqual(parsePackageJson("not json"), []);
});
