/**
 * Helper chuẩn hóa response thành công cho toàn bộ hệ thống API
 * Thành công: { data: ..., meta?: ... }
 */

function sendSuccess(res, data, statusCode = 200, meta = null) {
  const payload = { data };
  if (meta) {
    payload.meta = meta;
  }
  return res.status(statusCode).json(payload);
}

module.exports = { sendSuccess };
