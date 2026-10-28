const assert = require("node:assert/strict");
const test = require("node:test");
const jwt = require("jsonwebtoken");
const { OAuth2Client } = require("google-auth-library");

process.env.JWT_SECRET = "test-secret-with-more-than-thirty-two-characters";
process.env.GOOGLE_CLIENT_ID = "test-google-client-id";
process.env.GITHUB_CLIENT_ID = "test-github-client-id";
process.env.GITHUB_CLIENT_SECRET = "test-github-client-secret";

let users = [];
let refreshTokens = [];
let idCounter = 0;

function project(record, select) {
  if (!record || !select) {
    return record;
  }
  return Object.fromEntries(
    Object.entries(select).map(([key, selection]) => {
      if (selection === true) {
        return [key, record[key]];
      }
      return [key, project(record[key], selection.select)];
    })
  );
}

function uniqueConstraintError(target) {
  return Object.assign(new Error("Unique constraint failed"), {
    code: "P2002",
    meta: { target: [target] },
  });
}

const prisma = {
  async $transaction(callback) {
    return callback(prisma);
  },
  user: {
    async create({ data, select }) {
      if (users.some((user) => user.email === data.email)) {
        throw uniqueConstraintError("email");
      }
      if (data.googleId && users.some((user) => user.googleId === data.googleId)) {
        throw uniqueConstraintError("googleId");
      }
      if (data.githubId && users.some((user) => user.githubId === data.githubId)) {
        throw uniqueConstraintError("githubId");
      }
      const user = {
        id: `user-${++idCounter}`,
        email: data.email,
        passwordHash: data.passwordHash ?? null,
        googleId: data.googleId ?? null,
        githubId: data.githubId ?? null,
        fullName: data.fullName,
        role: data.role,
        avatarUrl: data.avatarUrl ?? null,
        loginAttempts: data.loginAttempts ?? 0,
        loginLockedUntil: data.loginLockedUntil ?? null,
        createdAt: new Date(),
        studentProfile: data.studentProfile ? { userId: `user-${idCounter}` } : null,
        recruiterProfile: null,
      };
      users.push(user);
      return project(user, select);
    },
    async findUnique({ where, select }) {
      const user = users.find((record) =>
        Object.entries(where).every(([key, value]) => record[key] === value)
      );
      return project(user, select);
    },
    async update({ where, data, select }) {
      const user = users.find((record) => record.id === where.id);
      if (!user) throw new Error("User not found");
      for (const [key, val] of Object.entries(data)) {
        if (val && typeof val === "object" && "increment" in val) {
          user[key] = (user[key] || 0) + val.increment;
        } else {
          user[key] = val;
        }
      }
      return project(user, select);
    },
  },
  refreshToken: {
    async create({ data }) {
      refreshTokens.push(data);
      return data;
    },
    async findUnique({ where, include }) {
      const token = refreshTokens.find((record) => record.token === where.token);
      if (!token) {
        return null;
      }
      const res = { ...token };
      if (include?.user) {
        res.user = users.find((u) => u.id === token.userId);
      }
      return res;
    },
    async delete({ where }) {
      refreshTokens = refreshTokens.filter((record) => record.token !== where.token);
    },
    async findFirst({ where, include }) {
      const token = refreshTokens.find((record) => record.token === where.token);
      if (!token) return null;
      const res = { ...token };
      if (include?.user) {
        res.user = users.find((u) => u.id === token.userId);
      }
      return res;
    },
    async deleteMany({ where }) {
      refreshTokens = refreshTokens.filter((record) => record.token !== where.token);
    },
  },
};

const prismaPath = require.resolve("../src/lib/prisma");
require.cache[prismaPath] = {
  id: prismaPath,
  filename: prismaPath,
  loaded: true,
  exports: { prisma },
};

const authController = require("../src/controllers/auth.controller");
const authService = require("../src/services/auth.service");
const { authenticate } = require("../src/middleware/auth");
const { errorHandler } = require("../src/middleware/error");
const { generateAccessToken } = require("../src/utils/token");

const originalGoogleVerifier = OAuth2Client.prototype.verifyIdToken;
let googlePayload;
OAuth2Client.prototype.verifyIdToken = async ({ audience }) => {
  assert.equal(audience, process.env.GOOGLE_CLIENT_ID);
  return { getPayload: () => googlePayload };
};

