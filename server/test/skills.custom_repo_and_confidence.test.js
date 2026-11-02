const test = require("node:test");
const assert = require("node:assert/strict");
const skillService = require("../src/services/skill.service");

test("addSelfClaimedSkill thêm skill với confidence self_claimed", async () => {
  const fakeRepo = {
    addSelfClaimed: async (userId, skillName) => ({
      id: "skill-1",
      userId,
      skillName,
      source: "self",
      confidence: "self_claimed",
    }),
  };

  const result = await skillService.addSelfClaimedSkill("user-1", "Docker", fakeRepo);
  assert.equal(result.skillName, "Docker");
  assert.equal(result.confidence, "self_claimed");
});

test("addSelfClaimedSkill từ chối tên kỹ năng rỗng", async () => {
  await assert.rejects(
    () => skillService.addSelfClaimedSkill("user-1", "   "),
    { message: "Tên kỹ năng không được để trống" },
  );
});

test("deleteSkill gọi repository xóa kỹ năng", async () => {
  let deleted = null;
  const fakeRepo = {
    deleteSkill: async (userId, skillName) => {
      deleted = { userId, skillName };
      return { count: 1 };
    },
  };

  await skillService.deleteSkill("user-1", "Docker", fakeRepo);
  assert.deepEqual(deleted, { userId: "user-1", skillName: "Docker" });
});

test("endorseSkill từ chối khi tự xác nhận chính mình", async () => {
  await assert.rejects(
    () => skillService.endorseSkill("user-1", "user-1", "Flutter"),
    { message: "Không thể tự xác nhận kỹ năng của chính mình" },
  );
});

test("endorseSkill từ chối khi người xác nhận không có bằng chứng kỹ năng đó", async () => {
  const fakeRepo = {
    listSkills: async () => [{ skillName: "Flutter", confidence: "self_claimed" }],
  };

  await assert.rejects(
    () => skillService.endorseSkill("user-1", "user-2", "Flutter", fakeRepo),
    { message: "Bạn cần có kỹ năng này ở mức 'Có bằng chứng' để xác nhận cho người khác" },
  );
});

test("scanCustomRepo từ chối URL sai định dạng", async () => {
  await assert.rejects(
    () => skillService.scanCustomRepo("user-1", "not-a-repo"),
    { message: "Định dạng repo không đúng (ví dụ: owner/repo hoặc https://github.com/owner/repo)" },
  );
});

test("scanCustomRepo bóc tách đúng owner/repo từ URL hợp lệ và trích xuất đề xuất", async () => {
  const fakeReader = {
    readSingleRepo: async (fullName) => ({
      repo: fullName,
      url: `https://github.com/${fullName}`,
      languageBytes: { Dart: 1000 },
      topics: ["flutter"],
      rootFiles: ["pubspec.yaml"],
      dependencies: { pub: ["provider"] },
      text: "App Flutter",
    }),
  };

  const upserted = [];
  const fakeRepo = {
    listSkills: async () => [],
    listSuggestions: async () => [
      { id: "s1", skillName: "Flutter", evidence: [], confidence: "evidenced" },
    ],
    upsertPending: async (userId, name, evidence) => {
      upserted.push({ userId, name, evidence });
    },
  };

  const result = await skillService.scanCustomRepo(
    "user-1",
    "https://github.com/flutter/samples",
    fakeRepo,
    fakeReader,
  );

  assert.equal(result.repo, "flutter/samples");
  assert.ok(upserted.length > 0);
});

