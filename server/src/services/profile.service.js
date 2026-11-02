const repo = require("../repositories/profile.repository");
const { ApiError } = require("../middleware/error");

async function getProfile(userId, repository = repo) {
  const user = await repository.findProfileByUserId(userId);
  if (!user) {
    throw new ApiError(404, "USER_NOT_FOUND", "Không tìm thấy hồ sơ người dùng");
  }
  return {
    id: user.id,
    email: user.email,
    fullName: user.fullName,
    role: user.role,
    avatarUrl: user.avatarUrl,
    headline: user.studentProfile?.headline ?? "",
    about: user.studentProfile?.about ?? "",
    location: user.studentProfile?.location ?? "TP. Hồ Chí Minh",
    school: user.studentProfile?.school ?? "",
    major: user.studentProfile?.major ?? "",
    isPrivate: true, // Private by default (F-002, Ticket 02)
  };
}

async function updateProfile(userId, body, repository = repo) {
  const { fullName, headline, about, location, school, major, isPrivate } = body;

  if (fullName !== undefined && (!fullName || !fullName.trim())) {
    throw new ApiError(400, "INVALID_NAME", "Họ và tên không được để trống");
  }

  const profile = await repository.upsertProfile(userId, {
    fullName,
    headline,
    about,
    location,
    school,
    major,
    isPrivate: isPrivate ?? true,
  });

  return {
    fullName: fullName?.trim(),
    ...profile,
    isPrivate: isPrivate ?? true,
  };
}

module.exports = {
  getProfile,
  updateProfile,
};
