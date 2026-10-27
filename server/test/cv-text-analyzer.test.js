const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const test = require("node:test");
const { analyzeCv } = require("../src/services/ai/mockAdapter");

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
