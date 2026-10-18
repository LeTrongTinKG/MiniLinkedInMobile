/**
 * Centralized Error Handling
 * - ApiError: Lớp lỗi tùy chỉnh chứa statusCode và mã lỗi code
 * - asyncHandler: Bọc controller để bắt promise rejection tự động chuyển đến errorHandler
 * - errorHandler: Middleware xử lý lỗi đặt cuối cùng trong index.js
 */

class ApiError extends Error {
  constructor(statusCode, code, message) {
    super(message);
    this.name = "ApiError";
    this.statusCode = statusCode;
    this.code = code;
  }
}

const asyncHandler = (fn) => (req, res, next) =>
  Promise.resolve(fn(req, res, next)).catch(next);

function errorHandler(err, _req, res, _next) {
  // 1. Lỗi nghiệp vụ có chủ đích
  if (err instanceof ApiError) {
    return res.status(err.statusCode).json({
      error: {
        code: err.code,
        message: err.message,
      },
    });
  }

  // 2. Lỗi trùng lặp dữ liệu từ Prisma (P2002)
  if (err && typeof err === "object" && err.code === "P2002") {
    const target = err?.meta?.target;
    let field = "Dữ liệu";
    if (target === "email" || (Array.isArray(target) && target.includes("email"))) {
      field = "Email";
    } else if (target === "googleId" || (Array.isArray(target) && target.includes("googleId"))) {
      field = "Tài khoản Google";
    }
    return res.status(409).json({
      error: {
        code: "DUPLICATE_RESOURCE",
        message: `${field} đã được sử dụng`,
      },
    });
  }

  // 3. Lỗi xác thực JWT
  if (err?.name === "TokenExpiredError") {
    return res.status(401).json({
      error: {
        code: "TOKEN_EXPIRED",
        message: "Access token đã hết hạn",
      },
    });
  }
  if (err?.name === "JsonWebTokenError" || err?.name === "NotBeforeError") {
    return res.status(401).json({
      error: {
        code: "INVALID_TOKEN",
        message: "Access token không hợp lệ",
      },
    });
  }

  // 4. Lỗi server không lường trước
  console.error("Unhandled Error:", err);
  return res.status(500).json({
    error: {
      code: "INTERNAL_SERVER_ERROR",
      message: "Đã có lỗi xảy ra phía máy chủ",
    },
  });
}

module.exports = { ApiError, asyncHandler, errorHandler };
