# Kế Hoạch Triển Khai Chi Tiết (04-TICKETS.md)

Lộ trình triển khai giai đoạn D5 theo thứ tự phụ thuộc chặt chẽ, an toàn, có khả năng rollback từng ticket.

---

## 1. Giai Đoạn 1: Nền Tảng Token & Theme (Thứ Tự Phụ Thuộc 1)

### TK-01: Hệ Thống Token & ThemeData Clay Minimalist
- **Mục tiêu**: Bổ sung Design Tokens (Màu Slate/Indigo, Bo góc 12/16/20/28dp, Shadow mềm, Typography) vào `AppColors`, `AppTheme`, và `ThemeExtension`.
- **File tác động**: `lib/core/theme/app_colors.dart`, `lib/core/theme/app_theme.dart`, `lib/core/theme/app_spacing.dart`.
- **Tiêu chí xong**: Khởi tạo đầy đủ tokens mới; không làm gãy giao diện đang có; `flutter analyze` 0 lỗi.
- **Rủi ro & Rollback**: Rủi ro thấp. Rollback bằng `git checkout` 3 file theme.

---

## 2. Giai Đoạn 2: Bộ Thành Phần Dùng Chung UI Kit (Thứ Tự Phụ Thuộc 2)

### TK-02: Bộ Nút & Ô Nhập Liệu Chuẩn Clay
- **Mục tiêu**: Chuẩn hóa `AppButton` (Primary, Outline, Ghost bo 20dp, min 48dp), `AppTextField` bo 12dp có icon & báo lỗi inline, `AppSegmentedTab` bo 24dp.
- **File tác động**: `lib/ui_kit/buttons/`, `lib/ui_kit/inputs/`, `lib/ui_kit/tabs/`.
- **Tiêu chí xong**: Các biến thể trạng thái (normal, pressed, disabled, error) hoạt động mượt; A11y $\ge 48\text{dp}$.
- **Rủi ro & Rollback**: Rủi ro thấp.

### TK-03: Thẻ Thể Hiện Năng Lực & Bằng Chứng
- **Mục tiêu**: Xây dựng `ConfidenceBadge` (3 cấp độ: Đã xác thực, Có hoạt động, Tự khai), `SkillEvidenceChip`, `JobCard`, `PostCard` bo 16dp.
- **File tác động**: `lib/ui_kit/cards/`, `lib/features/skills/presentation/widgets/`.
- **Tiêu chí xong**: Thể hiện trung thực 3 mức độ tin cậy; không dùng từ ngữ phóng đại/chứng chỉ.
- **Rủi ro & Rollback**: Rủi ro trung bình (cần đảm bảo tương thích dữ liệu).

### TK-04: Khung Modal BottomSheet & Empty/Error States
- **Mục tiêu**: Chuẩn hóa `AppBottomSheet` bo trên 24dp kính mờ, `EmptyStateView` có nút điều hướng giải cứu luồng cụt, `ErrorBanner` bo 12dp.
- **File tác động**: `lib/ui_kit/sheets/`, `lib/ui_kit/feedback/`.
- **Tiêu chí xong**: Xóa toàn bộ luồng cụt trạng thái rỗng trên toàn app.
- **Rủi ro & Rollback**: Rủi ro thấp.

---

## 3. Giai Đoạn 3: Khung Điều Hướng Trung Tâm (Thứ Tự Phụ Thuộc 3)

### TK-05: Khung Shell & FloatingDockBar Sinh Viên
- **Mục tiêu**: Tích hợp `FloatingDockBar` bo 28dp kính mờ lơ lửng, nút AI trung tâm, áp dụng `bottomPadding: 88dp` cho `JobList`, `SocialFeed`, `NewsPage`.
- **File tác động**: `lib/features/student_home/student_home_screen.dart`, `widgets/student_bottom_bar.dart`, `widgets/floating_dock_bar.dart`.
- **Tiêu chí xong**: Dock hiển thị sang trọng, chuyển tab giữ nguyên vị trí cuộn, nút AI mở đúng `CoachSheet`.
- **Rủi ro & Rollback**: Rủi ro trung bình. Kiểm tra hiệu năng trên máy Android yếu.

