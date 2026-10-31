// Chạy 30 câu của docs/chatbot/eval-30.md qua chatbot thật, xuất bảng markdown để chấm tay.
// Cách chạy: COACH_MODE=ollama OLLAMA_MODEL=qwen3.5:4b-q4_K_M node scripts/coach-eval.js > ../docs/chatbot/eval-runs/<ngày>-<model>.md
const coachService = require("../src/services/coach.service");
const { createOllamaWriter } = require("../src/services/coach/ollamaWriter");
const { CASES, personaFor, fakeCoachRepo } = require("./coach-eval-cases");

const oneLine = (text) => String(text).replace(/\s+/g, " ").replace(/\|/g, "/");

async function main() {
  const writer = createOllamaWriter({ mode: process.env.COACH_MODE ?? "ollama" });
  const model = process.env.OLLAMA_MODEL ?? "qwen3.5:2b-q4_K_M";
  const warmStart = Date.now();
  const warmed = await writer.warmUp();
  const rows = [];
  for (const c of CASES) {
    const started = Date.now();
    const result = await coachService.ask("eval", { question: c.q }, { repo: fakeCoachRepo(personaFor(c.who)), writer });
    rows.push({ c, result, seconds: (Date.now() - started) / 1000 });
  }

  const times = rows.map((row) => row.seconds).sort((a, b) => a - b);
  const within = rows.filter((row) => row.seconds <= 10).length;
  const byModel = rows.filter((row) => row.result.mode === "ollama").length;
  const answered = rows.filter((row) => !row.result.refused).length;
  console.log(`# Lần chạy ${new Date().toISOString().slice(0, 16)} · ${writer.enabled ? model : "chỉ quy tắc"}\n`);
  console.log(`- Nạp model: ${warmed ? ((Date.now() - warmStart) / 1000).toFixed(1) + " giây (không tính)" : "không nạp"}`);
  console.log(`- Trả lời trong 10 giây: ${within}/30 · chậm nhất ${times.at(-1).toFixed(1)} giây · trung vị ${times[15].toFixed(1)} giây`);
  console.log(`- Model viết lại được dùng: ${byModel}/${answered} câu có trả lời (còn lại model lỗi, quá giờ hoặc bị bộ kiểm tra loại)\n`);
  console.log("| # | Nhóm | Câu hỏi | Trả lời | Nguồn | Giây | Đúng việc | Bám dữ liệu | Đúng trọng tâm |");
  console.log("|---|---|---|---|---|---|---|---|---|");
  for (const { c, result, seconds } of rows) {
    const source = result.refused ? "từ chối" : result.mode;
    console.log(`| ${c.n} | ${c.group} | ${oneLine(c.q)} | ${oneLine(result.answer)} | ${source} | ${seconds.toFixed(1)} | | | |`);
  }
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
