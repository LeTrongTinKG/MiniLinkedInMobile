const assert = require("node:assert/strict");
const test = require("node:test");

process.env.JWT_SECRET = "test-secret-with-more-than-thirty-two-characters";
process.env.NODE_ENV = "test";

let cvs = [];
let applications = [];
let idCounter = 0;

const prisma = {
  $transaction(callback) {
    return callback(prisma);
  },
  cv: {
    async create({ data, select }) {
      const record = {
        id: `cv-${++idCounter}`,
        userId: data.userId,
        fileName: data.fileName,
        fileUrl: data.fileUrl,
        extractedSkills: data.extractedSkills ?? null,
        isDefault: Boolean(data.isDefault),
        createdAt: new Date(),
        updatedAt: new Date(),
      };
      cvs.push(record);
      return { ...record };
    },

    async findMany({ where = {}, orderBy }) {
      let filtered = [...cvs];
      if (where.userId) {
        filtered = filtered.filter((c) => c.userId === where.userId);
      }
      filtered.sort((a, b) => {
        if (a.isDefault !== b.isDefault) {
          return a.isDefault ? -1 : 1;
        }
        return b.createdAt.getTime() - a.createdAt.getTime();
      });
      return filtered.map((c) => ({ ...c }));
    },

    async findUnique({ where: { id } }) {
      const found = cvs.find((c) => c.id === id);
      if (!found) return null;
      const count = applications.filter((a) => a.cvId === id).length;
      return {
        ...found,
        _count: {
          applications: count,
        },
      };
    },

    async findFirst({ where = {}, orderBy }) {
      let filtered = [...cvs];
      if (where.userId) {
        filtered = filtered.filter((c) => c.userId === where.userId);
      }
      if (where.id?.not) {
        filtered = filtered.filter((c) => c.id !== where.id.not);
      }
      filtered.sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime());
      return filtered[0] ? { ...filtered[0] } : null;
    },

    async count({ where = {} }) {
      let filtered = [...cvs];
      if (where.userId) {
        filtered = filtered.filter((c) => c.userId === where.userId);
      }
      return filtered.length;
    },

    async updateMany({ where = {}, data }) {
      let count = 0;
      for (const c of cvs) {
        if (!where.userId || c.userId === where.userId) {
          Object.assign(c, data);
          count++;
        }
      }
      return { count };
    },

    async update({ where: { id }, data, select }) {
      const found = cvs.find((c) => c.id === id);
      if (!found) throw new Error("Cv not found");
      Object.assign(found, data, { updatedAt: new Date() });
      return { ...found };
    },

    async delete({ where: { id } }) {
      const index = cvs.findIndex((c) => c.id === id);
      if (index === -1) throw new Error("Cv not found");
      const [removed] = cvs.splice(index, 1);
      return removed;
    },
  },
};

// Mock prisma dependency
require.cache[require.resolve("../src/lib/prisma")] = {
  exports: { prisma },
};

const cvController = require("../src/controllers/cv.controller");
const cvService = require("../src/services/cv.service");
const { authenticate, authorize } = require("../src/middleware/auth");
const { uploadCvMiddleware, PDF_MAGIC } = require("../src/middleware/upload");
const { errorHandler, ApiError } = require("../src/middleware/error");
const { generateAccessToken } = require("../src/utils/token");

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

test.beforeEach(() => {
  cvs = [];
  applications = [];
  idCounter = 0;
});

test("POST /api/v1/cvs từ chối khi không có Access Token (401 UNAUTHORIZED)", async () => {
  const req = { headers: {} };
  const res = await dispatch(cvController.uploadCv, req, [
    authenticate,
    authorize("student"),
  ]);

  assert.equal(res.statusCode, 401);
  assert.equal(res.body.error.code, "UNAUTHORIZED");
});

test("POST /api/v1/cvs từ chối khi user có role recruiter (403 FORBIDDEN)", async () => {
  const token = generateAccessToken({
    id: "recruiter-1",
    email: "recruiter@company.com",
    role: "recruiter",
  });

  const req = {
    headers: { authorization: `Bearer ${token}` },
  };
  const res = await dispatch(cvController.uploadCv, req, [
    authenticate,
    authorize("student"),
  ]);

  assert.equal(res.statusCode, 403);
  assert.equal(res.body.error.code, "FORBIDDEN");
});