const originalFetch = global.fetch;
let mockFetchHandler = null;
global.fetch = async (...args) => {
  if (mockFetchHandler) {
    return mockFetchHandler(...args);
  }
  if (originalFetch) return originalFetch(...args);
  throw new Error("fetch not mocked");
};

function createMockRes() {
  return {
    statusCode: 200,
    status(code) {
      this.statusCode = code;
      return this;
    },
    json(body) {
      this.body = body;
      return this;
    },
  };
}

async function dispatch(handler, req) {
  const res = createMockRes();
  const next = (err) => {
    if (err) {
      errorHandler(err, req, res, () => {});
    }
  };
  await handler(req, res, next);
  return res;
}

function registerBody(overrides = {}) {
  return {
    email: "student@example.com",
    password: "password123",
    fullName: "Test Student",
    role: "student",
    ...overrides,
  };
}

test.beforeEach(() => {
  users = [];
  refreshTokens = [];
  idCounter = 0;
  googlePayload = undefined;
  mockFetchHandler = null;
});

test.after(() => {
  OAuth2Client.prototype.verifyIdToken = originalGoogleVerifier;
  global.fetch = originalFetch;
});

test("register validates input and creates a student session with standardized response without internal fields", async () => {
  const invalidRes = await dispatch(authController.register, {
    body: registerBody({ role: "admin" }),
  });
  assert.equal(invalidRes.statusCode, 400);
  assert.equal(invalidRes.body.error.code, "VALIDATION_ERROR");
  assert.equal(users.length, 0);

  const registerRes = await dispatch(authController.register, { body: registerBody() });
  assert.equal(registerRes.statusCode, 201);
  assert.equal(registerRes.body.data.user.email, "student@example.com");
  assert.equal("passwordHash" in registerRes.body.data.user, false);
  assert.equal("tokenVersion" in registerRes.body.data.user, false);
  assert.equal("loginAttempts" in registerRes.body.data.user, false);
  assert.ok(registerRes.body.data.accessToken);
  assert.ok(registerRes.body.data.refreshToken);
  assert.equal(users[0].role, "student");
  assert.ok(users[0].studentProfile);
});

test("register supports recruiter role without studentProfile", async () => {
  const registerRes = await dispatch(authController.register, {
    body: registerBody({
      email: "recruiter@example.com",
      role: "recruiter",
      fullName: "Recruiter One",
    }),
  });
  assert.equal(registerRes.statusCode, 201);
  assert.equal(users[0].role, "recruiter");
  assert.equal(users[0].studentProfile, null);
});

test("login requires correct credentials and returns sanitized payload", async () => {
  await dispatch(authController.register, { body: registerBody() });

  // 1. Đăng nhập thành công với mật khẩu đúng
  const loginRes = await dispatch(authController.login, {
    body: { email: "student@example.com", password: "password123" },
  });
  assert.equal(loginRes.statusCode, 200);
  assert.equal(loginRes.body.data.user.email, "student@example.com");
  assert.equal("passwordHash" in loginRes.body.data.user, false);
  assert.ok(loginRes.body.data.accessToken);
  assert.ok(loginRes.body.data.refreshToken);

  // 2. Mật khẩu sai -> 401 INVALID_CREDENTIALS
  const badPasswordRes = await dispatch(authController.login, {
    body: { email: "student@example.com", password: "wrong-password" },
  });
  assert.equal(badPasswordRes.statusCode, 401);
  assert.equal(badPasswordRes.body.error.code, "INVALID_CREDENTIALS");

  // 3. Email không tồn tại -> 401 INVALID_CREDENTIALS
  const unknownEmailRes = await dispatch(authController.login, {
    body: { email: "unknown@example.com", password: "password123" },
  });
  assert.equal(unknownEmailRes.statusCode, 401);
  assert.equal(unknownEmailRes.body.error.code, "INVALID_CREDENTIALS");

  // 4. Chống User Enumeration: email sai format -> cũng 401 INVALID_CREDENTIALS
  const malformedEmailRes = await dispatch(authController.login, {
    body: { email: "not-an-email", password: "password123" },
  });
  assert.equal(malformedEmailRes.statusCode, 401);
  assert.equal(malformedEmailRes.body.error.code, "INVALID_CREDENTIALS");
});

