const bcrypt = require("bcryptjs");
const { OAuth2Client } = require("google-auth-library");
const { prisma } = require("../lib/prisma");
const userRepository = require("../repositories/user.repository");
const tokenRepository = require("../repositories/token.repository");
const {
  generateAccessToken,
  generateRefreshToken,
  getRefreshTokenExpiry,
} = require("../utils/token");
const { ApiError } = require("../middleware/error");

const googleClient = new OAuth2Client();
const validRoles = new Set(["student", "recruiter"]);

function isValidEmail(email) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

async function createSession(user, db = prisma) {
  const accessToken = generateAccessToken(user);
  const refreshToken = generateRefreshToken();
  await tokenRepository.createRefreshToken(
    {
      token: refreshToken,
      userId: user.id,
      expiresAt: getRefreshTokenExpiry(),
    },
    db
  );
  return { accessToken, refreshToken };
}

async function register({ email, password, fullName, role }) {
  if (
    typeof email !== "string" ||
    !isValidEmail(email.trim()) ||
    typeof password !== "string" ||
    password.length < 6 ||
    typeof fullName !== "string" ||
    fullName.trim().length === 0 ||
    !validRoles.has(role)
  ) {
    throw new ApiError(
      400,
      "VALIDATION_ERROR",
      "Email hợp lệ, mật khẩu (tối thiểu 6 ký tự), họ tên và vai trò (student/recruiter) là bắt buộc"
    );
  }

  const normalizedEmail = email.trim().toLowerCase();
  const existingUser = await userRepository.findByEmail(normalizedEmail);
  if (existingUser) {
    throw new ApiError(409, "EMAIL_ALREADY_EXISTS", "Email này đã được sử dụng");
  }

  const passwordHash = await bcrypt.hash(password, 10);
  const userData = {
    email: normalizedEmail,
    passwordHash,
    fullName: fullName.trim(),
    role,
    ...(role === "student" ? { studentProfile: { create: {} } } : {}),
  };

  const session = await prisma.$transaction(async (tx) => {
    const user = await userRepository.createUser(userData, tx);
    const tokens = await createSession(user, tx);
    return { user, ...tokens };
  });

  return session;
}

async function login({ email, password }) {
  if (
    typeof email !== "string" ||
    typeof password !== "string" ||
    email.trim().length === 0 ||
    password.length === 0
  ) {
    throw new ApiError(400, "VALIDATION_ERROR", "Email và mật khẩu là bắt buộc");
  }

  const normalizedEmail = email.trim().toLowerCase();
  // Chống User Enumeration: Nếu định dạng email không hợp lệ, trả chung lỗi 401
  if (!isValidEmail(normalizedEmail)) {
    throw new ApiError(401, "INVALID_CREDENTIALS", "Email hoặc mật khẩu không chính xác");
  }

  const user = await userRepository.findByEmail(normalizedEmail, true);
  if (!user) {
    throw new ApiError(401, "INVALID_CREDENTIALS", "Email hoặc mật khẩu không chính xác");
  }

  // 1. Kiểm tra Rate Limiting (Khóa 15 phút nếu sai 5 lần)
  if (user.loginLockedUntil && new Date(user.loginLockedUntil) > new Date()) {
    const remainingMinutes = Math.max(
      1,
      Math.ceil((new Date(user.loginLockedUntil).getTime() - Date.now()) / (60 * 1000))
    );
    throw new ApiError(
      429,
      "ACCOUNT_LOCKED",
      `Tài khoản bị tạm khóa do nhập sai mật khẩu quá 5 lần. Vui lòng thử lại sau ${remainingMinutes} phút`
    );
  }

  // 2. So khớp mật khẩu
  const isMatch = user.passwordHash
    ? await bcrypt.compare(password, user.passwordHash)
    : false;

  if (!isMatch) {
    const updated = await userRepository.incrementLoginAttempts(user.id);
    if (updated.loginLockedUntil) {
      throw new ApiError(
        429,
        "ACCOUNT_LOCKED",
        "Bạn đã nhập sai 5 lần. Tài khoản bị tạm khóa trong 15 phút"
      );
    }
    throw new ApiError(401, "INVALID_CREDENTIALS", "Email hoặc mật khẩu không chính xác");
  }

  // 3. Đăng nhập đúng -> Reset số lần sai nếu cần
  if (user.loginAttempts > 0 || user.loginLockedUntil) {
    await userRepository.resetLoginAttempts(user.id);
  }

  const clientUser = {
    id: user.id,
    email: user.email,
    fullName: user.fullName,
    role: user.role,
    avatarUrl: user.avatarUrl,
    createdAt: user.createdAt,
  };
  const tokens = await createSession(user);
  return { user: clientUser, ...tokens };
}

