// Test trích kỹ năng và phân tích lương
const test = require("node:test");
const assert = require("node:assert");
const { extractSkills, findSkillsInText } = require("../../src/services/job-sync/cleaner/skills");
const { parseSalary, parseSalaryText } = require("../../src/services/job-sync/cleaner/salary");

test("skills: ranh giới từ, cụm dài trước", () => {
  const found = findSkillsInText("We use JavaScript and Java with React Native", false);
  assert.ok(found.has("javascript"));
  assert.ok(found.has("java"));
  assert.ok(found.has("react native"));
  assert.ok(!found.has("react"), "react native không được đếm thành react");
  // java không khớp trong javascript
  assert.deepStrictEqual([...findSkillsInText("javascript only", false)], ["javascript"]);
  // c++, c#, .net, node.js có luật riêng
  const special = findSkillsInText("C++, C#, .NET và Node.js", false);
  assert.ok(special.has("c++") && special.has("c#") && special.has(".net") && special.has("nodejs"));
});

test("skills: từ dễ nhầm chỉ nhận ở chỗ chắc chắn", () => {
  assert.strictEqual(extractSkills("Dev", "We love to go the extra mile and use rest of time").requiredSkills.length, 0);
  assert.deepStrictEqual(extractSkills("Go Developer", "").requiredSkills, ["go"]);
  assert.deepStrictEqual(extractSkills("Dev", "Mô tả\nGo developer cho hệ thống").requiredSkills, ["go"]);
  // Trong mục Yêu cầu thì nhận
  assert.ok(extractSkills("Dev", "Yêu cầu:\n- Có kinh nghiệm Spring, REST").requiredSkills.includes("spring boot"));
});

test("skills: chia theo mục Yêu cầu / Ưu tiên, bỏ mục Quyền lợi", () => {
  const description = "Yêu cầu:\n- Biết Python, SQL\nƯu tiên:\n- Có Docker, Python\nQuyền lợi:\n- Laptop Linux, Git miễn phí";
  const { requiredSkills, niceToHave } = extractSkills("Data Intern", description);
  assert.deepStrictEqual(requiredSkills.sort(), ["python", "sql"]);
  assert.deepStrictEqual(niceToHave, ["docker"]); // python đã bắt buộc nên không lặp lại
});

test("salary: dữ liệu có cấu trúc, quy về theo tháng", () => {
  assert.deepStrictEqual(parseSalary({ min: 24000, max: 36000, currency: "USD", period: "YEAR" }, null),
    { salaryMin: 2000, salaryMax: 3000, salaryCurrency: "USD" });
  assert.deepStrictEqual(parseSalary({ min: 10000000, max: 15000000, currency: "VND", period: "MONTH" }, null),
    { salaryMin: 10000000, salaryMax: 15000000, salaryCurrency: "VND" });
  // Theo giờ thì bỏ trống
  assert.strictEqual(parseSalary({ min: 10, max: 20, currency: "USD", period: "HOUR" }, null).salaryMin, null);
});

test("salary: chuỗi chữ - triệu, k, khoảng, trần, sàn, thỏa thuận", () => {
  assert.deepStrictEqual(parseSalaryText("15 – 25 triệu"), { salaryMin: 15000000, salaryMax: 25000000, salaryCurrency: "VND" });
  assert.deepStrictEqual(parseSalaryText("Up to $2000"), { salaryMin: null, salaryMax: 2000, salaryCurrency: "USD" });
  assert.deepStrictEqual(parseSalaryText("Từ 10 triệu"), { salaryMin: 10000000, salaryMax: null, salaryCurrency: "VND" });
  assert.deepStrictEqual(parseSalaryText("$24k - $36k / year"), { salaryMin: 2000, salaryMax: 3000, salaryCurrency: "USD" });
  assert.deepStrictEqual(parseSalaryText("15.000.000 - 20.000.000 VND"), { salaryMin: 15000000, salaryMax: 20000000, salaryCurrency: "VND" });
  const none = { salaryMin: null, salaryMax: null, salaryCurrency: null };
  assert.deepStrictEqual(parseSalaryText("Thỏa thuận"), none);
  assert.deepStrictEqual(parseSalaryText("Negotiable"), none);
  assert.deepStrictEqual(parseSalaryText("$50-$75 /hour"), none);
  assert.deepStrictEqual(parseSalaryText("$1000 per task"), none);
  assert.deepStrictEqual(parseSalaryText("70K-80K"), none); // không rõ tiền tệ: không đoán
  assert.deepStrictEqual(parseSalaryText(""), none);
});
