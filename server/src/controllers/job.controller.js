const jobService = require("../services/job.service");
const { sendSuccess } = require("./response");
const { asyncHandler } = require("../middleware/error");

/**
 * Controller xử lý các request liên quan đến Job
 * Áp dụng SRP (Single Responsibility Principle) - Chỉ xử lý I/O HTTP và gọi Service
 */
const getPublicJobs = asyncHandler(async (req, res) => {
  const result = await jobService.getPublicJobs(req.query);
  return sendSuccess(res, result.items, 200, result.meta);
});

const getJobDetail = asyncHandler(async (req, res) => {
  const job = await jobService.getJobDetail(req.params.id);
  return sendSuccess(res, job, 200);
});

const getRecruiterJobs = asyncHandler(async (req, res) => {
  const result = await jobService.getRecruiterJobs(req.user.userId, req.query);
  return sendSuccess(res, result.items, 200, result.meta);
});

module.exports = {
  getPublicJobs,
  getJobDetail,
  getRecruiterJobs,
};
