/**
 * Helper chuẩn hóa response cho toàn bộ hệ thống API
 * Thành công: { data: ..., meta?: ... }
 * Thất bại: { error: { code, message } }
 */

function sendSuccess(res, data, statusCode = 200, meta = null) {
  const payload = { data };
  if (meta) {
    payload.meta = meta;
  }
  return res.status(statusCode).json(payload);
}

function sendError(res, message, code = "ERROR", statusCode = 400) {
  return res.status(statusCode).json({
    error: {
      code,
      message,
    },
  });
}

module.exports = { sendSuccess, sendError };
