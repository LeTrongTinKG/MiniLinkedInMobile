// Mọi route social KHÔNG có token phải trả 401.
const assert = require("node:assert/strict");
const test = require("node:test");
const express = require("express");
const { errorHandler } = require("../../src/middleware/error");
const socialRoutes = require("../../src/routes/social");

const ID = "11111111-1111-4111-8111-111111111111";

// Danh sách toàn bộ route social: [method, path]
const ROUTES = [
  ["GET", "/posts"],
  ["POST", "/posts"],
  ["GET", `/posts/${ID}`],
  ["PATCH", `/posts/${ID}`],
  ["DELETE", `/posts/${ID}`],
  ["GET", `/posts/${ID}/revisions`],
  ["POST", `/posts/${ID}/shares`],
  ["GET", `/users/${ID}/posts`],
  ["PUT", `/posts/${ID}/reaction`],
  ["DELETE", `/posts/${ID}/reaction`],
  ["GET", `/posts/${ID}/reactions`],
  ["GET", `/posts/${ID}/comments`],
  ["POST", `/posts/${ID}/comments`],
  ["GET", `/comments/${ID}/replies`],
  ["PATCH", `/comments/${ID}`],
  ["DELETE", `/comments/${ID}`],
  ["PUT", `/comments/${ID}/reaction`],
  ["DELETE", `/comments/${ID}/reaction`],
  ["POST", "/media"],
];

async function withServer(run) {
  const app = express();
  app.use(express.json());
  app.use("/api/social", socialRoutes);
  app.use(errorHandler);
  const server = app.listen(0);
  try {
    await run(`http://127.0.0.1:${server.address().port}/api/social`);
  } finally {
    server.close();
  }
}

test("mọi route social không có token => 401 UNAUTHORIZED", async () => {
  await withServer(async (base) => {
    for (const [method, path] of ROUTES) {
      const res = await fetch(base + path, { method });
      assert.equal(res.status, 401, `${method} ${path} phải trả 401`);
      const body = await res.json();
      assert.equal(body.error.code, "UNAUTHORIZED");
    }
  });
});

test("token sai => 401 INVALID_TOKEN", async () => {
  process.env.JWT_SECRET = process.env.JWT_SECRET || "x".repeat(40);
  await withServer(async (base) => {
    const res = await fetch(`${base}/posts`, { headers: { Authorization: "Bearer abc.def.ghi" } });
    assert.equal(res.status, 401);
    assert.equal((await res.json()).error.code, "INVALID_TOKEN");
  });
});
