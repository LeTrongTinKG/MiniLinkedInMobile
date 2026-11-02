// Bước 9: hình thức làm việc (onsite / hybrid / remote)

// "remote" nhưng không phải kiểu "no remote", "không remote"
const REMOTE_RE = /(?<!no |not |không |ko )\b(remote|work from home|wfh)\b|(?<!không )làm việc từ xa|\btừ xa\b/i;
const HYBRID_RE = /\bhybrid\b/i;

function inferWorkMode({ isRemote, title, description }) {
  const t = String(title || "");
  const d = String(description || "");

  // Tiêu đề rõ ràng thì tin tiêu đề trước
  if (HYBRID_RE.test(t)) return "hybrid";
  if (REMOTE_RE.test(t)) return "remote";
  // Cờ remote do nguồn báo
  if (isRemote === true) return "remote";
  // Rồi tới mô tả
  if (HYBRID_RE.test(d)) return "hybrid";
  if (REMOTE_RE.test(d)) return "remote";
  return "onsite";
}

module.exports = { inferWorkMode };