---

## 4. Giai Đoạn 4: Ba Màn Thí Điểm (Thứ Tự Phụ Thuộc 4)

### TK-06: Màn S-02 Đăng Nhập & Đăng Ký (Auth)
- **Mục tiêu**: Giao diện đăng nhập/đăng ký Segmented Tab theo mẫu 21st.dev Premium Auth, ô nhập bo 12dp, SSO buttons.
- **File tác động**: `lib/features/auth/presentation/screens/login_screen.dart`, `register_screen.dart`.
- **Tiêu chí xong**: Đăng nhập/đăng ký thành công với `AuthProvider` hiện có; validation inline rõ ràng.
- **Rủi ro & Rollback**: Rủi ro trung bình. Rollback bằng git checkout branch auth.

### TK-07: Màn S-09 Hồ Sơ & S-11 Kỹ Năng Bằng Chứng
- **Mục tiêu**: Giao diện hồ sơ Executive Minimalist, thẻ kỹ năng phân hạng 3 cấp độ, card quét GitHub repo thay CV.
- **File tác động**: `lib/features/profile/profile_page.dart`, `lib/features/skills/presentation/screens/skills_screen.dart`.
- **Tiêu chí xong**: Hiển thị đúng dữ liệu từ `CvProvider` và `SkillsViewModel`.
- **Rủi ro & Rollback**: Rủi ro trung bình.

---

## 5. Giai Đoạn 5: Các Lô Màn Hình Còn Lại (Thứ Tự Phụ Thuộc 5)

### TK-08: Nghiệp Vụ Việc Làm & Tuyển Dụng (Lô 2: S-05, M-02, M-03, S-14, S-15)
- **Mục tiêu**: Danh sách việc làm responsive, modal chi tiết công việc, bộ lọc cấu trúc 2 cột Clay, quản lý đơn ứng tuyển, recruiter home.
- **File tác động**: `lib/features/jobs/`, `lib/features/applications/`, `lib/features/recruiter_home/`.
- **Tiêu chí xong**: Nộp đơn mượt mà, lọc công việc chuẩn xác.

### TK-09: Mạng Xã Hội, Tin Tức & Chatbot AI (Lô 3: S-06, S-07, S-08, M-01)
- **Mục tiêu**: Bảng tin mạng xã hội, 6 cảm xúc reaction, tạo bài viết, tin công nghệ 2 cột, Trợ lý kỹ năng AI chuẩn 21st.dev `ChatSuggestions`.
- **File tác động**: `lib/features/social/`, `lib/features/news/`, `lib/features/coach/`.
- **Tiêu chí xong**: Đăng bài mượt, gợi ý câu hỏi thông minh 21st.dev gửi nhận câu trả lời AI chính xác.

### TK-10: Hồ Sơ Mở Rộng & Bằng Chứng AI (Lô 4: S-01, S-10, S-12, S-13)
- **Mục tiêu**: Splash screen khởi động, sửa hồ sơ bảo vệ riêng tư `isPrivate: true`, xin phép phân tích Atom, quét repo GitHub.
- **File tác động**: `lib/features/auth/presentation/screens/splash_screen.dart`, `lib/features/profile/edit_profile_page.dart`, `lib/features/consent/`, `lib/features/skills/presentation/screens/repo_upload_screen.dart`.
- **Tiêu chí xong**: Giữ nguyên cam kết pháp lý và cổng đồng ý trước khi quét repo.

---

## 6. Giai Đoạn 6: Dọn Dẹp Mã Cứng & Nghiệm Thu Tổng Thể (Thứ Tự Phụ Thuộc 6)

### TK-11: Quét Dọn Giá Trị Cứng & Regression Test Toàn Diện
- **Mục tiêu**: Rà soát thay thế toàn bộ màu cứng, padding cứng bằng tokens; chạy toàn bộ test unit/widget; kiểm thử responsive & cỡ chữ lớn (1.3x - 2.0x).
- **File tác động**: Toàn bộ codebase `lib/`.
- **Tiêu chí xong**: `flutter analyze` 0 warning/error; 100% tests PASS; đạt checklist `05-ACCEPTANCE.md`.

