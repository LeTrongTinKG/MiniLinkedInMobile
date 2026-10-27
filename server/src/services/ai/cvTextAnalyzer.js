const { SKILLS } = require("./skillsDictionary");

const escapeRegex = (s) => s.replace(/[.*+?^${}()|[\]\\/]/g, "\\$&");

// Khớp nguyên từ, không dính chữ/số hai bên (tránh "go" trong "good", "java" trong "javascript")
const toPattern = (term) => new RegExp(`(?<![a-z0-9])${escapeRegex(term)}(?![a-z0-9])`);

const PATTERNS = SKILLS.map(([name, ...aliases]) => ({
  name,
  regexes: [name, ...aliases].map(toPattern),
}));

function findSkills(text) {
  const lower = text.toLowerCase();
  return PATTERNS.filter(({ regexes }) => regexes.some((r) => r.test(lower))).map((p) => p.name);
}

function findExperienceMonths(text) {
  const years = text.match(/(\d+(?:[.,]\d+)?)\s*(?:năm|years?)\s+(?:kinh nghiệm|experience)/i);
  if (years) return Math.round(parseFloat(years[1].replace(",", ".")) * 12);
  const months = text.match(/(\d+)\s*(?:tháng|months?)\s+(?:kinh nghiệm|experience)/i);
  return months ? parseInt(months[1], 10) : 0;
}

function findEducation(text) {
  const line = text.split(/\r?\n/).find((l) => /đại học|university|học viện|college/i.test(l));
  return line ? line.trim().slice(0, 120) : null;
}

/**
 * Đọc chữ trong PDF rồi dò kỹ năng, học vấn, kinh nghiệm.
 * Ném lỗi nếu file không đọc được thành PDF (để caller quyết định fallback).
 */
async function extractPdfText(fileBuffer) {
  // Nạp muộn: pdfjs in cảnh báo khi require, chỉ cần khi thật sự đọc PDF
  const pdfjs = require("pdfjs-dist/legacy/build/pdf.js");
  const doc = await pdfjs.getDocument({
    data: new Uint8Array(fileBuffer),
    useSystemFonts: true,
    verbosity: 0,
  }).promise;
  const pages = [];
  for (let i = 1; i <= doc.numPages; i++) {
    const content = await (await doc.getPage(i)).getTextContent();
    pages.push(content.items.map((item) => item.str).join("\n"));
  }
  return pages.join("\n");
}

async function analyzePdfText(fileBuffer) {
  const text = await extractPdfText(fileBuffer);
  return {
    skills: findSkills(text),
    education: findEducation(text),
    experienceMonths: findExperienceMonths(text),
  };
}

module.exports = { analyzePdfText };
