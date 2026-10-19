const mockAdapter = require("./mockAdapter");
const httpAdapter = require("./httpAdapter");
const { AiServiceError } = require("./errors");

function isRealMode() {
  return (process.env.AI_MODE || "mock") === "real";
}

function isFallbackEnabled() {
  return process.env.AI_FALLBACK_TO_MOCK === "true";
}

async function withFallback(realFn, mockFn, label) {
  try {
    return await realFn();
  } catch (err) {
    if (isFallbackEnabled()) {
      console.warn(`[aiClient] ${label} — fallback to mock (${err.message})`);
      return await mockFn();
    }
    throw err;
  }
}

async function analyzeCv(fileBuffer, fileName) {
  if (!isRealMode()) return mockAdapter.analyzeCv(fileBuffer, fileName);
  return withFallback(
    () => httpAdapter.analyzeCv(fileBuffer, fileName),
    () => mockAdapter.analyzeCv(fileBuffer, fileName),
    "analyzeCv"
  );
}

async function match(cvSkills, job) {
  if (!isRealMode()) return mockAdapter.match(cvSkills, job);
  return withFallback(
    () => httpAdapter.match(cvSkills, job),
    () => mockAdapter.match(cvSkills, job),
    "match"
  );
}

module.exports = { analyzeCv, match, AiServiceError };
