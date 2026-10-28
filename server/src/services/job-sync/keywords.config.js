// Cấu hình kéo job: từ khóa (có thứ tự), ngân sách request, mục tiêu. Sửa ở đây, không cần động vào code.

// Từ khóa chạy từ trên xuống. Nhóm 1: cấp độ + stack, nhóm 2: công ty ưu tiên, nhóm 3: từ khóa rộng.
const KEYWORDS = [
  // Nhóm 1: cấp độ + stack phổ biến
  "junior developer",
  "fresher java",
  "intern flutter",
  "junior node.js",
  "thực tập sinh lập trình",
  "fresher react",
  "junior python",
  // Nhóm 2: công ty ưu tiên
  "FPT Software fresher",
  "VNG junior",
  // Nhóm 3: từ khóa rộng
  "lập trình viên",
  "software engineer vietnam",
];

module.exports = {
  KEYWORDS,
  TARGET_JOBS: 100, // đủ số job sạch này thì dừng
  BUDGET: { jsearch: 10, serpapi: 3, remotive: 1 }, // số request tối đa mỗi lượt
  REMOTIVE_MAX_SHARE: 0.2, // Remotive chiếm tối đa ~20% tổng số job
  MIN_CLEAN_PER_KEYWORD: 3, // JSearch ra ít hơn số này job sạch thì mới nhờ SerpApi bù
  MAX_AGE_DAYS: 30, // đăng quá 30 ngày thì loại
  CLOSE_AFTER_DAYS: 14, // 14 ngày không còn thấy trên nguồn thì đóng job
};
