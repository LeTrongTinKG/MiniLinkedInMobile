const test = require("node:test");
const assert = require("node:assert/strict");
const { match, analyzeCv } = require("../src/services/ai/mockAdapter");

const baseJob = { title: "Mobile Dev", description: "" };

test("match: 1/2 required khớp → score 50, missing đúng", async () => {
  const result = await match(["flutter"], {
    ...baseJob,
    requiredSkills: ["flutter", "rest api"],
    niceToHave: [],
  });
  assert.equal(result.score, 50);
  assert.deepEqual(result.missingSkills, ["rest api"]);
  assert.deepEqual(result.matchedSkills, ["flutter"]);
});

test("match: khớp đủ required → score 100, không thiếu gì", async () => {
  const result = await match(["flutter", "dart", "git"], {
    ...baseJob,
    requiredSkills: ["flutter", "dart", "git"],
    niceToHave: [],
  });
  assert.equal(result.score, 100);
  assert.deepEqual(result.missingSkills, []);
  assert.equal(result.suggestion, "Bạn đã có đủ kỹ năng chính");
});

test("match: chữ hoa và khoảng trắng vẫn khớp", async () => {
  const result = await match(["Flutter "], {
    ...baseJob,
    requiredSkills: ["flutter"],
    niceToHave: [],
  });
  assert.equal(result.score, 100);
});

test("match: required và niceToHave đều rỗng → score 0", async () => {
  const result = await match(["flutter"], {
    ...baseJob,
    requiredSkills: [],
    niceToHave: [],
  });
  assert.equal(result.score, 0);
  assert.deepEqual(result.matchedSkills, []);
  assert.deepEqual(result.missingSkills, []);
});

test("match: required rỗng, dùng niceToHave để tính score", async () => {
  const result = await match(["git"], {
    ...baseJob,
    requiredSkills: [],
    niceToHave: ["git", "docker"],
  });
  assert.equal(result.score, 50);
});

test("match: suggestion chứa tên kỹ năng còn thiếu", async () => {
  const result = await match([], {
    ...baseJob,
    requiredSkills: ["flutter", "dart"],
    niceToHave: [],
  });
  assert.ok(result.suggestion.includes("flutter"));
  assert.ok(result.suggestion.includes("dart"));
});

test("match: kỹ năng trùng trong đầu vào chỉ tính 1 lần", async () => {
  const result = await match(["flutter", "flutter", "FLUTTER"], {
    ...baseJob,
    requiredSkills: ["flutter"],
    niceToHave: [],
  });
  assert.equal(result.score, 100);
  assert.deepEqual(result.matchedSkills, ["flutter"]);
});

test("analyzeCv: file không đọc được vẫn trả đúng cấu trúc, không bịa kỹ năng", async () => {
  const result = await analyzeCv(Buffer.from("fake"), "cv.pdf");
  assert.ok(Array.isArray(result.skills));
  // ADR-0005: file không đọc được thì không có kỹ năng nào, không bịa sẵn
  assert.deepEqual(result.skills, []);
  assert.ok(typeof result.experienceMonths === "number");
});
