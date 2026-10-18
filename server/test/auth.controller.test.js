const assert = require("node:assert/strict");
const test = require("node:test");
const jwt = require("jsonwebtoken");
const { OAuth2Client } = require("google-auth-library");

process.env.JWT_SECRET = "test-secret-with-more-than-thirty-two-characters";
process.env.GOOGLE_CLIENT_ID = "test-google-client-id";

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
      const user = {
        id: `user-${++idCounter}`,
        email: data.email,
        passwordHash: data.passwordHash ?? null,
        googleId: data.googleId ?? null,
        fullName: data.fullName,
        role: data.role,
        avatarUrl: data.avatarUrl ?? null,
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
      Object.assign(user, data);
      return project(user, select);
    },
  },
  refreshToken: {
    async create({ data }) {
      refreshTokens.push(data);
    },
    async findUnique({ where, select }) {
      const token = refreshTokens.find((record) => record.token === where.token);
      if (!token) {
        return null;
      }
      const user = users.find((record) => record.id === token.userId);
      return {
        expiresAt: token.expiresAt,
        user: project(user, select.user.select),
      };
    },
    async delete({ where }) {
      refreshTokens = refreshTokens.filter((record) => record.token !== where.token);
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
const { authenticate } = require("../src/middleware/auth");
const { generateAccessToken } = require("../src/utils/token");
const originalGoogleVerifier = OAuth2Client.prototype.verifyIdToken;
let googlePayload;
OAuth2Client.prototype.verifyIdToken = async ({ audience }) => {
  assert.equal(audience, process.env.GOOGLE_CLIENT_ID);
  return { getPayload: () => googlePayload };
};

function response() {
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
});

test.after(() => {
  OAuth2Client.prototype.verifyIdToken = originalGoogleVerifier;
});

test("register validates input and creates a student session", async () => {
  const invalidResponse = response();
  await authController.register(
    { body: registerBody({ role: "admin" }) },
    invalidResponse
  );
  assert.equal(invalidResponse.statusCode, 400);
  assert.equal(users.length, 0);

  const registerResponse = response();
  await authController.register({ body: registerBody() }, registerResponse);
  assert.equal(registerResponse.statusCode, 201);
  assert.equal(registerResponse.body.user.email, "student@example.com");
  assert.equal("passwordHash" in registerResponse.body.user, false);
  assert.ok(users[0].studentProfile);
  assert.equal(refreshTokens.length, 1);
  assert.equal(
    jwt.verify(registerResponse.body.accessToken, process.env.JWT_SECRET).userId,
    users[0].id
  );
});

test("register conflicts on duplicate email and defers recruiter profile creation", async () => {
  await authController.register({ body: registerBody() }, response());
  const duplicateResponse = response();
  await authController.register({ body: registerBody() }, duplicateResponse);
  assert.equal(duplicateResponse.statusCode, 409);

  const recruiterResponse = response();
  await authController.register(
    { body: registerBody({ email: "recruiter@example.com", role: "recruiter" }) },
    recruiterResponse
  );
  assert.equal(recruiterResponse.statusCode, 201);
  assert.equal(users[1].recruiterProfile, null);
});

test("login accepts valid credentials and rejects incorrect credentials", async () => {
  await authController.register({ body: registerBody() }, response());

  const loginResponse = response();
  await authController.login(
    { body: { email: "STUDENT@example.com", password: "password123" } },
    loginResponse
  );
  assert.equal(loginResponse.statusCode, 200);
  assert.equal(loginResponse.body.user.email, "student@example.com");

  const invalidResponse = response();
  await authController.login(
    { body: { email: "student@example.com", password: "wrong" } },
    invalidResponse
  );
  assert.equal(invalidResponse.statusCode, 401);
});

test("Google login verifies audience and creates a student account", async () => {
  googlePayload = {
    sub: "google-user-1",
    email: "google@example.com",
    email_verified: true,
    name: "Google User",
  };
  const googleResponse = response();
  await authController.googleLogin(
    { body: { idToken: "mock-google-id-token" } },
    googleResponse
  );
  assert.equal(googleResponse.statusCode, 200);
  assert.equal(googleResponse.body.isNewUser, true);
  assert.equal(googleResponse.body.user.email, "google@example.com");
  assert.ok(users[0].studentProfile);
});

test("Google login rejects an unverified email", async () => {
  googlePayload = {
    sub: "google-user-unverified",
    email: "unverified@example.com",
    email_verified: false,
  };
  const googleResponse = response();
  await authController.googleLogin(
    { body: { idToken: "mock-google-id-token" } },
    googleResponse
  );
  assert.equal(googleResponse.statusCode, 401);
  assert.equal(users.length, 0);
});

test("refresh rejects expired tokens and logout revokes active tokens", async () => {
  await authController.register({ body: registerBody() }, response());
  const token = refreshTokens[0].token;

  const refreshResponse = response();
  await authController.refresh({ body: { refreshToken: token } }, refreshResponse);
  assert.equal(refreshResponse.statusCode, 200);
  assert.ok(refreshResponse.body.accessToken);

  refreshTokens[0].expiresAt = new Date(Date.now() - 1000);
  const expiredResponse = response();
  await authController.refresh({ body: { refreshToken: token } }, expiredResponse);
  assert.equal(expiredResponse.statusCode, 401);
  assert.equal(refreshTokens.length, 0);

  const logoutResponse = response();
  await authController.logout({ body: { refreshToken: token } }, logoutResponse);
  assert.equal(logoutResponse.statusCode, 200);
});

test("getMe returns public user data and profile fields only", async () => {
  await authController.register({ body: registerBody() }, response());
  const meResponse = response();
  await authController.getMe({ user: { userId: users[0].id } }, meResponse);

  assert.equal(meResponse.statusCode, 200);
  assert.ok(meResponse.body.user.studentProfile);
  assert.equal("passwordHash" in meResponse.body.user, false);
});

test("authenticate rejects missing tokens and attaches verified claims", () => {
  const missingResponse = response();
  authenticate({ headers: {} }, missingResponse, () => {
    assert.fail("next must not be called without a token");
  });
  assert.equal(missingResponse.statusCode, 401);

  const token = generateAccessToken({
    id: "user-auth",
    email: "auth@example.com",
    role: "student",
  });
  const req = { headers: { authorization: `Bearer ${token}` } };
  let nextCalled = false;
  authenticate(req, response(), () => {
    nextCalled = true;
  });
  assert.equal(nextCalled, true);
  assert.deepEqual(req.user, {
    userId: "user-auth",
    email: "auth@example.com",
    role: "student",
  });
});
