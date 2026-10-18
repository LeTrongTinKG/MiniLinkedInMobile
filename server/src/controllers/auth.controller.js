const bcrypt = require("bcryptjs");
const { OAuth2Client } = require("google-auth-library");
const { prisma } = require("../lib/prisma");
const {
  generateAccessToken,
  generateRefreshToken,
  getRefreshTokenExpiry,
} = require("../utils/token");

const googleClient = new OAuth2Client();
const publicUserSelect = {
  id: true,
  email: true,
  fullName: true,
  role: true,
  avatarUrl: true,
  createdAt: true,
};
const validRoles = new Set(["student", "recruiter"]);

function isValidEmail(email) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

function isPrismaUniqueConstraintError(error) {
  return error && typeof error === "object" && error.code === "P2002";
}

function isEmailUniqueConstraintError(error) {
  const target = error?.meta?.target;
  return (
    isPrismaUniqueConstraintError(error) &&
    (target === "email" || (Array.isArray(target) && target.includes("email")))
  );
}

async function createSession(user, client = prisma) {
  const accessToken = generateAccessToken(user);
  const refreshToken = generateRefreshToken();
  await client.refreshToken.create({
    data: {
      token: refreshToken,
      userId: user.id,
      expiresAt: getRefreshTokenExpiry(),
    },
  });
  return { accessToken, refreshToken };
}

async function register(req, res) {
  const { email, password, fullName, role } = req.body || {};
  if (
    typeof email !== "string" ||
    !isValidEmail(email.trim()) ||
    typeof password !== "string" ||
    password.length < 6 ||
    typeof fullName !== "string" ||
    fullName.trim().length === 0 ||
    !validRoles.has(role)
  ) {
    return res.status(400).json({
      error: "Valid email, password (at least 6 characters), fullName, and role are required",
    });
  }

  const normalizedEmail = email.trim().toLowerCase();
  const userData = {
    email: normalizedEmail,
    passwordHash: await bcrypt.hash(password, 10),
    fullName: fullName.trim(),
    role,
  };
  if (role === "student") {
    userData.studentProfile = { create: {} };
  }

  let session;
  try {
    session = await prisma.$transaction(async (transaction) => {
      const user = await transaction.user.create({
        data: userData,
        select: publicUserSelect,
      });
      const tokens = await createSession(user, transaction);
      return { user, ...tokens };
    });
  } catch (error) {
    if (isEmailUniqueConstraintError(error)) {
      return res.status(409).json({ error: "Email is already registered" });
    }
    throw error;
  }

  return res.status(201).json(session);
}

async function login(req, res) {
  const { email, password } = req.body || {};
  if (
    typeof email !== "string" ||
    !isValidEmail(email.trim()) ||
    typeof password !== "string" ||
    password.length === 0
  ) {
    return res.status(400).json({ error: "Valid email and password are required" });
  }

  const user = await prisma.user.findUnique({
    where: { email: email.trim().toLowerCase() },
    select: {
      ...publicUserSelect,
      passwordHash: true,
    },
  });
  if (!user?.passwordHash || !(await bcrypt.compare(password, user.passwordHash))) {
    return res.status(401).json({ error: "Invalid email or password" });
  }

  const { passwordHash, ...publicUser } = user;
  const tokens = await createSession(publicUser);
  return res.status(200).json({ user: publicUser, ...tokens });
}

async function googleLogin(req, res) {
  const { idToken } = req.body || {};
  if (typeof idToken !== "string" || idToken.length === 0) {
    return res.status(400).json({ error: "Google idToken is required" });
  }

  const clientId = process.env.GOOGLE_CLIENT_ID;
  if (!clientId) {
    throw new Error("GOOGLE_CLIENT_ID is not configured");
  }

  let payload;
  try {
    const ticket = await googleClient.verifyIdToken({
      idToken,
      audience: clientId,
    });
    payload = ticket.getPayload();
  } catch (error) {
    if (
      error?.name === "GaxiosError" &&
      (!error.response || error.response.status >= 500)
    ) {
      throw error;
    }
    return res.status(401).json({ error: "Invalid Google idToken" });
  }

  if (
    !payload ||
    typeof payload.sub !== "string" ||
    typeof payload.email !== "string" ||
    payload.email_verified !== true
  ) {
    return res.status(401).json({ error: "Google account must have a verified email" });
  }

  const email = payload.email.trim().toLowerCase();
  let user = await prisma.user.findUnique({
    where: { googleId: payload.sub },
    select: publicUserSelect,
  });
  let isNewUser = false;

  if (!user) {
    const emailUser = await prisma.user.findUnique({
      where: { email },
      select: { ...publicUserSelect, googleId: true },
    });

    if (emailUser?.googleId && emailUser.googleId !== payload.sub) {
      return res.status(409).json({ error: "Email is linked to another Google account" });
    }

    if (emailUser) {
      user = await prisma.user.update({
        where: { id: emailUser.id },
        data: { googleId: payload.sub },
        select: publicUserSelect,
      });
    } else {
      try {
        user = await prisma.user.create({
          data: {
            email,
            googleId: payload.sub,
            fullName: payload.name?.trim() || email.split("@")[0],
            avatarUrl: payload.picture || null,
            role: "student",
            studentProfile: { create: {} },
          },
          select: publicUserSelect,
        });
        isNewUser = true;
      } catch (error) {
        if (isPrismaUniqueConstraintError(error)) {
          return res.status(409).json({ error: "Google account is already linked" });
        }
        throw error;
      }
    }
  }

  const tokens = await createSession(user);
  return res.status(200).json({ user, ...tokens, isNewUser });
}

async function refresh(req, res) {
  const { refreshToken } = req.body || {};
  if (typeof refreshToken !== "string" || refreshToken.length === 0) {
    return res.status(400).json({ error: "refreshToken is required" });
  }

  const tokenRecord = await prisma.refreshToken.findUnique({
    where: { token: refreshToken },
    select: {
      expiresAt: true,
      user: { select: publicUserSelect },
    },
  });
  if (!tokenRecord) {
    return res.status(401).json({ error: "Invalid refresh token" });
  }
  if (tokenRecord.expiresAt <= new Date()) {
    await prisma.refreshToken.delete({ where: { token: refreshToken } });
    return res.status(401).json({ error: "Refresh token expired" });
  }

  return res.status(200).json({
    accessToken: generateAccessToken(tokenRecord.user),
  });
}

async function logout(req, res) {
  const { refreshToken } = req.body || {};
  if (typeof refreshToken !== "string" || refreshToken.length === 0) {
    return res.status(400).json({ error: "refreshToken is required" });
  }

  await prisma.refreshToken.deleteMany({ where: { token: refreshToken } });
  return res.status(200).json({ message: "Logged out" });
}

async function getMe(req, res) {
  const user = await prisma.user.findUnique({
    where: { id: req.user.userId },
    select: {
      ...publicUserSelect,
      studentProfile: true,
      recruiterProfile: true,
    },
  });
  if (!user) {
    return res.status(404).json({ error: "User not found" });
  }
  return res.status(200).json({ user });
}

module.exports = { register, login, googleLogin, refresh, logout, getMe };
