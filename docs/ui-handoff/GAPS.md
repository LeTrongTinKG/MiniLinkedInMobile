# Khiếm Khuyết UX, Yêu Cầu Dữ Liệu & Lộ Trình Tái Dựng (GAPS.md)

## 1. Đánh Giá Khiếm Khuyết UX Từ Mã Nguồn (Code-level UX Gaps)

> [!NOTE]
> Toàn bộ các điểm dưới đây được phát hiện trực tiếp từ phân tích luồng code, không phỏng đoán cảm tính thị giác.

### Mức P0: Ảnh hưởng trực tiếp đến trải nghiệm và tính toàn vẹn dữ liệu
- **P0-1: Kiểm tra hợp lệ (Form Validation) không nhất quán giữa các màn**:
  - `features/auth/presentation/screens/login_screen.dart:45-65`: Dùng `Form` + `validator` chuẩn của Flutter.
  - `features/profile/edit_profile_page.dart:58-75` & `features/skills/.../repo_upload_screen.dart:40-62`: Không dùng `FormKey`, việc kiểm tra hợp lệ được đẩy hoàn toàn vào ViewModel. Khi người dùng nhập sai (ví dụ URL repo sai định dạng), giao diện chỉ hiện SnackBar chung chung thay vì thông báo lỗi đỏ trực tiếp dưới ô nhập liệu (`AppTextField.errorText`).
- **P0-2: Đứt gãy đa ngôn ngữ (Localization Fracture)**:
  - Khi người dùng bấm `LanguageSwitchButton` chuyển sang Tiếng Anh, các màn hình S-05 (Việc làm), S-06 (Mạng xã hội), S-08 (Tin tức) vẫn hiển thị 100% tiếng Việt do bị hardcode chuỗi trong `job_list_screen.dart:55-80` và `social_feed_screen.dart:70-95`.

### Mức P1: Ảnh hưởng đến tính thẩm mỹ và tính nhất quán Design System
- **P1-1: Giá trị màu sắc & khoảng cách viết cứng rải rác**:
  - `splash_screen.dart:17` dùng màu xanh LinkedIn cũ `#0A66C2` lệch tông với `#2952CC` của toàn app.
  - `profile_page.dart:124` tự định nghĩa màu nền Avatar `#CFDAF7` thay vì gọi token `AppColors.primaryContainer`.
  - `edit_profile_page.dart:45-47` dùng màu cứng `#F0FDF4` và `#86EFAC` cho hộp riêng tư.
- **P1-2: Trạng thái màn hình rỗng (Empty States) sơ sài, thiếu điều hướng khắc phục**:
  - `features/news/presentation/screens/news_page.dart:90-98`: Khi không có tin tức chỉ hiện 1 dòng chữ "Không có tin tức", không có nút "Tải lại" hoặc hình minh họa.
  - `features/applications/applications_page.dart:45-55`: Khi chưa ứng tuyển chỉ hiện danh sách trống, không có nút "Khám phá việc làm ngay" để dẫn người dùng quay lại tab Jobs (luồng cụt).

### Mức P2: Trợ năng & Khả năng đáp ứng thiết bị
- **P2-1: Vùng chạm (Touch Target) dưới chuẩn 48x48dp**:
  - Các icon cảm xúc tại `features/social/.../reaction_bar.dart:40-60` có kích thước 24dp và padding chỉ 4dp, gây khó khăn cho thao tác ngón tay trên màn hình nhỏ.
- **P2-2: Thiếu responsive khi xoay ngang thiết bị**:
  - Ngoại trừ `job_list_screen.dart:40-42` có chia cột theo bề rộng, toàn bộ các màn hình còn lại (`Profile`, `Login`, `Social`) đều cố định layout 1 cột cho mobile dọc, chưa tối ưu khi dùng trên tablet hoặc chế độ chia đôi màn hình iPad/Web.

---

## 2. Danh Sách Ảnh Chụp Màn Hình Cần Chủ Dự Án Bổ Sung