test("rate limiting locks account after 5 consecutive failed logins using atomic increments", async () => {
  await dispatch(authController.register, { body: registerBody() });

  // 4 lần sai liên tiếp -> HTTP 401
  for (let i = 1; i <= 4; i++) {
    const res = await dispatch(authController.login, {
      body: { email: "student@example.com", password: "wrong" },
    });
    assert.equal(res.statusCode, 401);
    assert.equal(users[0].loginAttempts, i);
    assert.equal(users[0].loginLockedUntil, null);
  }

  // Lần sai thứ 5 -> Khóa tài khoản (HTTP 429)
  const lockedRes = await dispatch(authController.login, {
    body: { email: "student@example.com", password: "wrong" },
  });
  assert.equal(lockedRes.statusCode, 429);
  assert.equal(lockedRes.body.error.code, "ACCOUNT_LOCKED");
  assert.equal(users[0].loginAttempts, 5);
  assert.ok(users[0].loginLockedUntil);

  // Đăng nhập đúng trong lúc bị khóa -> vẫn trả 429
  const blockedRes = await dispatch(authController.login, {
    body: { email: "student@example.com", password: "password123" },
  });
  assert.equal(blockedRes.statusCode, 429);
  assert.equal(blockedRes.body.error.code, "ACCOUNT_LOCKED");
});

test("login resets failed attempts on successful authentication", async () => {
  await dispatch(authController.register, { body: registerBody() });

  // 2 lần nhập sai
  await dispatch(authController.login, {
    body: { email: "student@example.com", password: "wrong" },
  });
  await dispatch(authController.login, {
    body: { email: "student@example.com", password: "wrong" },
  });
  assert.equal(users[0].loginAttempts, 2);

  // Nhập đúng -> reset về 0
  const successRes = await dispatch(authController.login, {
    body: { email: "student@example.com", password: "password123" },
  });
  assert.equal(successRes.statusCode, 200);
  assert.equal(users[0].loginAttempts, 0);
  assert.equal(users[0].loginLockedUntil, null);
});

test("Google login verifies audience and creates a student account", async () => {
  googlePayload = {
    sub: "google-user-1",
    email: "google@example.com",
    email_verified: true,
    name: "Google User",
  };
  const googleRes = await dispatch(authController.googleLogin, {
    body: { idToken: "mock-google-id-token" },
  });
  assert.equal(googleRes.statusCode, 200);
  assert.equal(googleRes.body.data.isNewUser, true);
  assert.equal(googleRes.body.data.user.email, "google@example.com");
  assert.equal("tokenVersion" in googleRes.body.data.user, false);
  assert.ok(users[0].studentProfile);
});

test("Google login rejects an unverified email", async () => {
  googlePayload = {
    sub: "google-user-unverified",
    email: "unverified@example.com",
    email_verified: false,
  };
  const googleRes = await dispatch(authController.googleLogin, {
    body: { idToken: "mock-google-id-token" },
  });
  assert.equal(googleRes.statusCode, 401);
  assert.equal(googleRes.body.error.code, "GOOGLE_EMAIL_UNVERIFIED");
  assert.equal(users.length, 0);
});

// ── GitHub Login Tests ────────────────────────────────────────────────────────

test("GitHub login validates missing or empty code", async () => {
  const missingCodeRes = await dispatch(authController.githubLogin, {
    body: {},
  });
  assert.equal(missingCodeRes.statusCode, 400);
  assert.equal(missingCodeRes.body.error.code, "VALIDATION_ERROR");

  const emptyCodeRes = await dispatch(authController.githubLogin, {
    body: { code: "   " },
  });
  assert.equal(emptyCodeRes.statusCode, 400);
  assert.equal(emptyCodeRes.body.error.code, "VALIDATION_ERROR");
});

test("GitHub login rejects when token exchange returns error or invalid code", async () => {
  mockFetchHandler = async (url) => {
    if (url.includes("login/oauth/access_token")) {
      return {
        json: async () => ({
          error: "bad_verification_code",
          error_description: "The code passed is incorrect or expired.",
        }),
      };
    }
  };

  const res = await dispatch(authController.githubLogin, {
    body: { code: "invalid-code" },
  });
  assert.equal(res.statusCode, 401);
  assert.equal(res.body.error.code, "INVALID_GITHUB_CODE");
});

