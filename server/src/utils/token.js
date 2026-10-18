const crypto = require("node:crypto");
const jwt = require("jsonwebtoken");

function getJwtSecret() {
  const secret = process.env.JWT_SECRET;
  if (typeof secret !== "string" || secret.length < 32) {
    throw new Error("JWT_SECRET must be configured with at least 32 characters");
  }
  return secret;
}

function generateAccessToken(user) {
  return jwt.sign(
    { userId: user.id, email: user.email, role: user.role },
    getJwtSecret(),
    { expiresIn: process.env.JWT_ACCESS_EXPIRES_IN || "1h" }
  );
}

function generateRefreshToken() {
  return crypto.randomUUID();
}

function getRefreshTokenExpiry(now = new Date()) {
  const expiresInDays = Number(process.env.JWT_REFRESH_EXPIRES_DAYS || 7);
  if (!Number.isSafeInteger(expiresInDays) || expiresInDays < 1) {
    throw new Error("JWT_REFRESH_EXPIRES_DAYS must be a positive whole number");
  }
  return new Date(now.getTime() + expiresInDays * 24 * 60 * 60 * 1000);
}

function verifyAccessToken(token) {
  return jwt.verify(token, getJwtSecret());
}

module.exports = {
  generateAccessToken,
  generateRefreshToken,
  getRefreshTokenExpiry,
  verifyAccessToken,
};
