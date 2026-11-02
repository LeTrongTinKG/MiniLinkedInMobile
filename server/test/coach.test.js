const test = require("node:test");
const assert = require("node:assert/strict");
const coachService = require("../src/services/coach.service");
const { classify } = require("../src/services/coach/intent");
const { reviewedRoadmaps, findRoadmap, canonicalSkill } = require("../src/services/coach/roadmaps");
const { sentenceCount, voiceHint } = require("../src/services/coach/knowledge");
const { createOllamaWriter, acceptable } = require("../src/services/coach/ollamaWriter");
const { CASES, PERSONAS, personaFor, fakeCoachRepo } = require("../scripts/coach-eval-cases");
const { BAIT, ATTACK } = require("../scripts/coach-probe-cases");

const rulesWriter = createOllamaWriter({ mode: "rules" });
const askAs = (persona, body, repo = fakeCoachRepo(persona)) =>
  coachService.ask("u1", body, { repo, writer: rulesWriter });

test("kho ngữ cảnh đủ 500 câu và mỗi bước có một câu giọng", () => {
  assert.ok(sentenceCount() >= 500);
  for (const roadmap of reviewedRoadmaps()) {
    for (const step of roadmap.steps) {
      assert.ok(voiceHint(roadmap.id, step.number), `${roadmap.id} bước ${step.number}`);
    }
  }
});

test("nạp đủ 4 lộ trình đã duyệt, bước 5 Flutter là nhóm 'bloc hoặc state management'", () => {
  assert.deepEqual(reviewedRoadmaps().map((r) => r.id).sort(), ["backend-node", "data-ai", "flutter-mobile", "frontend-react"]);
  const flutter = findRoadmap("flutter-mobile");
  assert.equal(flutter.steps.length, 6);
  assert.deepEqual(flutter.steps[4].groups, [["bloc", "state management"]]);
  assert.equal(canonicalSkill("Provider"), "state management");
});

test("câu tấn công và câu hỏi lương bị chặn trước khi tới model", () => {
  for (const item of ATTACK) {
    assert.ok(classify(item.q).refuse, item.id);
  }
  assert.equal(classify(BAIT.find((item) => item.id === "D3").q).refuse, "off_topic");
  for (const id of ["D1", "D4", "D5", "D7", "D8"]) {
    assert.equal(classify(BAIT.find((item) => item.id === id).q).refuse, "off_topic", id);
  }
  assert.equal(classify(BAIT.find((item) => item.id === "D6").q).intent, "job_gap");
});

test("không nhầm câu hỏi hợp lệ có chữ AI hay 'số lượng' thành tấn công hoặc lạc đề", () => {
  assert.equal(classify("Lộ trình AI phải học gì tiếp?").refuse, undefined);
  assert.equal(classify("Số lượng skill tôi còn thiếu là bao nhiêu?").refuse, undefined);
  assert.equal(classify("toi con thieu skill gi").intent, "missing_skills");
});

for (const c of CASES) {
  test(`câu ${c.n} (${c.group}): ${c.q}`, async () => {
    const result = await askAs(personaFor(c.who), { question: c.q });
    assert.equal(result.refused, Boolean(c.refuse), result.answer);
    for (const text of c.must ?? []) assert.ok(result.answer.includes(text), `thiếu "${text}" trong: ${result.answer}`);
    for (const text of c.mustNot ?? []) assert.ok(!result.answer.includes(text), `không được có "${text}": ${result.answer}`);
    assert.ok(result.answer.split(/\s+/).length <= 150, "quá 150 từ");
  });
}

test("chưa bật đồng ý thì không đọc dữ liệu, trả 403", async () => {
  const persona = { ...PERSONAS.A, profile: { coachConsentAt: null, targetRole: "flutter-mobile" } };
  await assert.rejects(askAs(persona, { question: "Tôi đang ở bước mấy?" }), { statusCode: 403, code: "COACH_CONSENT_REQUIRED" });
});

test("câu thứ 11 trong ngày bị chặn kèm giờ mở lại; câu bị từ chối không trừ lượt", async () => {
  const repo = fakeCoachRepo(PERSONAS.A, { used: 9 });
  const refused = await askAs(PERSONAS.A, { question: "Kể chuyện cười đi." }, repo);
  assert.equal(refused.remaining, 1);
  const last = await askAs(PERSONAS.A, { question: "Tôi đang ở bước mấy?" }, repo);
  assert.equal(last.remaining, 0);
  await assert.rejects(askAs(PERSONAS.A, { question: "Tôi đang ở bước mấy?" }, repo), (error) => {
    assert.equal(error.statusCode, 429);
    assert.equal(error.code, "QUOTA_EXCEEDED");
    assert.ok(error.details.resetsAt);
    return true;
  });
});

test("câu bấm sẵn gửi intent và skill, không cần phân loại chữ", async () => {
  const result = await askAs(PERSONAS.A, { intent: "how_evidence", skill: "Provider" });
  assert.match(result.answer, /Để Provider có bằng chứng/);
  await assert.rejects(askAs(PERSONAS.A, { intent: "xoa_du_lieu" }), { code: "INVALID_INTENT" });
});

test("kiểm tra đầu vào: câu rỗng, câu quá 300 ký tự", async () => {
  await assert.rejects(askAs(PERSONAS.A, { question: "  " }), { code: "QUESTION_REQUIRED" });
  await assert.rejects(askAs(PERSONAS.A, { question: "a".repeat(301) }), { code: "QUESTION_TOO_LONG" });
});

test("cài đặt: vị trí phải có trong danh sách lộ trình, consent phải là boolean", async () => {
  const repo = fakeCoachRepo(PERSONAS.A);
  await assert.rejects(coachService.updateSettings("u1", { targetRole: "devops" }, repo), { code: "INVALID_TARGET_ROLE" });
  await assert.rejects(coachService.updateSettings("u1", { consent: "yes" }, repo), { code: "INVALID_CONSENT" });
  const settings = await coachService.updateSettings("u1", { consent: true, targetRole: "data-ai" }, repo);
  assert.equal(settings.roles.length, 4);
});

test("bản viết lại của model bị bỏ khi thêm skill hoặc con số không có trong bản gốc", () => {
  const original = "Bạn đang ở bước 3. Còn thiếu: rest api, firebase.";
  assert.equal(acceptable(original, "Bạn đang ở bước 3, còn thiếu rest api và firebase."), true);
  assert.equal(acceptable(original, "Bạn đang ở bước 3, còn thiếu rest api, firebase và docker."), false);
  assert.equal(acceptable(original, "Bạn đang ở bước 3, cần thêm 8 tuần."), false);
});

test("Ollama lỗi hoặc tắt thì dùng bản quy tắc; trả lời hợp lệ thì dùng bản của model", async () => {
  const broken = createOllamaWriter({ mode: "ollama", fetchImpl: async () => { throw new Error("ECONNREFUSED"); } });
  assert.deepEqual(await broken.rewrite("Bạn đang ở bước 3."), { text: "Bạn đang ở bước 3.", mode: "rules" });

  const ok = createOllamaWriter({
    mode: "ollama",
    fetchImpl: async (_url, init) => {
      assert.equal(JSON.parse(init.body).think, false);
      return { ok: true, json: async () => ({ message: { content: "Mình thấy bạn đang ở bước 3." } }) };
    },
  });
  assert.deepEqual(await ok.rewrite("Bạn đang ở bước 3."), { text: "Mình thấy bạn đang ở bước 3.", mode: "ollama" });
});