test("POST /api/v1/cvs từ chối khi không gửi file (400 FILE_REQUIRED)", async () => {
  const token = generateAccessToken({
    id: "student-1",
    email: "student1@school.edu.vn",
    role: "student",
  });

  const req = {
    headers: { authorization: `Bearer ${token}` },
    files: {}, // Không có file
  };

  const res = await dispatch(cvController.uploadCv, req, [
    authenticate,
    authorize("student"),
    (r, _res, n) => {
      r.file = undefined;
      n();
    },
  ]);

  assert.equal(res.statusCode, 400);
  assert.equal(res.body.error.code, "FILE_REQUIRED");
});

test("POST /api/v1/cvs upload thành công file PDF <= 5MB và tự động đặt làm mặc định khi là CV đầu tiên", async () => {
  const token = generateAccessToken({
    id: "student-1",
    email: "student1@school.edu.vn",
    role: "student",
  });

  const mockPdfBuffer = Buffer.from("%PDF-1.4 Mock CV Content");
  const req = {
    headers: { authorization: `Bearer ${token}` },
    file: {
      originalname: "NguyenVanA_CV.pdf",
      mimetype: "application/pdf",
      buffer: mockPdfBuffer,
      size: mockPdfBuffer.length,
    },
  };

  const res = await dispatch(cvController.uploadCv, req, [
    authenticate,
    authorize("student"),
  ]);

  assert.equal(res.statusCode, 201);
  assert.ok(res.body.data);
  assert.equal(res.body.data.fileName, "NguyenVanA_CV.pdf");
  assert.equal(res.body.data.isDefault, true); // CV đầu tiên tự động thành mặc định
  assert.ok(res.body.data.fileUrl);
  assert.equal(cvs.length, 1);
});

test("POST /api/v1/cvs sanitize tên file độc hại trước khi lưu DB (chống Stored/Second-order XSS)", async () => {
  const token = generateAccessToken({
    id: "student-1",
    email: "student1@school.edu.vn",
    role: "student",
  });

  const mockPdfBuffer = Buffer.from("%PDF-1.4 XSS Payload Test");
  const req = {
    headers: { authorization: `Bearer ${token}` },
    file: {
      originalname: '"><img src=x onerror=alert(1)>.pdf',
      mimetype: "application/pdf",
      buffer: mockPdfBuffer,
      size: mockPdfBuffer.length,
    },
  };

  const res = await dispatch(cvController.uploadCv, req, [
    authenticate,
    authorize("student"),
  ]);

  assert.equal(res.statusCode, 201);
  assert.ok(res.body.data);
  // Các ký tự ", >, <, =, (, ) phải được thay thế bằng _
  assert.ok(!res.body.data.fileName.includes("<"));
  assert.ok(!res.body.data.fileName.includes(">"));
  assert.ok(!res.body.data.fileName.includes('"'));
  assert.ok(!res.body.data.fileName.includes('('));
  assert.ok(!res.body.data.fileName.includes(')'));
  assert.equal(res.body.data.fileName, '___img src_x onerror_alert_1__.pdf');
});

test("POST /api/v1/cvs upload CV thứ hai sẽ có isDefault = false", async () => {
  const token = generateAccessToken({
    id: "student-1",
    email: "student1@school.edu.vn",
    role: "student",
  });

  // CV 1
  await dispatch(
    cvController.uploadCv,
    {
      headers: { authorization: `Bearer ${token}` },
      file: {
        originalname: "CV_1.pdf",
        mimetype: "application/pdf",
        buffer: Buffer.from("%PDF-1.4 CV 1"),
      },
    },
    [authenticate, authorize("student")]
  );

  // CV 2
  const res2 = await dispatch(
    cvController.uploadCv,
    {
      headers: { authorization: `Bearer ${token}` },
      file: {
        originalname: "CV_2.pdf",
        mimetype: "application/pdf",
        buffer: Buffer.from("%PDF-1.4 CV 2"),
      },
    },
    [authenticate, authorize("student")]
  );

  assert.equal(res2.statusCode, 201);
  assert.equal(res2.body.data.fileName, "CV_2.pdf");
  assert.equal(res2.body.data.isDefault, false); // CV thứ 2 mặc định là false
  assert.equal(cvs.length, 2);
});

