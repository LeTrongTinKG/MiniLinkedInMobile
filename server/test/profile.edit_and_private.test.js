const test = require("node:test");
const assert = require("node:assert/strict");
const profileService = require("../src/services/profile.service");

test("profile.service: getProfile returns default private profile", async () => {
  const fakeRepo = {
    findProfileByUserId: async (userId) => ({
      id: userId,
      email: "test@example.com",
      fullName: "Test User",
      role: "student",
      studentProfile: {
        headline: "Flutter Dev",
        about: "Hello world",
        location: "TP. Hồ Chí Minh",
        school: "HCMUS",
        major: "CS",
      },
    }),
  };

  const profile = await profileService.getProfile("fake-user-id", fakeRepo);
  assert.equal(profile.isPrivate, true);
  assert.equal(profile.location, "TP. Hồ Chí Minh");
  assert.equal(profile.fullName, "Test User");
});

test("profile.service: updateProfile validates name not empty", async () => {
  await assert.rejects(
    async () => {
      await profileService.updateProfile("fake-user-id", { fullName: "   " });
    },
    {
      name: "ApiError",
      statusCode: 400,
      code: "INVALID_NAME",
    }
  );
});

test("profile.service: updateProfile updates fields with isPrivate true by default", async () => {
  const fakeRepo = {
    upsertProfile: async (userId, data) => ({
      userId,
      ...data,
    }),
  };

  const updated = await profileService.updateProfile(
    "fake-user-id",
    {
      fullName: "Nguyễn Văn A",
      headline: "Mobile Dev",
      school: "ĐH Khoa Học Tự Nhiên",
    },
    fakeRepo
  );
  assert.equal(updated.fullName, "Nguyễn Văn A");
  assert.equal(updated.isPrivate, true);
});
