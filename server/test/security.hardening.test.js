const assert = require("node:assert/strict");
const test = require("node:test");
const app = require("../src/index");

// Helper gửi mock HTTP request qua express app
function mockRequest(app, { method = "GET", url = "/", headers = {} }) {
  return new Promise((resolve) => {
    const req = {
      method,
      url,
      headers: { ...headers },
    };

    let statusCode = 200;
    const responseHeaders = {};
    let responseBody = null;

    const res = {
      status(code) {
        statusCode = code;
        return this;
      },
      json(body) {
        responseBody = body;
        resolve({ statusCode, headers: responseHeaders, body: responseBody });
        return this;
      },
      setHeader(k, v) {
        responseHeaders[k.toLowerCase()] = v;
      },
      getHeader(k) {
        return responseHeaders[k.toLowerCase()];
      },
    };

    app.handle(req, res);
  });
}

test("Bảo mật: Phản hồi API chứa header X-Content-Type-Options: nosniff", async () => {
  const res = await mockRequest(app, { method: "GET", url: "/" });
  assert.equal(res.headers["x-content-type-options"], "nosniff");
});

test("Bảo mật: CORS chấp nhận origin localhost:3000", async () => {
  const res = await mockRequest(app, {
    method: "GET",
    url: "/",
    headers: { origin: "http://localhost:3000" },
  });
  assert.equal(res.headers["access-control-allow-origin"], "http://localhost:3000");
});

test("Bảo mật: CORS từ chối origin độc hại lạ", async () => {
  const res = await mockRequest(app, {
    method: "GET",
    url: "/",
    headers: { origin: "https://evil-attacker.example.com" },
  });
  assert.equal(res.headers["access-control-allow-origin"], undefined);
});
