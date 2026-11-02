const rateLimit = require("express-rate-limit");

/**
 * Middleware Rate Limiting bảo vệ các endpoint xác thực (Auth)
 * Ngăn chặn brute-force và credential stuffing theo địa chỉ IP
 */
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 phút
  max: 30, // Tối đa 30 yêu cầu / 15 phút trên mỗi IP
  standardHeaders: true, // Trả về thông tin RateLimit-* trong header
  legacyHeaders: false,
  skip: () => process.env.NODE_ENV === "test", // Bỏ qua khi chạy test tự động
  handler: (_req, res) => {
    res.status(429).json({
      error: {
        code: "TOO_MANY_REQUESTS",
        message: "Quá nhiều yêu cầu từ địa chỉ IP của bạn. Vui lòng thử lại sau 15 phút.",
      },
    });
  },
});

module.exports = { authLimiter };
