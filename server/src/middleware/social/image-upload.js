// Nhận 1 ảnh từ multipart field "file" (tối đa 10MB), để trong bộ nhớ.
const multer = require("multer");
const { ApiError } = require("../error");
const { MAX_IMAGE_SIZE } = require("../../services/social/media/image-validate");

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: MAX_IMAGE_SIZE, files: 1 },
}).single("file");

function uploadImageMiddleware(req, res, next) {
  upload(req, res, (err) => {
    if (err instanceof multer.MulterError) {
      if (err.code === "LIMIT_FILE_SIZE") {
        return next(new ApiError(400, "FILE_TOO_LARGE", "Ảnh không được vượt quá 10MB"));
      }
      return next(new ApiError(400, "VALIDATION_ERROR", "Upload không hợp lệ (chỉ gửi 1 ảnh ở field 'file')"));
    }
    if (err) return next(err);
    if (!req.file) return next(new ApiError(400, "FILE_REQUIRED", "File ảnh là bắt buộc"));
    return next();
  });
}

module.exports = { uploadImageMiddleware };
