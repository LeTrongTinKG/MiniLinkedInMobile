const { normalize } = require("./mapper");
const { analyzePdfText } = require("./cvTextAnalyzer");

const DEFAULT_ANALYSIS = {
  skills: ["flutter", "dart", "git"],
  education: "CNTT năm 4",
  experienceMonths: 6,
};

// Đọc chữ thật trong PDF; file không đọc được thì trả kết quả mặc định như trước
async function analyzeCv(fileBuffer, _fileName) {
  try {
    return await analyzePdfText(fileBuffer);
  } catch (_err) {
    return { ...DEFAULT_ANALYSIS };
  }
}

async function match(cvSkills, job) {
  const mySkills = normalize(cvSkills);
  const required = normalize(job.requiredSkills ?? []);
  const niceToHave = normalize(job.niceToHave ?? []);

  let score = 0;
  let matchedSkills = [];
  let missingSkills = [];

  if (required.length > 0) {
    matchedSkills = required.filter((s) => mySkills.includes(s));
    missingSkills = required.filter((s) => !mySkills.includes(s));
    score = Math.round((matchedSkills.length / required.length) * 100);
  } else if (niceToHave.length > 0) {
    const matchedNice = niceToHave.filter((s) => mySkills.includes(s));
    score = Math.round((matchedNice.length / niceToHave.length) * 100);
  }

  const suggestion =
    missingSkills.length > 0
      ? `Học thêm ${missingSkills.join(", ")}`
      : "Bạn đã có đủ kỹ năng chính";

  return { score, matchedSkills, missingSkills, suggestion };
}

module.exports = { analyzeCv, match };
