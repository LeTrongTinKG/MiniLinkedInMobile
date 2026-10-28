const { ApiError } = require("../middleware/error");

const VALID_APPLICATION_STATUSES = [
  "submitted",
  "viewed",
  "shortlisted",
  "accepted",
  "rejected",
  "withdrawn",
];

const ALLOWED_DECISION_STATUSES = ["viewed", "shortlisted", "accepted", "rejected"];

const WITHDRAWABLE_STATUSES = ["submitted", "viewed", "shortlisted"];

const VALID_STATUS_TRANSITIONS = {
  submitted: ["viewed", "shortlisted", "accepted", "rejected"],
  viewed: ["shortlisted", "accepted", "rejected"],
  shortlisted: ["accepted", "rejected"],
  accepted: [],
  rejected: [],
  withdrawn: [],
};

function canTransitionStatus(currentStatus, newStatus) {
  const allowed = VALID_STATUS_TRANSITIONS[currentStatus];
  return Array.isArray(allowed) && allowed.includes(newStatus);
}

function assertCanUpdateStatus(currentStatus, newStatus) {
  if (currentStatus === "withdrawn") {
    throw new ApiError(
      400,
      "CANNOT_UPDATE_WITHDRAWN",
      "Không thể duyệt hoặc từ chối đơn ứng tuyển đã được sinh viên rút"
    );
  }
  if (currentStatus === "accepted" || currentStatus === "rejected") {
    throw new ApiError(
      400,
      "CANNOT_UPDATE_FINALIZED",
      "Đơn ứng tuyển đã có kết quả quyết định cuối cùng"
    );
  }
  if (!canTransitionStatus(currentStatus, newStatus)) {
    throw new ApiError(
      400,
      "INVALID_STATUS_TRANSITION",
      `Không thể chuyển trạng thái từ ${currentStatus} sang ${newStatus}`
    );
  }
}

/**
 * Trích xuất mảng kỹ năng từ bản ghi CV
 */
function extractCvSkills(cv) {
  if (!cv || !cv.extractedSkills) return [];
  if (Array.isArray(cv.extractedSkills.skills)) {
    return cv.extractedSkills.skills;
  }
  if (Array.isArray(cv.extractedSkills)) {
    return cv.extractedSkills;
  }
  return [];
}

/**
 * Tìm Job hoặc ném lỗi nếu không tồn tại / sai ID
 */
async function findJobOrThrow(jobId, jobRepo) {
  let job;
  try {
    job = await jobRepo.findJobById(jobId);
  } catch (err) {
    if (err?.code === "P2023") throw new ApiError(404, "JOB_NOT_FOUND", "Không tìm thấy công việc");
    throw err;
  }
  if (!job) throw new ApiError(404, "JOB_NOT_FOUND", "Không tìm thấy công việc");
  return job;
}

/**
 * Xác định CV được nộp (theo cvId chỉ định hoặc CV mặc định)
 */
async function resolveTargetCv(userId, cvId, cvRepo) {
  if (typeof cvId === "string" && cvId.trim().length > 0) {
    const cv = await cvRepo.findById(cvId.trim());
    if (!cv) {
      throw new ApiError(404, "CV_NOT_FOUND", "Không tìm thấy CV");
    }
    if (cv.userId !== userId) {
      throw new ApiError(403, "FORBIDDEN", "Bạn không có quyền sử dụng CV này");
    }
    return cv;
  }

  const defaultCv = await cvRepo.findDefaultByUserId(userId);
  if (!defaultCv) {
    throw new ApiError(400, "NO_CV_FOUND", "Vui lòng tải lên hoặc chọn một CV để ứng tuyển");
  }
  return defaultCv;
}

module.exports = {
  VALID_APPLICATION_STATUSES,
  ALLOWED_DECISION_STATUSES,
  WITHDRAWABLE_STATUSES,
  VALID_STATUS_TRANSITIONS,
  canTransitionStatus,
  assertCanUpdateStatus,
  extractCvSkills,
  findJobOrThrow,
  resolveTargetCv,
};
