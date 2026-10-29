const { asyncHandler } = require("../../middleware/error");
const { sendSuccess } = require("../response");
const mediaService = require("../../services/social/media.service");

const uploadMedia = asyncHandler(async (req, res) => {
  const media = await mediaService.uploadImage({ userId: req.user.userId, file: req.file });
  return sendSuccess(res, media, 201);
});

module.exports = { uploadMedia };