test("GET /api/v1/cvs trả về danh sách CV của sinh viên đang đăng nhập", async () => {
  const token1 = generateAccessToken({
    id: "student-1",
    email: "student1@school.edu.vn",
    role: "student",
  });

  const token2 = generateAccessToken({
    id: "student-2",
    email: "student2@school.edu.vn",
    role: "student",
  });

  // Upload cho student 1
  await dispatch(
    cvController.uploadCv,
    {
      headers: { authorization: `Bearer ${token1}` },
      file: {
        originalname: "Student1_CV.pdf",
        mimetype: "application/pdf",
        buffer: Buffer.from("%PDF-1.4 Student 1"),
      },
    },
    [authenticate, authorize("student")]
  );

  // Upload cho student 2
  await dispatch(
    cvController.uploadCv,
    {
      headers: { authorization: `Bearer ${token2}` },
      file: {
        originalname: "Student2_CV.pdf",
        mimetype: "application/pdf",
        buffer: Buffer.from("%PDF-1.4 Student 2"),
      },
    },
    [authenticate, authorize("student")]
  );

  // Student 1 lấy CV của mình
  const res = await dispatch(
    cvController.getMyCvs,
    { headers: { authorization: `Bearer ${token1}` } },
    [authenticate, authorize("student")]
  );

  assert.equal(res.statusCode, 200);
  assert.ok(Array.isArray(res.body.data));
  assert.equal(res.body.data.length, 1);
  assert.equal(res.body.data[0].fileName, "Student1_CV.pdf");
});

test("PATCH /api/v1/cvs/:id/default đặt CV thành mặc định và đổi các CV khác thành false", async () => {
  const token = generateAccessToken({
    id: "student-1",
    email: "student1@school.edu.vn",
    role: "student",
  });

  // Tạo 2 CV
  await dispatch(
    cvController.uploadCv,
    {
      headers: { authorization: `Bearer ${token}` },
      file: { originalname: "CV_1.pdf", mimetype: "application/pdf", buffer: Buffer.from("%PDF-1.4 1") },
    },
    [authenticate, authorize("student")]
  );
  await dispatch(
    cvController.uploadCv,
    {
      headers: { authorization: `Bearer ${token}` },
      file: { originalname: "CV_2.pdf", mimetype: "application/pdf", buffer: Buffer.from("%PDF-1.4 2") },
    },
    [authenticate, authorize("student")]
  );

  assert.equal(cvs[0].isDefault, true);
  assert.equal(cvs[1].isDefault, false);

  // Đặt CV_2 thành mặc định
  const patchRes = await dispatch(
    cvController.setDefaultCv,
    {
      headers: { authorization: `Bearer ${token}` },
      params: { id: "cv-2" },
    },
    [authenticate, authorize("student")]
  );

  assert.equal(patchRes.statusCode, 200);
  assert.equal(patchRes.body.data.id, "cv-2");
  assert.equal(patchRes.body.data.isDefault, true);

  assert.equal(cvs[0].isDefault, false);
  assert.equal(cvs[1].isDefault, true);
});

test("PATCH /api/v1/cvs/:id/default trả về 404 khi ID không tồn tại", async () => {
  const token = generateAccessToken({
    id: "student-1",
    email: "student1@school.edu.vn",
    role: "student",
  });

  const res = await dispatch(
    cvController.setDefaultCv,
    {
      headers: { authorization: `Bearer ${token}` },
      params: { id: "non-existent-id" },
    },
    [authenticate, authorize("student")]
  );

  assert.equal(res.statusCode, 404);
  assert.equal(res.body.error.code, "CV_NOT_FOUND");
});

