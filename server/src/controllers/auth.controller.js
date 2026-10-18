const authService = require("../services/auth.service");
const { sendSuccess } = require("./response");
const { asyncHandler } = require("../middleware/error");

const register = asyncHandler(async (req, res) => {
  const result = await authService.register(req.body || {});
  return sendSuccess(res, result, 201);
});

const login = asyncHandler(async (req, res) => {
  const result = await authService.login(req.body || {});
  return sendSuccess(res, result, 200);
});

const googleLogin = asyncHandler(async (req, res) => {
  const result = await authService.googleLogin(req.body || {});
  return sendSuccess(res, result, 200);
});

const refresh = asyncHandler(async (req, res) => {
  const result = await authService.refresh(req.body || {});
  return sendSuccess(res, result, 200);
});

const logout = asyncHandler(async (req, res) => {
  const result = await authService.logout(req.body || {});
  return sendSuccess(res, result, 200);
});

const getMe = asyncHandler(async (req, res) => {
  const result = await authService.getMe(req.user.userId);
  return sendSuccess(res, result, 200);
});

module.exports = {
  register,
  login,
  googleLogin,
  refresh,
  logout,
  getMe,
};
