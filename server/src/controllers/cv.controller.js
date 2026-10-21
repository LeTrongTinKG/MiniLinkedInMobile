const cvService = require("../services/cv.service");
const { sendSuccess } = require("./response");
const { asyncHandler } = require("../middleware/error");

/**
 * Controller xử lý các HTTP request liên quan đến CV
 * Áp dụng Single Responsibility: Chỉ tương tác HTTP và gọi Service
 */

const uploadCv = asyncHandler(async (req, res) => {
  const cv = await cvService.uploadCv({
    userId: req.user.userId,
    file: req.file,
  });
  return sendSuccess(res, cv, 201);
});

const getMyCvs = asyncHandler(async (req, res) => {
  const cvs = await cvService.getMyCvs(req.user.userId);
  return sendSuccess(res, cvs, 200);
});

const setDefaultCv = asyncHandler(async (req, res) => {
  const cv = await cvService.setDefaultCv(req.user.userId, req.params.id);
  return sendSuccess(res, cv, 200);
});

const deleteCv = asyncHandler(async (req, res) => {
  const result = await cvService.deleteCv(req.user.userId, req.params.id);
  return sendSuccess(res, result, 200);
});

module.exports = {
  uploadCv,
  getMyCvs,
  setDefaultCv,
  deleteCv,
};