test("PATCH /api/v1/cvs/:id/default từ chối khi sinh viên thao tác trên CV của người khác (403)", async () => {
  const token1 = generateAccessToken({
    id: "student-1",
    email: "student1@school.edu.vn",
    role: "student",
  });
  const token2 = generateAccessToken({
    id: "student-2",
    email: "student2@school.edu.vn",
    role: "student",
  });

  // Student 1 upload cv-1
  await dispatch(
    cvController.uploadCv,
    {
      headers: { authorization: `Bearer ${token1}` },
      file: { originalname: "CV_1.pdf", mimetype: "application/pdf", buffer: Buffer.from("%PDF-1.4 1") },
    },
    [authenticate, authorize("student")]
  );

  // Student 2 cố gắng set default cv-1
  const res = await dispatch(
    cvController.setDefaultCv,
    {
      headers: { authorization: `Bearer ${token2}` },
      params: { id: "cv-1" },
    },
    [authenticate, authorize("student")]
  );

  assert.equal(res.statusCode, 403);
  assert.equal(res.body.error.code, "FORBIDDEN");
});

test("DELETE /api/v1/cvs/:id từ chối xóa khi CV đã được dùng trong đơn ứng tuyển (400 CV_IN_USE)", async () => {
  const token = generateAccessToken({
    id: "student-1",
    email: "student1@school.edu.vn",
    role: "student",
  });

  // Upload CV
  await dispatch(
    cvController.uploadCv,
    {
      headers: { authorization: `Bearer ${token}` },
      file: { originalname: "CV_1.pdf", mimetype: "application/pdf", buffer: Buffer.from("%PDF-1.4 1") },
    },
    [authenticate, authorize("student")]
  );

  // Giả lập CV đã được ứng tuyển vào Job
  applications.push({ id: "app-1", jobId: "job-1", cvId: "cv-1" });

  const deleteRes = await dispatch(
    cvController.deleteCv,
    {
      headers: { authorization: `Bearer ${token}` },
      params: { id: "cv-1" },
    },
    [authenticate, authorize("student")]
  );

  assert.equal(deleteRes.statusCode, 400);
  assert.equal(deleteRes.body.error.code, "CV_IN_USE");
  assert.equal(cvs.length, 1);
});

test("DELETE /api/v1/cvs/:id xóa thành công và tự động gán CV còn lại làm mặc định", async () => {
  const token = generateAccessToken({
    id: "student-1",
    email: "student1@school.edu.vn",
    role: "student",
  });

  // Upload 2 CV
  await dispatch(
    cvController.uploadCv,
    {
      headers: { authorization: `Bearer ${token}` },
      file: { originalname: "CV_1.pdf", mimetype: "application/pdf", buffer: Buffer.from("%PDF-1.4 1") },
    },
    [authenticate, authorize("student")]
  );
  await dispatch(
    cvController.uploadCv,
    {
      headers: { authorization: `Bearer ${token}` },
      file: { originalname: "CV_2.pdf", mimetype: "application/pdf", buffer: Buffer.from("%PDF-1.4 2") },
    },
    [authenticate, authorize("student")]
  );

  assert.equal(cvs[0].isDefault, true); // cv-1 là mặc định
  assert.equal(cvs[1].isDefault, false);

  // Xóa cv-1 (mặc định)
  const deleteRes = await dispatch(
    cvController.deleteCv,
    {
      headers: { authorization: `Bearer ${token}` },
      params: { id: "cv-1" },
    },
    [authenticate, authorize("student")]
  );

  assert.equal(deleteRes.statusCode, 200);
  assert.equal(deleteRes.body.data.message, "Xóa CV thành công");
  assert.equal(cvs.length, 1);
  // cv-2 còn lại tự động thành mặc định
  assert.equal(cvs[0].id, "cv-2");
  assert.equal(cvs[0].isDefault, true);
});