test("GitHub login rejects when account has no verified Gmail", async () => {
  mockFetchHandler = async (url) => {
    if (url.includes("login/oauth/access_token")) {
      return { json: async () => ({ access_token: "gh-mock-token" }) };
    }
    if (url.includes("api.github.com/user/emails")) {
      return {
        json: async () => [
          { email: "dev@outlook.com", verified: true, primary: true },
          { email: "unverified@gmail.com", verified: false, primary: false },
        ],
      };
    }
    if (url.includes("api.github.com/user")) {
      return { json: async () => ({ id: 123456, login: "githubuser" }) };
    }
  };

  const res = await dispatch(authController.githubLogin, {
    body: { code: "valid-code" },
  });
  assert.equal(res.statusCode, 400);
  assert.equal(res.body.error.code, "GITHUB_GMAIL_REQUIRED");
  assert.equal(users.length, 0);
});

test("GitHub login creates a new student account when verified Gmail is provided", async () => {
  mockFetchHandler = async (url) => {
    if (url.includes("login/oauth/access_token")) {
      return { json: async () => ({ access_token: "gh-mock-token" }) };
    }
    if (url.includes("api.github.com/user/emails")) {
      return {
        json: async () => [
          { email: "student.dev@gmail.com", verified: true, primary: true },
        ],
      };
    }
    if (url.includes("api.github.com/user")) {
      return {
        json: async () => ({
          id: 998877,
          login: "octodev",
          name: "Octo Developer",
          avatar_url: "https://avatars.githubusercontent.com/u/998877",
        }),
      };
    }
  };

  const res = await dispatch(authController.githubLogin, {
    body: { code: "valid-gh-code" },
  });
  assert.equal(res.statusCode, 200);
  assert.equal(res.body.data.isNewUser, true);
  assert.equal(res.body.data.user.email, "student.dev@gmail.com");
  assert.equal(res.body.data.user.fullName, "Octo Developer");
  assert.ok(res.body.data.accessToken);
  assert.ok(res.body.data.refreshToken);
  assert.equal(users[0].githubId, "998877");
  assert.ok(users[0].studentProfile);
});

test("GitHub login auto-links to an existing user with matching verified Gmail", async () => {
  // Đăng ký tài khoản trước bằng mật khẩu
  await dispatch(authController.register, {
    body: registerBody({ email: "existing.student@gmail.com" }),
  });
  assert.equal(users.length, 1);
  assert.equal(users[0].githubId, null);

  mockFetchHandler = async (url) => {
    if (url.includes("login/oauth/access_token")) {
      return { json: async () => ({ access_token: "gh-mock-token" }) };
    }
    if (url.includes("api.github.com/user/emails")) {
      return {
        json: async () => [
          { email: "other@school.edu", verified: true, primary: true },
          { email: "existing.student@gmail.com", verified: true, primary: false },
        ],
      };
    }
    if (url.includes("api.github.com/user")) {
      return {
        json: async () => ({
          id: 554433,
          login: "existinggh",
          name: "Existing Student",
        }),
      };
    }
  };

  const res = await dispatch(authController.githubLogin, {
    body: { code: "link-code" },
  });
  assert.equal(res.statusCode, 200);
  assert.equal(res.body.data.isNewUser, false);
  assert.equal(users.length, 1); // Không tạo thêm user mới
  assert.equal(users[0].githubId, "554433"); // Tự động liên kết
});

test("GitHub login rejects when email is linked to another GitHub account", async () => {
  // Tạo user đã liên kết với GitHub ID khác
  await prisma.user.create({
    data: {
      email: "linked@gmail.com",
      githubId: "first-github-id",
      fullName: "Already Linked",
      role: "student",
    },
  });

  mockFetchHandler = async (url) => {
    if (url.includes("login/oauth/access_token")) {
      return { json: async () => ({ access_token: "gh-mock-token" }) };
    }
    if (url.includes("api.github.com/user/emails")) {
      return {
        json: async () => [
          { email: "linked@gmail.com", verified: true, primary: true },
        ],
      };
    }
    if (url.includes("api.github.com/user")) {
      return {
        json: async () => ({
          id: 999999, // Different GitHub ID
          login: "secondgh",
        }),
      };
    }
  };

  const res = await dispatch(authController.githubLogin, {
    body: { code: "conflict-code" },
  });
  assert.equal(res.statusCode, 409);
  assert.equal(res.body.error.code, "EMAIL_LINKED_ANOTHER_GITHUB");
});

