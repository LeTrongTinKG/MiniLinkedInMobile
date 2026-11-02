// Test nén ảnh bằng ảnh mẫu tạo bằng sharp.
const assert = require("node:assert/strict");
const test = require("node:test");
const sharp = require("sharp");
const { compressImage } = require("../../src/services/social/media/image-compress");
const { validateImage } = require("../../src/services/social/media/image-validate");

// Tạo ảnh màu ngẫu nhiên (để ảnh nặng, nén mới có ý nghĩa)
async function makeImage(width, height, format = "jpeg", options = {}) {
  const raw = Buffer.alloc(width * height * 3);
  for (let i = 0; i < raw.length; i++) raw[i] = (i * 7 + (i >> 5)) & 255;
  let img = sharp(raw, { raw: { width, height, channels: 3 } });
  if (options.exif) img = img.withExif({ IFD0: { Make: "TestCam", Copyright: "secret" } });
  if (options.orientation) img = img.withMetadata({ orientation: options.orientation });
  return img[format]().toBuffer();
}

test("ảnh JPEG lớn: ra WebP, cạnh dài <= 1920, không còn EXIF, thumbnail <= 400", async () => {
  const input = await makeImage(3000, 2000, "jpeg", { exif: true });
  assert.ok((await sharp(input).metadata()).exif, "ảnh mẫu phải có EXIF");

  const { main, thumb } = await compressImage(input, "jpeg");

  const meta = await sharp(main.buffer).metadata();
  assert.equal(meta.format, "webp");
  assert.ok(Math.max(meta.width, meta.height) <= 1920);
  assert.equal(meta.width, 1920);
  assert.equal(meta.exif, undefined, "EXIF phải bị xóa");

  const thumbMeta = await sharp(thumb.buffer).metadata();
  assert.equal(thumbMeta.format, "webp");
  assert.ok(Math.max(thumbMeta.width, thumbMeta.height) <= 400);
  assert.equal(thumbMeta.exif, undefined);
  assert.ok(main.buffer.length < input.length, "ảnh sau nén phải nhỏ hơn");
});

test("ảnh nhỏ không bị phóng to", async () => {
  const input = await makeImage(300, 200, "png");
  const { main } = await compressImage(input, "png");
  assert.equal(main.width, 300);
  assert.equal(main.height, 200);
});

test("ảnh chụp dọc (EXIF xoay 90 độ) được xoay đúng chiều trước khi bỏ EXIF", async () => {
  // Ảnh lưu 400x200 kèm cờ orientation 6 => khi hiển thị là 200x400 (dọc)
  const input = await makeImage(400, 200, "jpeg", { orientation: 6 });
  const { main } = await compressImage(input, "jpeg");
  assert.equal(main.width, 200);
  assert.equal(main.height, 400);
  assert.equal((await sharp(main.buffer).metadata()).orientation, undefined);
});

test("ảnh PNG => WebP lossless (giữ nguyên điểm ảnh)", async () => {
  const input = await makeImage(200, 100, "png");
  const { main } = await compressImage(input, "png");
  const original = await sharp(input).raw().toBuffer();
  const result = await sharp(main.buffer).raw().toBuffer();
  assert.ok(original.equals(result), "PNG -> WebP lossless phải giống hệt từng điểm ảnh");
});

test("file hỏng => INVALID_FILE_TYPE", async () => {
  await assert.rejects(
    compressImage(Buffer.from("khong phai anh"), "jpeg"),
    (err) => err.code === "INVALID_FILE_TYPE"
  );
});

test("validateImage: kiểm tra MIME, đuôi, magic bytes, dung lượng", async () => {
  const jpeg = await makeImage(50, 50, "jpeg");
  assert.equal(validateImage({ buffer: jpeg, mimetype: "image/jpeg", originalname: "a.JPG" }), "jpeg");

  const cases = [
    [{ buffer: jpeg, mimetype: "application/pdf", originalname: "a.jpg" }, "INVALID_FILE_TYPE"],
    [{ buffer: jpeg, mimetype: "image/jpeg", originalname: "a.exe" }, "INVALID_FILE_TYPE"],
    [{ buffer: Buffer.from("MZ not image"), mimetype: "image/png", originalname: "a.png" }, "INVALID_FILE_TYPE"],
    [{ buffer: Buffer.alloc(10 * 1024 * 1024 + 1), mimetype: "image/png", originalname: "a.png" }, "FILE_TOO_LARGE"],
    [
      {
        buffer: Buffer.concat([Buffer.from([0, 0, 0, 24]), Buffer.from("ftypheic"), Buffer.alloc(8)]),
        mimetype: "image/jpeg",
        originalname: "a.jpg",
      },
      "INVALID_FILE_TYPE",
    ],
  ];
  for (const [file, code] of cases) {
    assert.throws(() => validateImage(file), (err) => err.statusCode === 400 && err.code === code);
  }
});
