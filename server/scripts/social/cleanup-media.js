// Chạy: node scripts/social/cleanup-media.js [số giờ, mặc định 24]
// Xóa ảnh upload lên mà quá N giờ vẫn chưa gắn vào bài nào (chưa cần cron, chạy tay khi cần).
require("dotenv").config({ quiet: true });
const { pool } = require("../../src/lib/social/db");
const { cleanupOrphanMedia } = require("../../src/services/social/media.service");

const hours = Number(process.argv[2]) || 24;

cleanupOrphanMedia(hours)
  .then((count) => console.log(`Đã dọn ${count} ảnh rác (cũ hơn ${hours} giờ)`))
  .catch((err) => {
    console.error("Dọn ảnh lỗi:", err.message);
    process.exitCode = 1;
  })
  .finally(() => pool.end());
