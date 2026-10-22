const multer = require("multer");
const { ApiError } = require("./error");

const MAX_FILE_SIZE = 5 * 1024 * 1024; // 5 MB
const PDF_MAGIC = Buffer.from([0x25, 0x50, 0x44, 0x46]); // %PDF

const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: MAX_FILE_SIZE,
  },
  fileFilter: (_req, file, cb) => {
    const isPdfMime = file.mimetype === "application/pdf";
    const isPdfExt =
      typeof file.originalname === "string" &&
      file.originalname.toLowerCase().endsWith(".pdf");

    // Phải thỏa mãn CẢ HAI điều kiện: MIME type và file extension
    if (!isPdfMime || !isPdfExt) {
      return cb(
        new ApiError(400, "INVALID_FILE_TYPE", "Chỉ chấp nhận file định dạng PDF (.pdf)")
      );
    }
    cb(null, true);
  },
}).fields([
  { name: "file", maxCount: 1 },
  { name: "cv", maxCount: 1 },
]);

/**
 * Middleware xử lý upload file CV PDF tối đa 5MB
 * Hỗ trợ nhận file qua field name "file" hoặc "cv"
 * Bắt lỗi kích thước (FILE_TOO_LARGE) và định dạng (INVALID_FILE_TYPE) trả về HTTP 400
 */
function uploadCvMiddleware(req, res, next) {
  upload(req, res, (err) => {
    if (err) {
      if (err instanceof multer.MulterError) {
        if (err.code === "LIMIT_FILE_SIZE") {
          return next(
            new ApiError(400, "FILE_TOO_LARGE", "Kích thước file không được vượt quá 5MB")
          );
        }
        return next(new ApiError(400, "VALIDATION_ERROR", err.message));
      }
      return next(err);
    }

    // Chuẩn hóa file lấy từ field 'file' hoặc 'cv' gán vào req.file
    req.file = req.files?.file?.[0] || req.files?.cv?.[0];

    if (!req.file) {
      return next(new ApiError(400, "FILE_REQUIRED", "File CV là bắt buộc"));
    }

    // Magic byte validation: kiểm tra nội dung thực sự có header %PDF không
    if (
      !req.file.buffer ||
      req.file.buffer.length < 4 ||
      !req.file.buffer.subarray(0, 4).equals(PDF_MAGIC)
    ) {
      return next(
        new ApiError(400, "INVALID_FILE_TYPE", "File không phải định dạng PDF hợp lệ")
      );
    }

    return next();
  });
}

module.exports = {
  uploadCvMiddleware,
  MAX_FILE_SIZE,
  PDF_MAGIC,
};
