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

const addSkill = asyncHandler(async (req, res) => {
  const { skillName } = req.body;
  return sendSuccess(res, await skillService.addSelfClaimedSkill(req.user.userId, skillName), 201);
});

const deleteSkill = asyncHandler(async (req, res) => {
  const { name } = req.params;
  return sendSuccess(res, await skillService.deleteSkill(req.user.userId, name));
});

const scanRepo = asyncHandler(async (req, res) => {
  const { repoUrl } = req.body;
  return sendSuccess(res, await skillService.scanCustomRepo(req.user.userId, repoUrl));
});

const endorseSkill = asyncHandler(async (req, res) => {
  const { name } = req.params;
  const { targetUserId } = req.body;
  return sendSuccess(res, await skillService.endorseSkill(req.user.userId, targetUserId, name));
});

module.exports = {
  getMySkills,
  getSuggestions,
  scanGithub,
  acceptSuggestion,
  rejectSuggestion,
  addSkill,
  deleteSkill,
  scanRepo,
  endorseSkill,
};
