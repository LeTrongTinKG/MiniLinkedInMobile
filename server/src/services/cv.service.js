const cvRepository = require("../repositories/cv.repository");
const storageService = require("./storage/storage.service");
const aiClient = require("./ai/aiClient");
const { ApiError } = require("../middleware/error");

/**
 * Service xử lý nghiệp vụ quản lý CV
 * Áp dụng SOLID (DIP, SRP): cho phép inject repository, storage adapter và aiClient
 */

/**
 * Helper tìm CV và xác thực quyền sở hữu của user
 * Tránh lặp code giữa setDefaultCv và deleteCv
 * @param {string} userId - ID người dùng đang đăng nhập
 * @param {string} cvId - ID CV cần truy vấn
 * @param {Object} repo - CV repository
 * @returns {Promise<Object>} Bản ghi CV hợp lệ
 */
async function fetchOwnedCv(userId, cvId, repo = cvRepository) {
  if (!userId) {
    throw new ApiError(401, "UNAUTHORIZED", "Yêu cầu đăng nhập");
  }

  if (typeof cvId !== "string" || cvId.trim().length === 0) {
    throw new ApiError(400, "INVALID_CV_ID", "ID CV không hợp lệ");
  }

  let cv;
  try {
    cv = await repo.findById(cvId.trim());
  } catch (error) {
    if (error?.code === "P2023") {
      throw new ApiError(404, "CV_NOT_FOUND", "Không tìm thấy CV");
    }
    throw error;
  }

  if (!cv) {
    throw new ApiError(404, "CV_NOT_FOUND", "Không tìm thấy CV");
  }

  // Kiểm tra quyền sở hữu
  if (cv.userId !== userId) {
    throw new ApiError(403, "FORBIDDEN", "Bạn không có quyền thao tác trên CV này");
  }

  return cv;
}

/**
 * Upload CV mới
 */
async function uploadCv(
  { userId, file },
  repo = cvRepository,
  storage = storageService,
  ai = aiClient
) {
  if (!userId) {
    throw new ApiError(401, "UNAUTHORIZED", "Yêu cầu đăng nhập");
  }

  if (!file || !file.buffer) {
    throw new ApiError(400, "FILE_REQUIRED", "File CV là bắt buộc");
  }

  // Sanitize tên file để ngăn chặn XSS và Directory Traversal
  const rawFileName = typeof file.originalname === "string" ? file.originalname : "cv.pdf";
  const sanitizedFileName = rawFileName
    .replace(/[^a-zA-Z0-9._\- ]/g, "_")
    .slice(0, 128);

  // 1. Upload file lên Storage (Supabase hoặc Mock)
  const uploadResult = await storage.uploadFile({
    buffer: file.buffer,
    originalName: sanitizedFileName,
    mimeType: file.mimetype,
    userId,
  });

  // 2. Phân tích kỹ năng qua aiClient. Lỗi AI không chặn upload — lưu extractedSkills = null
  let extractedSkills = null;
  try {
    extractedSkills = await ai.analyzeCv(file.buffer, sanitizedFileName);
  } catch (aiErr) {
    console.warn("AI service analyzeCv error (fallback null):", aiErr.message);
  }

  // 3. Kiểm tra xem sinh viên đã có CV nào chưa -> Nếu chưa có, tự động đặt làm CV mặc định
  const currentCount = await repo.countByUserId(userId);
  const isDefault = currentCount === 0;

  // 4. Lưu bản ghi vào Database
  const cv = await repo.createCv({
    userId,
    fileName: sanitizedFileName,
    fileUrl: uploadResult.url,
    extractedSkills,
    isDefault,
  });

  return cv;
}

/**
 * Lấy danh sách tất cả CV của sinh viên đang đăng nhập
 */
async function getMyCvs(userId, repo = cvRepository) {
  if (!userId) {
    throw new ApiError(401, "UNAUTHORIZED", "Yêu cầu đăng nhập");
  }
  return repo.findByUserId(userId);
}

/**
 * Đặt một CV làm CV mặc định duy nhất
 */
async function setDefaultCv(userId, cvId, repo = cvRepository) {
  const cv = await fetchOwnedCv(userId, cvId, repo);
  return repo.setDefaultCv(userId, cv.id);
}

/**
 * Xóa một CV
 */
async function deleteCv(
  userId,
  cvId,
  repo = cvRepository,
  storage = storageService
) {
  const cv = await fetchOwnedCv(userId, cvId, repo);

  // Kiểm tra CV đã được dùng trong đơn ứng tuyển chưa (bảo toàn lịch sử ứng tuyển)
  const applicationsCount = cv._count?.applications ?? 0;
  if (applicationsCount > 0) {
    throw new ApiError(
      400,
      "CV_IN_USE",
      "Không thể xóa CV đã được dùng để ứng tuyển việc làm"
    );
  }

  // 1. Xóa bản ghi trong Database trước (DB có thể rollback hoặc ném lỗi nếu vi phạm ràng buộc)
  await repo.deleteCv(cv.id);

  // 2. Nếu CV vừa xóa là CV mặc định, tự động gán CV gần nhất còn lại làm mặc định
  if (cv.isDefault) {
    const nextDefault = await repo.findFirstByUserId(userId);
    if (nextDefault) {
      await repo.updateCvDefault(nextDefault.id, true);
    }
  }

  // 3. Xóa file trên Storage sau khi DB đã xóa sạch (tránh URL hỏng và orphaned DB row)
  try {
    await storage.deleteFile(cv.fileUrl);
  } catch (storageErr) {
    console.warn("Lỗi khi xóa file trên Storage (không chặn nghiệp vụ DB):", storageErr.message);
  }

  return { message: "Xóa CV thành công" };
}

module.exports = {
  uploadCv,
  getMyCvs,
  setDefaultCv,
  deleteCv,
};
