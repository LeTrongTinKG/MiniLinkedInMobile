const assert = require("node:assert/strict");
const test = require("node:test");
const app = require("../src/index");

// Helper gửi mock HTTP request qua express app
function mockRequest(app, { method = "GET", url = "/" }) {
  return new Promise((resolve) => {
    const req = {
      method,
      url,
      headers: {},
    };

    let statusCode = 200;
    let headers = {};
    let responseBody = null;

    const res = {
      status(code) {
        statusCode = code;
        return this;
      },
      json(body) {
        responseBody = body;
        resolve({ statusCode, headers, body: responseBody });
        return this;
      },
      setHeader(k, v) {
        headers[k] = v;
      },
      getHeader(k) {
        return headers[k];
      },
    };

    app.handle(req, res);
  });
}

test("GET / trả về thông tin API và danh sách endpoints", async () => {
  const res = await mockRequest(app, { method: "GET", url: "/" });

  assert.equal(res.statusCode, 200);
  assert.equal(res.body.message, "Welcome to Mini LinkedIn REST API");
  assert.equal(res.body.version, "1.0.0");
  assert.ok(res.body.endpoints);
  assert.equal(res.body.endpoints.health, "/health");
  assert.equal(res.body.endpoints.apiV1, "/api/v1");
});

test("GET /api/v1 trả về thông tin API version 1", async () => {
  const res = await mockRequest(app, { method: "GET", url: "/api/v1" });

  assert.equal(res.statusCode, 200);
  assert.equal(res.body.version, "1.0.0");
});

test("404 handler bắt các route lạ và trả về JSON chuẩn", async () => {
  const res = await mockRequest(app, { method: "GET", url: "/random-unknown-route" });

  assert.equal(res.statusCode, 404);
  assert.deepEqual(res.body, {
    error: {
      code: "NOT_FOUND",
      message: "Route không tồn tại",
    },
  });
});
