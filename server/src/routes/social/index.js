// Router gốc của module social (mount ở /api/social).
const express = require("express");
const { authenticate } = require("../../middleware/auth");
const { ApiError } = require("../../middleware/error");

const router = express.Router();

// Đăng nhập bắt buộc cho MỌI route social: gắn 1 lần ở đây
router.use(authenticate);

router.use(require("./post.routes"));
router.use(require("./comment.routes"));
router.use(require("./reaction.routes"));
router.use(require("./media.routes"));

// Token còn hạn nhưng user đã bị xóa khỏi DB -> khóa ngoại (FK) báo lỗi 23503 -> trả 401 thay vì 500
router.use((err, _req, _res, next) => {
  if (err && err.code === "23503" && /table "users"/.test(err.detail || "")) {
    return next(new ApiError(401, "UNAUTHORIZED", "Tài khoản không còn tồn tại, hãy đăng nhập lại"));
  }
  return next(err);
});

module.exports = router;