async function googleLogin({ idToken }) {
  if (typeof idToken !== "string" || idToken.length === 0) {
    throw new ApiError(400, "VALIDATION_ERROR", "Google idToken là bắt buộc");
  }

  const clientId = process.env.GOOGLE_CLIENT_ID;
  if (!clientId) {
    throw new ApiError(500, "CONFIG_ERROR", "GOOGLE_CLIENT_ID chưa được cấu hình");
  }

  let payload;
  try {
    const ticket = await googleClient.verifyIdToken({
      idToken,
      audience: clientId,
    });
    payload = ticket.getPayload();
  } catch (error) {
    if (error?.name === "GaxiosError" && (!error.response || error.response.status >= 500)) {
      throw error;
    }
    throw new ApiError(401, "INVALID_GOOGLE_TOKEN", "Google idToken không hợp lệ");
  }

  if (
    !payload ||
    typeof payload.sub !== "string" ||
    typeof payload.email !== "string" ||
    payload.email_verified !== true
  ) {
    throw new ApiError(
      401,
      "GOOGLE_EMAIL_UNVERIFIED",
      "Tài khoản Google cần có email đã được xác thực"
    );
  }

  const email = payload.email.trim().toLowerCase();
  let user = await userRepository.findByGoogleId(payload.sub);
  let isNewUser = false;

  if (!user) {
    const emailUser = await userRepository.findByEmail(email, true);

    if (emailUser?.googleId && emailUser.googleId !== payload.sub) {
      throw new ApiError(
        409,
        "EMAIL_LINKED_ANOTHER_GOOGLE",
        "Email này đã được liên kết với một tài khoản Google khác"
      );
    }

    if (emailUser) {
      user = await userRepository.updateUser(emailUser.id, { googleId: payload.sub });
    } else {
      user = await userRepository.createUser({
        email,
        googleId: payload.sub,
        fullName: payload.name?.trim() || email.split("@")[0],
        avatarUrl: payload.picture || null,
        role: "student",
        studentProfile: { create: {} },
      });
      isNewUser = true;
    }
  }

  const tokens = await createSession(user);
  return { user, ...tokens, isNewUser };
}

async function refresh({ refreshToken }) {
  if (typeof refreshToken !== "string" || refreshToken.length === 0) {
    throw new ApiError(400, "VALIDATION_ERROR", "refreshToken là bắt buộc");
  }

  const tokenRecord = await tokenRepository.findRefreshToken(refreshToken);
  if (!tokenRecord) {
    throw new ApiError(401, "INVALID_REFRESH_TOKEN", "Refresh token không hợp lệ");
  }

  if (tokenRecord.expiresAt <= new Date()) {
    await tokenRepository.deleteRefreshToken(refreshToken);
    throw new ApiError(
      401,
      "REFRESH_TOKEN_EXPIRED",
      "Refresh token đã hết hạn, vui lòng đăng nhập lại"
    );
  }

  // Token Rotation: Xóa token cũ, sinh cặp token mới và lưu DB trong cùng 1 Transaction an toàn
  const newTokens = await prisma.$transaction(async (tx) => {
    await tokenRepository.deleteRefreshToken(refreshToken, tx);
    const newAccessToken = generateAccessToken(tokenRecord.user);
    const newRefreshToken = generateRefreshToken();
    await tokenRepository.createRefreshToken(
      {
        token: newRefreshToken,
        userId: tokenRecord.user.id,
        expiresAt: getRefreshTokenExpiry(),
      },
      tx
    );
    return {
      accessToken: newAccessToken,
      refreshToken: newRefreshToken,
    };
  });

  return newTokens;
}

async function logout({ refreshToken }) {
  if (typeof refreshToken !== "string" || refreshToken.length === 0) {
    throw new ApiError(400, "VALIDATION_ERROR", "refreshToken là bắt buộc");
  }

  const tokenRecord = await tokenRepository.findRefreshToken(refreshToken);
  if (tokenRecord) {
    await prisma.$transaction(async (tx) => {
      await tokenRepository.deleteRefreshToken(refreshToken, tx);
      await userRepository.incrementTokenVersion(tokenRecord.userId, tx);
    });
  }
  return { message: "Đăng xuất thành công" };
}

async function getMe(userId) {
  const user = await userRepository.findById(userId);
  if (!user) {
    throw new ApiError(404, "USER_NOT_FOUND", "Không tìm thấy thông tin người dùng");
  }
  return { user };
}

module.exports = {
  register,
  login,
  googleLogin,
  refresh,
  logout,
  getMe,
};
