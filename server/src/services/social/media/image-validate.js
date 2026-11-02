// Kiểm tra file ảnh upload: loại file (MIME + đuôi + magic bytes) và dung lượng.
const { ApiError } = require("../../../middleware/error");

const MAX_IMAGE_SIZE = 10 * 1024 * 1024; // 10MB

const ALLOWED = {
  "image/jpeg": [".jpg", ".jpeg"],
  "image/png": [".png"],
  "image/webp": [".webp"],
};

const invalidType = (message) => new ApiError(400, "INVALID_FILE_TYPE", message);

// Đọc vài byte đầu file để biết file thật sự là loại gì (không tin tên file)
function detectKind(buf) {
  if (buf.length >= 3 && buf[0] === 0xff && buf[1] === 0xd8 && buf[2] === 0xff) return "jpeg";
  if (
    buf.length >= 8 &&
    buf.subarray(0, 8).equals(Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]))
  ) {
    return "png";
  }
  if (
    buf.length >= 12 &&
    buf.subarray(0, 4).toString("ascii") === "RIFF" &&
    buf.subarray(8, 12).toString("ascii") === "WEBP"
  ) {
    return "webp";
  }
  // HEIC/HEIF: byte 4-11 là "ftyp" + brand heic/heix/mif1...
  if (buf.length >= 12 && buf.subarray(4, 8).toString("ascii") === "ftyp") return "heic";
  return null;
}

// Trả về loại ảnh thật ("jpeg" | "png" | "webp"), sai thì ném ApiError
function validateImage(file) {
  if (!file || !file.buffer) throw new ApiError(400, "FILE_REQUIRED", "File ảnh là bắt buộc");
  if (file.buffer.length > MAX_IMAGE_SIZE) {
    throw new ApiError(400, "FILE_TOO_LARGE", "Ảnh không được vượt quá 10MB");
  }

  const exts = ALLOWED[file.mimetype];
  const name = String(file.originalname || "").toLowerCase();
  if (!exts || !exts.some((e) => name.endsWith(e))) {
    throw invalidType("Chỉ chấp nhận ảnh JPEG, PNG hoặc WebP");
  }

  const kind = detectKind(file.buffer);
  if (kind === "heic") throw invalidType("Ảnh HEIC chưa được hỗ trợ, hãy đổi sang JPEG hoặc PNG");
  if (!kind) throw invalidType("Nội dung file không phải ảnh hợp lệ");
  return kind;
}

module.exports = { validateImage, detectKind, MAX_IMAGE_SIZE };