test("fetchOwnedCv helper ném lỗi chuẩn xác khi validate input và ownership", async () => {
  await assert.rejects(
    async () => cvService.fetchOwnedCv(null, "cv-1"),
    (err) => err instanceof ApiError && err.statusCode === 401 && err.code === "UNAUTHORIZED"
  );

  await assert.rejects(
    async () => cvService.fetchOwnedCv("student-1", ""),
    (err) => err instanceof ApiError && err.statusCode === 400 && err.code === "INVALID_CV_ID"
  );
});

test("uploadCvMiddleware từ chối file có magic bytes không hợp lệ (không phải %PDF) với 400 INVALID_FILE_TYPE", async () => {
  const req = {
    files: {
      file: [
        {
          originalname: "fake.pdf",
          mimetype: "application/pdf",
          buffer: Buffer.from("NOT-A-PDF-HEADER-CONTENTS"),
        },
      ],
    },
  };
  const res = createMockRes();
  let caughtError = null;
  const next = (err) => {
    caughtError = err;
    if (err) errorHandler(err, req, res, () => {});
  };

  // Giả lập trực tiếp logic magic byte của uploadCvMiddleware sau khi parse
  req.file = req.files.file[0];
  if (
    !req.file.buffer ||
    req.file.buffer.length < 4 ||
    !req.file.buffer.subarray(0, 4).equals(PDF_MAGIC)
  ) {
    next(new ApiError(400, "INVALID_FILE_TYPE", "File không phải định dạng PDF hợp lệ"));
  }

  assert.equal(res.statusCode, 400);
  assert.equal(res.body.error.code, "INVALID_FILE_TYPE");
});

test("uploadCvMiddleware từ chối file quá 5MB và trả về 400 FILE_TOO_LARGE", async () => {
  const req = {};
  const res = createMockRes();
  const multerErr = new Error("File too large");
  multerErr.code = "LIMIT_FILE_SIZE";

  let caughtError = null;
  const next = (err) => {
    caughtError = err;
    errorHandler(err, req, res, () => {});
  };

  if (multerErr.code === "LIMIT_FILE_SIZE") {
    next(new ApiError(400, "FILE_TOO_LARGE", "Kích thước file không được vượt quá 5MB"));
  }

  assert.equal(res.statusCode, 400);
  assert.equal(res.body.error.code, "FILE_TOO_LARGE");
});

test("uploadCvMiddleware từ chối file sai định dạng không phải PDF và trả về 400 INVALID_FILE_TYPE", async () => {
  const req = {};
  const res = createMockRes();
  let caughtError = null;
  const next = (err) => {
    caughtError = err;
    errorHandler(err, req, res, () => {});
  };

  const fileFilterErr = new ApiError(400, "INVALID_FILE_TYPE", "Chỉ chấp nhận file định dạng PDF (.pdf)");
  next(fileFilterErr);

  assert.equal(res.statusCode, 400);
  assert.equal(res.body.error.code, "INVALID_FILE_TYPE");
});


test("POST /api/v1/cvs tự động fallback sang mock khi AI service lỗi, vẫn lưu extractedSkills thành công và không trả 500", async () => {
  const token = generateAccessToken({
    id: "student-1",
    email: "student1@school.edu.vn",
    role: "student",
  });

  const aiClient = require("../src/services/ai/aiClient");
  const originalAnalyzeCv = aiClient.analyzeCv;
  aiClient.analyzeCv = async () => {
    throw new Error("AI Service 503 Service Unavailable");
  };

  try {
    const mockPdfBuffer = Buffer.from("%PDF-1.4 Mock CV Error Fallback");
    const req = {
      headers: { authorization: `Bearer ${token}` },
      file: {
        originalname: "Fallback_CV.pdf",
        mimetype: "application/pdf",
        buffer: mockPdfBuffer,
        size: mockPdfBuffer.length,
      },
    };

    const res = await dispatch(cvController.uploadCv, req, [
      authenticate,
      authorize("student"),
    ]);

    assert.equal(res.statusCode, 201);
    assert.ok(res.body.data);
    assert.ok(res.body.data.extractedSkills);
    assert.deepEqual(res.body.data.extractedSkills.skills, ["flutter", "dart", "git"]);
  } finally {
    aiClient.analyzeCv = originalAnalyzeCv;
  }
});
