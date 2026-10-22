const { verifyAccessToken } = require("../utils/token");

async function authenticate(req, res, next) {
  const authHeader = req.headers.authorization;
  if (typeof authHeader !== "string") {
    return res.status(401).json({
      error: {
        code: "UNAUTHORIZED",
        message: "Access token là bắt buộc",
      },
    });
  }

  const [scheme, token, ...extraParts] = authHeader.split(" ");
  if (scheme?.toLowerCase() !== "bearer" || !token || extraParts.length > 0) {
    return res.status(401).json({
      error: {
        code: "UNAUTHORIZED",
        message: "Access token là bắt buộc",
      },
    });
  }

  let payload;
  try {
    payload = verifyAccessToken(token);
  } catch (error) {
    if (error.name === "TokenExpiredError") {
      return res.status(401).json({
        error: {
          code: "TOKEN_EXPIRED",
          message: "Access token đã hết hạn",
        },
      });
    }
    if (error.name === "JsonWebTokenError" || error.name === "NotBeforeError") {
      return res.status(401).json({
        error: {
          code: "INVALID_TOKEN",
          message: "Access token không hợp lệ",
        },
      });
    }
    return next(error);
  }

  if (
    !payload ||
    typeof payload !== "object" ||
    typeof payload.userId !== "string" ||
    typeof payload.email !== "string" ||
    !["student", "recruiter"].includes(payload.role)
  ) {
    return res.status(401).json({
      error: {
        code: "INVALID_TOKEN",
        message: "Access token không hợp lệ",
      },
    });
  }

  req.user = {
    userId: payload.userId,
    email: payload.email,
    role: payload.role,
  };
  return next();
}

function authorize(...allowedRoles) {
  return (req, res, next) => {
    if (!req.user || !allowedRoles.includes(req.user.role)) {
      return res.status(403).json({
        error: {
          code: "FORBIDDEN",
          message: "Bạn không có quyền thực hiện hành động này",
        },
      });
    }
    return next();
  };
}

/**
 * Middleware xác thực tùy chọn (Optional Authentication)
 * Nếu client gửi header Authorization hợp lệ -> gán req.user
 * Nếu không gửi hoặc token không hợp lệ -> req.user = null, vẫn cho phép request tiếp tục
 */
async function optionalAuthenticate(req, res, next) {
  const authHeader = req.headers.authorization;
  if (typeof authHeader !== "string") {
    req.user = null;
    return next();
  }

  const [scheme, token, ...extraParts] = authHeader.split(" ");
  if (scheme?.toLowerCase() !== "bearer" || !token || extraParts.length > 0) {
    req.user = null;
    return next();
  }

  try {
    const payload = verifyAccessToken(token);
    if (
      payload &&
      typeof payload === "object" &&
      typeof payload.userId === "string" &&
      typeof payload.email === "string" &&
      ["student", "recruiter"].includes(payload.role)
    ) {
      req.user = {
        userId: payload.userId,
        email: payload.email,
        role: payload.role,
      };
      return next();
    }
  } catch (_err) {
    // Token không hợp lệ hoặc hết hạn -> coi như khách vãng lai
  }

  req.user = null;
  return next();
}

module.exports = { authenticate, authorize, optionalAuthenticate };
