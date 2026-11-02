const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const test = require("node:test");
const { analyzeCv } = require("../src/services/ai/mockAdapter");
const { withEvidence } = require("../src/services/ai/cvTextAnalyzer");

const samplePdf = fs.readFileSync(path.join(__dirname, "fixtures", "cv-sample.pdf"));

test("analyzeCv: đọc chữ trong PDF và dò đúng kỹ năng có trong CV", async () => {
  const result = await analyzeCv(samplePdf, "cv.pdf");
  for (const skill of ["flutter", "dart", "git", "firebase", "rest api", "nodejs", "postgresql"]) {
    assert.ok(result.skills.includes(skill), `thiếu kỹ năng ${skill}`);
  }
});

test("analyzeCv: không dò nhầm kỹ năng không có trong CV", async () => {
  const result = await analyzeCv(samplePdf, "cv.pdf");
  assert.ok(!result.skills.includes("python"));
  assert.ok(!result.skills.includes("javascript"), "node.js không được tính là javascript");
  assert.ok(!result.skills.includes("java"));
});

test("withEvidence: mỗi kỹ năng giữ lại đều kèm câu trích có thật trong CV", async () => {
  const result = await withEvidence(samplePdf, { skills: ["flutter", "Node.js", "postgresql"] });
  assert.deepEqual(result.skills, ["flutter", "nodejs", "postgresql"]);
  for (const item of result.evidence) {
    assert.ok(item.quote.length > 0 && item.quote.length <= 160);
  }
});

test("withEvidence: kỹ năng AI trả về nhưng CV không nhắc tới thì bị bỏ", async () => {
  const result = await withEvidence(samplePdf, { skills: ["flutter", "python", "kubernetes"] });
  assert.deepEqual(result.skills, ["flutter"]);
  assert.equal(result.evidence.length, 1);
});

test("withEvidence: PDF không đọc được thì không còn kỹ năng nào", async () => {
  const result = await withEvidence(Buffer.from("not a pdf"), { skills: ["flutter"], education: null });
  assert.deepEqual(result.skills, []);
  assert.deepEqual(result.evidence, []);
});
