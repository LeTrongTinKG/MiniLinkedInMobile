const { verifyAccessToken } = require("../utils/token");
const userRepository = require("../repositories/user.repository");

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

  // Kiểm tra tokenVersion đối chiếu với DB (thu hồi token nếu đã logout)
  try {
    const userRecord = await userRepository.findTokenVersion(payload.userId);
    const expectedVersion = userRecord?.tokenVersion ?? 0;
    const tokenVersion = typeof payload.tokenVersion === "number" ? payload.tokenVersion : 0;

    if (!userRecord || expectedVersion !== tokenVersion) {
      return res.status(401).json({
        error: {
          code: "TOKEN_REVOKED",
          message: "Phiên đăng nhập đã bị thu hồi hoặc đã đăng xuất",
        },
      });
    }
  } catch (dbError) {
    return next(dbError);
  }

  req.user = {
    userId: payload.userId,
    email: payload.email,
    role: payload.role,
  };
  return next();
}

module.exports = { authenticate };
