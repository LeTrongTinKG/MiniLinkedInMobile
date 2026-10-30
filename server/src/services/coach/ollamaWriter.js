const { mentionedSkills } = require("./intent");

/**
 * Model chỉ viết lại câu trả lời quy tắc cho tự nhiên (ADR-0008).
 * Kết quả bị bỏ, dùng lại bản quy tắc, khi: lỗi, quá giờ, quá 150 từ, nhắc skill hoặc con số không có trong bản gốc.
 */

const MAX_WORDS = 150;
const SYSTEM_PROMPT = [
  "Bạn viết lại đoạn thông tin dưới đây thành lời tư vấn ngắn bằng tiếng Việt cho một sinh viên, xưng 'mình', gọi 'bạn'.",
  "Giữ nguyên mọi tên skill, số bước, số tuần, tên job và tên lộ trình.",
  "Không thêm skill, con số, lời khuyên hay thông tin nào không có trong đoạn gốc.",
  "'Còn thiếu' và 'chưa có bằng chứng' là hai ý khác nhau, giữ đúng từng ý.",
  "Tối đa 120 từ. Chỉ trả về đoạn văn, không tiêu đề, không gạch đầu dòng.",
].join(" ");

const numbersIn = (text) => new Set(text.match(/\d+/g) ?? []);

function acceptable(original, rewritten) {
  if (!rewritten || rewritten.split(/\s+/).length > MAX_WORDS) return false;
  const allowedSkills = new Set(mentionedSkills(original));
  if (mentionedSkills(rewritten).some((name) => !allowedSkills.has(name))) return false;
  const allowedNumbers = numbersIn(original);
  return [...numbersIn(rewritten)].every((n) => allowedNumbers.has(n));
}

function createOllamaWriter({
  fetchImpl = globalThis.fetch,
  mode = process.env.COACH_MODE ?? "rules",
  url = process.env.OLLAMA_URL ?? "http://localhost:11434",
  model = process.env.OLLAMA_MODEL ?? "qwen3.5:2b-q4_K_M",
  timeoutMs = 10_000,
} = {}) {
  const enabled = mode === "ollama";

  async function chat(messages) {
    const response = await fetchImpl(`${url}/api/chat`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        model,
        messages,
        stream: false,
        think: false,
        keep_alive: "30m",
        options: { temperature: 0.2, num_predict: 300 },
      }),
      signal: AbortSignal.timeout(timeoutMs),
    });
    if (!response.ok) throw new Error(`Ollama ${response.status}`);
    return response.json();
  }

  async function rewrite(text) {
    if (!enabled) return { text, mode: "rules" };
    try {
      const body = await chat([
        { role: "system", content: SYSTEM_PROMPT },
        { role: "user", content: text },
      ]);
      const rewritten = String(body?.message?.content ?? "").trim();
      return acceptable(text, rewritten) ? { text: rewritten, mode: "ollama" } : { text, mode: "rules" };
    } catch {
      return { text, mode: "rules" };
    }
  }

  // Nạp model sẵn lúc server khởi động: lần nạp đầu mất 15–25 giây trên Mac 8 GB.
  async function warmUp() {
    if (!enabled) return false;
    try {
      await fetchImpl(`${url}/api/chat`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ model, messages: [], keep_alive: "30m" }),
        signal: AbortSignal.timeout(60_000),
      });
      return true;
    } catch {
      return false;
    }
  }

  return { enabled, rewrite, warmUp };
}

module.exports = { createOllamaWriter, acceptable };
