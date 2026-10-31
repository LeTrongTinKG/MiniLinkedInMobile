# ADR-0007 · Độ tin cậy theo commit, hạn mức quét, chấm job bằng skill đã duyệt

- **Trạng thái:** Đề xuất · 2026-10-31
- **Bổ sung cho:** [ADR-0005](0005-skills-need-evidence.md). Không thay thế ADR-0005.
- **Nguồn:** Atom, ADR-0011 và ALG-05. Ngưỡng chép nguyên, không tự đặt.

## Bối cảnh

ADR-0005 lưu bằng chứng nhưng mọi skill đã duyệt đều ngang nhau: một chữ trong README cũng như nhiều tháng viết code. Không có trần số lần quét GitHub. Điểm job chỉ nhìn skill trong CV, bỏ skill GitHub người dùng đã đồng ý.

## Quyết định

1. **Độ tin cậy** do tín hiệu tính, không do nút "Thêm vào hồ sơ".
   - Tín hiệu mạnh là commit của đúng tài khoản GitHub đã liên kết: ít nhất 5 commit, 200 dòng thêm, trải 14 ngày. Tối đa 3 commit mỗi ngày. Bỏ file sinh tự động và file khóa. Commit đầu hơn 1000 dòng chỉ bị bỏ khi đã đọc tới gốc lịch sử.
   - `evidenced` khi có tín hiệu mạnh và một tín hiệu độc lập: thư viện khai báo ở repo đã có ít nhất một commit hợp lệ, hoặc tín hiệu mạnh ở một repo khác.
   - Mọi trường hợp còn lại là `self_claimed`. Giao diện, khi đạt `evidenced`, viết "Có hoạt động mã nguồn đáng kể". Không viết "thành thạo".
2. **Hạn mức:** 3 lần quét thành công mỗi tháng, tính từ ngày 1 theo giờ Việt Nam. Lượt thất bại (GitHub lỗi, không có repo) không tính. Đang có một lần quét chạy thì lần bấm thứ hai nhận `SCAN_ALREADY_RUNNING`. Hết lượt nhận `QUOTA_EXCEEDED` kèm `resetsAt`.
3. **Chấm job** dùng skill trong CV cộng skill GitHub đã duyệt (`user_skills.source = github`). Trùng tên chỉ tính một lần. Skill tự khai không đưa vào.

## Hệ quả

- Một lần quét gọi thêm GitHub để đọc commit (tối đa 20 commit mỗi repo, 240 lời gọi cả lượt). Không có `GITHUB_READ_TOKEN` thì dễ chạm trần 60 lời gọi/giờ; lượt đó thất bại và không trừ hạn mức.
- Chạy `prisma/skill_confidence_ext.sql` (hoặc `prisma db push`) rồi `prisma/rls_lockdown.sql`.
- Đơn đã nộp giữ điểm cũ. Đơn mới và màn chi tiết job dùng cách chấm mới.
- shortcut: ngưỡng và hạn mức nằm trong code (`scoreCommits.js`, `scanQuota.js`), không có bảng cài đặt như Atom. Đổi số thì sửa code và viết ADR mới.
