const cvRepository = require("../repositories/cv.repository");
const storageService = require("./storage/storage.service");
const { analyzeCv } = require("./ai/aiClient");
const { ApiError } = require("../middleware/error");

/**
 * Service xử lý nghiệp vụ quản lý CV
 * Áp dụng SOLID (DIP, SRP): cho phép inject repository, storage adapter và aiClient
 */

/**
 * Upload CV mới
 */
async function uploadCv(
  { userId, file },
  repo = cvRepository,
  storage = storageService,
  ai = { analyzeCv }
) {
  if (!file || !file.buffer) {
    throw new ApiError(400, "FILE_REQUIRED", "File CV là bắt buộc");
  }

  // 1. Upload file lên Storage (Supabase hoặc Mock)
  const uploadResult = await storage.uploadFile({
    buffer: file.buffer,
    originalName: file.originalname,
    mimeType: file.mimetype,
    userId,
  });

  // 2. Phân tích kỹ năng qua AI service (Graceful degradation: nếu AI lỗi thì vẫn lưu CV và set extractedSkills = null)
  let extractedSkills = null;
  try {
    extractedSkills = await ai.analyzeCv(file.buffer, file.originalname);
  } catch (aiErr) {
    console.warn("AI service analyzeCv error (fallback to null):", aiErr.message);
    extractedSkills = null;
  }

  // 3. Kiểm tra xem sinh viên đã có CV nào chưa -> Nếu chưa có, tự động đặt làm CV mặc định
  const currentCount = await repo.countByUserId(userId);
  const isDefault = currentCount === 0;

  // 4. Lưu bản ghi vào Database
  const cv = await repo.createCv({
    userId,
    fileName: file.originalname,
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
    throw new ApiError(403, "FORBIDDEN", "Bạn không có quyền xóa CV này");
  }

  // Kiểm tra CV đã được dùng trong đơn ứng tuyển chưa (bảo toàn lịch sử ứng tuyển)
  const applicationsCount = cv._count?.applications ?? 0;
  if (applicationsCount > 0) {
    throw new ApiError(
      400,
      "CV_IN_USE",
      "Không thể xóa CV đã được dùng để ứng tuyển việc làm"
    );
  }

  // Xóa file trên Storage
  await storage.deleteFile(cv.fileUrl);

  // Xóa bản ghi trong Database
  await repo.deleteCv(cv.id);

  // Nếu CV vừa xóa là CV mặc định, tự động gán CV gần nhất còn lại làm mặc định
  if (cv.isDefault) {
    const nextDefault = await repo.findFirstByUserId(userId);
    if (nextDefault) {
      await repo.updateCvDefault(nextDefault.id, true);
    }
  }

  return { message: "Xóa CV thành công" };
}

module.exports = {
  uploadCv,
  getMyCvs,
  setDefaultCv,
  deleteCv,
};
