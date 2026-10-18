const { verifyAccessToken } = require("../utils/token");

function authenticate(req, res, next) {
  const authHeader = req.headers.authorization;
  if (typeof authHeader !== "string") {
    return res.status(401).json({ error: "Access token is required" });
  }

  const [scheme, token, ...extraParts] = authHeader.split(" ");
  if (scheme?.toLowerCase() !== "bearer" || !token || extraParts.length > 0) {
    return res.status(401).json({ error: "Access token is required" });
  }

  let payload;
  try {
    payload = verifyAccessToken(token);
  } catch (error) {
    if (error.name === "TokenExpiredError") {
      return res.status(401).json({
        error: "Access token expired",
        code: "TOKEN_EXPIRED",
      });
    }
    if (error.name === "JsonWebTokenError" || error.name === "NotBeforeError") {
      return res.status(401).json({ error: "Invalid access token" });
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
    return res.status(401).json({ error: "Invalid access token" });
  }

  req.user = {
    userId: payload.userId,
    email: payload.email,
    role: payload.role,
  };
  return next();
}

module.exports = { authenticate };
