const profileService = require("../services/profile.service");
const { sendSuccess } = require("./response");
const { asyncHandler } = require("../middleware/error");

const getProfile = asyncHandler(async (req, res) => {
  const profile = await profileService.getProfile(req.user.userId);
  return sendSuccess(res, profile, 200);
});

const updateProfile = asyncHandler(async (req, res) => {
  const updated = await profileService.updateProfile(req.user.userId, req.body || {});
  return sendSuccess(res, updated, 200);
});

module.exports = {
  getProfile,
  updateProfile,
};