test("refresh performs token rotation in a transaction (deletes old token and issues new pair)", async () => {
  await dispatch(authController.register, { body: registerBody() });
  const oldToken = refreshTokens[0].token;

  // Gọi refresh thành công -> trả về cả accessToken mới và refreshToken mới
  const refreshRes = await dispatch(authController.refresh, {
    body: { refreshToken: oldToken },
  });
  assert.equal(refreshRes.statusCode, 200);
  assert.ok(refreshRes.body.data.accessToken);
  assert.ok(refreshRes.body.data.refreshToken);
  assert.notEqual(refreshRes.body.data.refreshToken, oldToken);

  // Token cũ đã bị xoá khỏi danh sách DB
  assert.equal(refreshTokens.some((t) => t.token === oldToken), false);
  // Token mới đã được lưu trong DB
  assert.equal(refreshTokens.some((t) => t.token === refreshRes.body.data.refreshToken), true);

  // Thử dùng lại token cũ -> bị từ chối 401
  const reuseRes = await dispatch(authController.refresh, {
    body: { refreshToken: oldToken },
  });
  assert.equal(reuseRes.statusCode, 401);
  assert.equal(reuseRes.body.error.code, "INVALID_REFRESH_TOKEN");
});

test("logout revokes refresh token so it cannot be used again", async () => {
  await dispatch(authController.register, { body: registerBody() });
  const loginRes = await dispatch(authController.login, {
    body: { email: "student@example.com", password: "password123" },
  });
  const activeAccessToken = loginRes.body.data.accessToken;
  const activeRefreshToken = loginRes.body.data.refreshToken;

  // Trước khi logout: access token hợp lệ
  const preAuthRes = createMockRes();
  let preAuthCalled = false;
  await authenticate(
    { headers: { authorization: `Bearer ${activeAccessToken}` } },
    preAuthRes,
    () => { preAuthCalled = true; }
  );
  assert.equal(preAuthCalled, true);

  // Logout
  const logoutRes = await dispatch(authController.logout, {
    body: { refreshToken: activeRefreshToken },
  });
  assert.equal(logoutRes.statusCode, 200);
  // Refresh token đã bị xóa khỏi DB
  assert.equal(refreshTokens.some((t) => t.token === activeRefreshToken), false);

  // Sau khi logout: access token cũ VẪN hợp lệ (stateless JWT) nhưng refresh token đã bị xóa
  // => Khi access token hết hạn (1h), không refresh được nữa
  const postAuthRes = createMockRes();
  let postAuthCalled = false;
  await authenticate(
    { headers: { authorization: `Bearer ${activeAccessToken}` } },
    postAuthRes,
    () => { postAuthCalled = true; }
  );
  assert.equal(postAuthCalled, true); // Stateless JWT vẫn valid (chưa hết 1h)

  // Nhưng refresh token đã không còn trong DB
  const refreshAfterLogout = await dispatch(authController.refresh, {
    body: { refreshToken: activeRefreshToken },
  });
  assert.equal(refreshAfterLogout.statusCode, 401);
  assert.equal(refreshAfterLogout.body.error.code, "INVALID_REFRESH_TOKEN");
});

test("getMe returns public user data and profile fields only", async () => {
  await dispatch(authController.register, { body: registerBody() });
  const meRes = await dispatch(authController.getMe, {
    user: { userId: users[0].id },
  });

  assert.equal(meRes.statusCode, 200);
  assert.ok(meRes.body.data.user.studentProfile);
  assert.equal("passwordHash" in meRes.body.data.user, false);
  assert.equal("loginAttempts" in meRes.body.data.user, false);
  assert.equal("tokenVersion" in meRes.body.data.user, false);
});
