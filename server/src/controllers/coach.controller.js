const coachService = require("../services/coach.service");
const { sendSuccess } = require("./response");
const { asyncHandler } = require("../middleware/error");

const getSettings = asyncHandler(async (req, res) => {
  return sendSuccess(res, await coachService.getSettings(req.user.userId));
});

const updateSettings = asyncHandler(async (req, res) => {
  return sendSuccess(res, await coachService.updateSettings(req.user.userId, req.body));
});

const ask = asyncHandler(async (req, res) => {
  return sendSuccess(res, await coachService.ask(req.user.userId, req.body));
});

module.exports = { getSettings, updateSettings, ask };
