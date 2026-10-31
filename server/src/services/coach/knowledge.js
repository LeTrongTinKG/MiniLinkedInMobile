const fs = require("fs");
const path = require("path");

/** Kho ngữ cảnh đã duyệt (ADR-0008). Câu trả lời chỉ lấy một câu giọng của đúng bước, không nhét cả kho vào model. */

const DIR = path.join(__dirname, "knowledge");

function parse(text) {
  const front = text.match(/^---\n([\s\S]*?)\n---/);
  const meta = {};
  if (front) {
    for (const line of front[1].split("\n")) {
      const at = line.indexOf(":");
      if (at > 0) meta[line.slice(0, at).trim()] = line.slice(at + 1).trim();
    }
  }
  const voices = new Map();
  let step = null;
  for (const line of text.split("\n")) {
    const heading = line.match(/^## step (\d+)/);
    if (heading) step = Number(heading[1]);
    else if (step && line.startsWith("Giọng:")) voices.set(step, line.replace(/^Giọng:\s*/, "").trim());
  }
  return { meta, voices };
}

let cache = null;
function docs() {
  cache ??= fs
    .readdirSync(DIR)
    .filter((file) => file.endsWith(".md"))
    .map((file) => parse(fs.readFileSync(path.join(DIR, file), "utf8")))
    .filter((doc) => doc.meta.status === "reviewed");
  return cache;
}

function voiceHint(roleId, stepNumber) {
  const doc = docs().find((item) => item.meta.role === roleId);
  return doc?.voices.get(stepNumber) ?? null;
}

/** Câu có ít nhất 8 từ. Dùng để kiểm tra kho không bị rút ngắn dưới 500 câu. */
function sentenceCount() {
  return fs
    .readdirSync(DIR)
    .filter((file) => file.endsWith(".md"))
    .reduce((sum, file) => {
      const text = fs.readFileSync(path.join(DIR, file), "utf8");
      const count = text.split(/[.!?]/).map((part) => part.trim()).filter((part) => part.split(/\s+/).length >= 8).length;
      return sum + count;
    }, 0);
}

module.exports = { voiceHint, sentenceCount };
