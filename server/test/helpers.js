const { errorHandler } = require("../src/middleware/error");

function createMockRes() {
  return {
    statusCode: 200,
    headers: {},
    setHeader(name, value) {
      this.headers[name.toLowerCase()] = value;
      return this;
    },
    status(code) {
      this.statusCode = code;
      return this;
    },
    json(body) {
      this.body = body;
      return this;
    },
    send(body) {
      this.body = body;
      return this;
    },
  };
}

async function dispatch(handler, req, middlewares = []) {
  const res = createMockRes();
  const next = (err) => {
    if (err) {
      errorHandler(err, req, res, () => {});
    }
  };

  for (const mw of middlewares) {
    let nextCalled = false;
    let mwError = null;
    await mw(req, res, (err) => {
      nextCalled = true;
      mwError = err;
    });

    if (mwError) {
      errorHandler(mwError, req, res, () => {});
      return res;
    }

    if (!nextCalled) {
      return res;
    }
  }

  await handler(req, res, next);
  return res;
}

module.exports = {
  createMockRes,
  dispatch,
};