Để agent ngoài tái dựng giao diện chuẩn xác nhất, chủ dự án cần cung cấp bộ ảnh chụp thực tế cho các trạng thái sau (Gợi ý chụp trên iPhone 15 Pro hoặc Chrome 1200x800, Chế độ sáng):

| STT | Màn hình | Các trạng thái cần ảnh chụp chi tiết |
|---|---|---|
| 1 | S-01 Splash | Màn hình logo lúc khởi động & Trạng thái mất mạng có nút "Thử lại". |
| 2 | S-02 & S-03 Auth | Form đăng nhập chuẩn, Trạng thái nhập sai mật khẩu, Trạng thái loading bấm nút SSO. |
| 3 | S-04 Student Home | Thanh điều hướng 3 tab bên dưới, Menu Drawer trượt từ mép trái ra. |
| 4 | S-05 Job List | Lưới thẻ việc làm có dữ liệu, Trạng thái shimmer loading, Modal chi tiết công việc. |
| 5 | S-06 Social Feed | Dòng bài viết có ảnh, Hộp chọn 6 biểu cảm (tym/like), Modal bình luận. |
| 6 | S-09 & S-10 Profile | Xem hồ sơ có huy hiệu kỹ năng, Giao diện chuyển cờ ngôn ngữ, Màn hình chỉnh sửa hồ sơ. |
| 7 | S-11 & S-13 Skills & Repo | Danh sách kỹ năng 3 cấp độ tin cậy, Màn hình nhập link GitHub Repo để quét. |
| 8 | S-12 AI Consent | Màn hình điều khoản minh bạch dữ liệu AI (đọc gì vs không đọc gì). |
| 9 | M-01 Coach Bot | Giao diện hội thoại hỏi đáp với bot gia sư, Cảnh báo khi chạm mốc 10 câu/ngày. |

---

## 3. Câu Hỏi Chủ Dự Án (PO) Cần Quyết Định
1. **Phong cách giao diện chủ đạo**: Giữ phong cách LinkedIn truyền thống hay chuyển hướng hoàn toàn sang phong cách hiện đại Minimalist / Slate (theo shadcn UI tokens)?
2. **Hỗ trợ Dark Mode**: Có kế hoạch triển khai chế độ nền tối (Dark Theme) ngay trong đợt bàn giao này hay tiếp tục giữ Light-only?
3. **Cải tiến luồng điều hướng**: Có cho phép tách trang Hồ sơ cá nhân thành một Tab riêng trên Bottom Navigation Bar (thay vì giấu trong Drawer) để tăng tính tiếp cận hay không?

---

## 4. Đề Xuất Thứ Tự Tái Dựng Giao Diện (Implementation Roadmap)
Agent bên ngoài nên dựng lại giao diện theo chuỗi phụ thuộc từ gốc đến ngọn:
1. **Giai đoạn 1 - Nền tảng**: Khởi tạo Theme, Color Tokens, Typography (`AppTheme`, `AppColors`, `AppSpacing`).
2. **Giai đoạn 2 - Thành phần cốt lõi**: Chuẩn hóa UI Kit (`AppButton`, `AppTextField`, `AppAvatar`, `AppSkeleton`, `ConfidenceBadge`, `LanguageSwitchButton`).
3. **Giai đoạn 3 - Bộ khung điều hướng**: Dựng App Shell, `MaterialApp` router, Navigation Bar và Drawer.
4. **Giai đoạn 4 - Màn hình độc lập (ít phụ thuộc)**: `SplashScreen`, `LoginScreen`, `RegisterScreen`, `AnalysisConsentScreen`.
5. **Giai đoạn 5 - Màn hình nghiệp vụ chính**: `StudentHomeScreen`, `JobListScreen`, `ProfilePage`, `EditProfilePage`, `SkillsScreen`, `RepoUploadScreen`.
6. **Giai đoạn 6 - Màn hình phức tạp / Hoãn lại**: `SocialFeedScreen`, `CoachSheet` (hoàn thiện sau khi backend chốt API hạn mức).

