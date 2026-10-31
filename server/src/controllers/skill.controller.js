const skillService = require("../services/skill.service");
const { sendSuccess } = require("./response");
const { asyncHandler } = require("../middleware/error");

const getMySkills = asyncHandler(async (req, res) => {
  return sendSuccess(res, await skillService.listMySkills(req.user.userId));
});

const getSuggestions = asyncHandler(async (req, res) => {
  return sendSuccess(res, await skillService.listSuggestions(req.user.userId));
});

const scanGithub = asyncHandler(async (req, res) => {
  return sendSuccess(res, await skillService.scanGithub(req.user.userId));
});

const acceptSuggestion = asyncHandler(async (req, res) => {
  return sendSuccess(res, await skillService.decideSuggestion(req.user.userId, req.params.id, true));
});

const rejectSuggestion = asyncHandler(async (req, res) => {
  return sendSuccess(res, await skillService.decideSuggestion(req.user.userId, req.params.id, false));
});

module.exports = { getMySkills, getSuggestions, scanGithub, acceptSuggestion, rejectSuggestion };
