# Bảng Đối Chiếu Nhất Quán Lô 4: Hồ Sơ Mở Rộng & Bằng Chứng AI (00-BATCH-4.md)

Lô 4 gồm 4 màn hình: `S-01-SPLASH`, `S-10-EDIT-PROFILE`, `S-12-ANALYSIS-CONSENT`, `S-13-REPO-EVIDENCE`.

---

## 1. Bảng Đối Chiếu Các Thành Phần Chủ Đạo

| Tiêu Chí | S-01 Splash | S-10 Edit Profile | S-12 Analysis Consent | S-13 Repo Evidence |
| :--- | :--- | :--- | :--- | :--- |
| **Vai trò** | Khởi động & phân quyền | Cập nhật hồ sơ cá nhân | Xin phép phân tích tự động | Quét repo lấy bằng chứng |
| **Vị trí Hành động chính** | Tự động chuyển hướng / Nút Thử lại | Nút "Lưu" pill góc trên phải | Nút "Tôi đồng ý" ở chân trang | Nút "Quét Repo" cạnh ô nhập |
| **Độ bo góc (Radius)** | Card lỗi 16dp, Nút 20dp | Card 16dp, Ô nhập 12dp | Card 16dp, Nút 20dp | Card 16dp, Chip 8dp, Nút 20dp |
| **Cam kết Riêng tư** | Bảo mật phiên đăng nhập | Mặc định riêng tư `isPrivate: true` | Cam kết không đọc Repo private | Tự kiểm tra Consent trước khi quét |
| **Xử lý trạng thái rỗng** | N/A (màn hình chuyển tiếp) | N/A (form chỉnh sửa) | N/A (màn hình điều khoản) | Card hướng dẫn quét repo |
| **Xử lý trạng thái lỗi** | Card báo lỗi mạng + nút thử lại | SnackBar đỏ nhạt bo 12dp | Báo lỗi không lưu được quyền | Card báo lỗi URL không hợp lệ |

---

## 2. Cam Kết Nhất Quán Trải Nghiệm Lô 4

1. **Chuẩn riêng tư Atom bất biến (ADR-0010)**: Trạng thái hồ sơ luôn mặc định riêng tư `isPrivate: true` trên `S-10-EDIT-PROFILE`. Không tự ý đổi hoặc hạ mức bảo mật.
2. **Minh bạch bằng chứng kỹ năng**: Trên `S-13-REPO-EVIDENCE`, cấp độ tin cậy được thể hiện trung thực: `VERIFIED` ("Đã xác thực"), `EVIDENCE_BASED` ("Có hoạt động mã nguồn đáng kể"), `SELF_CLAIMED` ("Tự khai"). Tuyệt đối không dùng từ "thành thạo" hay hiển thị như chứng chỉ nhằm tránh vi phạm quy tắc dark pattern.
3. **Quyền riêng tư minh bạch**: `S-12-ANALYSIS-CONSENT` phân định rõ ràng giữa dữ liệu được phép đọc và dữ liệu cấm đọc bằng màu sắc ngữ nghĩa trực quan; nút "Để sau" dễ bấm, không giấu nút hủy.
4. **Ngôn ngữ Executive Minimalist**: Toàn bộ các thẻ đều bo 16dp, viền mảnh 1px `#E2E8F0`, nền trắng tuyết trên nền Slate 50 `#F8FAFC`, đảm bảo đồng bộ 100% với toàn bộ ứng dụng.

