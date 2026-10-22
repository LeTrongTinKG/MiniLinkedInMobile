const { AiServiceError } = require("./errors");
const { analyzeResultToCamel, matchParamsToSnake, matchResultToCamel } = require("./mapper");

const normalize = (arr) =>
  [...new Set((arr ?? []).map((s) => s.trim().toLowerCase()).filter(Boolean))];

function getBaseUrl() {
  return (process.env.AI_SERVICE_URL || "http://localhost:8000").replace(/\/$/, "");
}

async function fetchWithTimeout(url, options, timeoutMs) {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), timeoutMs);
  try {
    return await fetch(url, { ...options, signal: controller.signal });
  } catch (err) {
    if (err.name === "AbortError") {
      throw new AiServiceError("TIMEOUT", `AI service timeout: ${url}`, 504);
    }
    throw new AiServiceError(
      "CONNECTION_ERROR",
      `Không kết nối được AI service: ${err.message}`,
      502
    );
  } finally {
    clearTimeout(timer);
  }
}

async function parseAiResponse(res) {
  const text = await res.text();
  let data;
  try {
    data = JSON.parse(text);
  } catch (_err) {
    throw new AiServiceError(
      "INVALID_RESPONSE",
      `AI service trả về định dạng không hợp lệ (HTTP ${res.status})`,
      res.status >= 400 ? res.status : 502
    );
  }

  if (!res.ok) {
    throw new AiServiceError(
      data?.error?.code ?? "AI_ERROR",
      data?.error?.message ?? "AI service trả về lỗi",
      res.status
    );
  }
  return data;
}

async function checkHealth() {
  const res = await fetchWithTimeout(
    `${getBaseUrl()}/health`,
    { method: "GET" },
    3_000
  );
  return parseAiResponse(res);
}

async function analyzeCv(fileBuffer, fileName) {
  const form = new FormData();
  form.append("file", new Blob([fileBuffer], { type: "application/pdf" }), fileName);

  const res = await fetchWithTimeout(
    `${getBaseUrl()}/analyze-cv`,
    { method: "POST", body: form },
    15_000
  );

  const data = await parseAiResponse(res);
  const result = analyzeResultToCamel(data);
  result.skills = normalize(result.skills);
  return result;
}

async function match(cvSkills, job) {
  const body = matchParamsToSnake(normalize(cvSkills), job);

  const res = await fetchWithTimeout(
    `${getBaseUrl()}/match`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body),
    },
    3_000
  );

  const data = await parseAiResponse(res);
  const result = matchResultToCamel(data);
  result.matchedSkills = normalize(result.matchedSkills);
  result.missingSkills = normalize(result.missingSkills);
  return result;
}

module.exports = { analyzeCv, match, checkHealth };
