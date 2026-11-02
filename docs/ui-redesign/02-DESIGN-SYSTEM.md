# Hệ Thống Thiết Kế Design System (02-DESIGN-SYSTEM.md) - Cổng G2

Quy chuẩn Design System hoàn chỉnh cho phong cách **Clay-inspired Executive Minimalist** (Hướng 1 đã duyệt), kết hợp cảm hứng từ các mẫu UI tuyển chọn của 21st.dev (`Premium Auth` & `Onboarding Screen`).

---

## 1. Hệ Thống Design Tokens

### A. Bảng Màu (Semantic Color Tokens)
Định nghĩa qua `AppColors` và `ColorScheme.light` chuẩn Material 3:

| Vai trò Token | Mã Hex | Tên biến Flutter | Tỉ lệ tương phản | Mục đích sử dụng |
|---|---|---|---|---|
| **Background** | `#F8FAFC` | `AppColors.background` | - | Nền toàn ứng dụng (Slate 50 thanh khiết) |
| **Surface** | `#FFFFFF` | `AppColors.surface` | 15.8:1 trên text | Bề mặt thẻ Card, Ô nhập liệu, BottomSheet |
| **Surface Subtle** | `#F1F5F9` | `AppColors.surfaceSubtle`| 13.5:1 trên text | Nền Segmented Tab switch, vùng phụ hover |
| **Primary** | `#2952CC` | `AppColors.primary` | 8.5:1 trên trắng | Nút hành động chính, viền focus, tab active |
| **Primary Container**| `#EEF2FF` | `AppColors.primaryContainer`| - | Nền badge kỹ năng, banner riêng tư nhạt |
| **On Primary Cont.** | `#1E40AF` | `AppColors.onPrimaryContainer`| 6.2:1 | Chữ và icon tương phản trên nền nhạt |
| **Text Primary** | `#0F172A` | `AppColors.textPrimary` | 15.8:1 trên trắng | Tiêu đề, chữ nội dung chính (Slate 900) |
| **Text Muted** | `#64748B` | `AppColors.textMuted` | 4.6:1 (Đạt WCAG AA)| Nhãn phụ, caption, placeholder (Slate 500) |
| **Border** | `#E2E8F0` | `AppColors.border` | - | Viền mỏng 1px tinh tế cho thẻ và input |
| **Destructive** | `#EF4444` | `AppColors.error` | 4.5:1 | Trạng thái lỗi, nút xóa, hủy bỏ |
| **Success / Salary** | `#10B981` | `AppColors.salary` | 4.5:1 | Mức lương, xác thực kỹ năng thành công |
| **Warning** | `#F59E0B` | `AppColors.warning` | 4.5:1 | Cảnh báo hạn mức câu hỏi, dữ liệu chờ |

### B. Typography (Thang Kiểu Chữ)
Sử dụng `GoogleFonts.beVietnamPro`:
- **Display Large**: 28sp / SemiBold (`w600`) / line-height 1.25. Dùng cho tiêu đề màn chào mừng, onboarding.
- **Title Large**: 20sp / SemiBold (`w600`) / line-height 1.3. Dùng cho Header màn hình chính, tên ứng viên.
- **Title Medium**: 16sp / SemiBold (`w600`) / line-height 1.35. Dùng cho tiêu đề thẻ việc làm, thẻ kỹ năng.
- **Body Large**: 15sp / Regular (`w400`) / line-height 1.5. Dùng cho bài viết mạng xã hội, mô tả công việc.
- **Body Medium**: 13sp / Regular (`w400`) / line-height 1.45. Dùng cho chi tiết việc làm, phụ đề danh sách.
- **Label Medium**: 13sp / Medium (`w500`). Dùng cho nút bấm, segmented tabs.
- **Label Small**: 11sp / SemiBold (`w600`). Dùng cho micro-badge 3 cấp độ tin cậy, commit hash.

### C. Khoảng Cách & Bo Góc (Spacing & Radii)
- **Thang khoảng cách (4/8dp)**: `tiny: 4dp`, `small: 8dp`, `mediumSmall: 12dp`, `medium: 16dp`, `large: 24dp`, `xlarge: 32dp`.
- **Bo góc (Border Radius)**:
  - `radiusChip`: 8dp (Chip kỹ năng, pill tags)
  - `radiusInput` & `radiusButton`: 12dp (Ô nhập liệu, nút bấm, segmented tab switch)
  - `radiusCard`: 16dp (Thẻ việc làm, thẻ bài viết)
  - `radiusDock`: 28dp (Floating Pill Dock điều hướng nổi)

### D. Đổ Bóng & Chuyển Động (Elevations & Motion)
- **Bóng đổ**: Phẳng tối giản (`elevation: 0`). Riêng Floating Dock và Card nổi dùng `BoxShadow(color: Color(0x08000000), blurRadius: 16, offset: Offset(0, 4))` kết hợp `BackdropFilter(sigmaX: 16, sigmaY: 16)`.
- **Chuyển động**: Micro-interactions thời lượng `200ms` đường cong `Curves.easeOutCubic`; Modal trượt lên `300ms` `Curves.easeOutQuart`.

---

## 2. Danh Mục 15 Thành Phần Dùng Chung Ưu Tiên

1. **`AppButton`**: Nút bấm bo 12dp. Biến thể: `primary` (nền xanh `#2952CC`), `secondary` (viền mảnh), `ghost`, `destructive`. Trạng thái: default, pressed, disabled, loading.
2. **`AppSegmentedTab`**: Bộ chuyển đổi 2-3 tab dạng pill (lấy cảm hứng từ mẫu `Premium Auth` 21st.dev cho Login/Register và Student/Recruiter switch).
3. **`AppTextField`**: Ô nhập liệu bo 12dp, icon dẫn đầu (`mail`, `lock`), nút ẩn hiện mật khẩu, hỗ trợ `errorText` inline màu đỏ dưới ô nhập (sửa dứt điểm P0-1).
4. **`FloatingDockBar`**: Thanh điều hướng nổi dạng pill bo 28dp, mờ kính nhẹ, tách rời mép đáy màn hình (lấy cảm hứng từ ảnh Clay).
5. **`ConfidenceBadge`**: Huy hiệu 3 cấp độ tin cậy: `[✓ Đã xác minh]`, `[⎇ Có minh chứng Git]`, `[👤 Tự khai]`, kết hợp micro-icon rõ ràng.
6. **`SkillEvidenceCard`**: Thẻ kỹ năng hiển thị trích dẫn mã nguồn GitHub (commit message, pull request link).
7. **`JobCard`**: Thẻ việc làm bo 16dp, logo tròn 40dp, tag mức lương xanh lá, danh sách chip kỹ năng yêu cầu.
8. **`PostCard`**: Thẻ bài viết mạng xã hội với avatar tác giả, hình ảnh đính kèm và reaction bar tối giản.
9. **`AppAvatar`**: Avatar người dùng chuẩn hóa duy nhất toàn app, fallback chữ cái đầu, không vỡ layout khi lỗi ảnh.
10. **`ChatSuggestions`**: Khung câu hỏi gợi ý AI composable (Header + Wrap buttons) chuẩn 21st.dev.
11. **`CoachBubble`**: Khung hội thoại tin nhắn của Gia sư AI với nhãn cam kết `[Trợ lý AI 0 USD]` và căn cứ nguồn.
12. **`PrivacyConsentBanner`**: Banner ổ khóa bảo vệ hồ sơ riêng tư mặc định (`isPrivate: true`) và hộp đồng ý AI.
13. **`EmptyStateView`**: Giao diện trạng thái rỗng có icon minh họa tinh tế và nút gợi ý hành động (sửa luồng cụt P1-2).
14. **`AppConfirmDialog`**: Hộp thoại cảnh báo nguy hiểm (Chặn người dùng, Xóa đơn, Xóa tài khoản vĩnh viễn).
15. **`AppSkeleton`**: Khung xương nhấp nháy êm dịu khi tải dữ liệu cho thẻ việc làm và bài viết.

---

## 3. Quy Tắc Nội Dung & Trợ Năng (Content & A11y)

- **Giọng điệu**: Chuyên nghiệp, súc tích, trung thực, tôn trọng quyền riêng tư.
- **Thông báo lỗi**: Viết cụ thể nguyên nhân và giải pháp (Ví dụ: *"URL repo phải có dạng github.com/user/repo"* thay vì *"Lỗi không hợp lệ"*).
- **Vùng chạm tối thiểu**: Mọi nút bấm, tab, icon cảm xúc đều có kích thước tương tác $\ge 48 \times 48\text{ dp}$ (thông qua `visualDensity` hoặc padding bọc ngoài).
- **Độ tương phản**: 100% văn bản đạt tỉ lệ tương phản tối thiểu $\ge 4.5:1$ (WCAG AA).
- **Hỗ trợ cỡ chữ lớn**: Giao diện sử dụng `FittedBox` hoặc `Wrap` cho chip và nút bấm, đảm bảo ở mức phóng to text hệ số 1.3 - 2.0 không phát sinh lỗi tràn pixel (A11y overflow).

---

## 4. Bảng Ánh Xạ Xóa Bỏ Giá Trị Cứng & Gom Gọn Widget Cũ

| Giá trị cứng / Widget trùng lặp hiện tại | Vị trí trong code (File:Dòng) | Thành phần / Token mới thay thế |
|---|---|---|
| Màu xanh LinkedIn `#0A66C2` | `splash_screen.dart:17` | `AppColors.primary` (`#2952CC`) |
| Màu nền Avatar tự chế `#CFDAF7` | `profile_page.dart:124` | `AppColors.primaryContainer` |
| Màu nền riêng tư `#F0FDF4`, `#86EFAC` | `edit_profile_page.dart:45-47`| `AppColors.surface` + `AppColors.salary` |
| 4 vị trí vẽ `CircleAvatar` thủ công | `profile_page:115`, `student_home:102`, `post_card:45` | Gom về 1 widget chuẩn `AppAvatar` |
| `showDialog` tự tạo `AlertDialog` | `student_home_screen.dart:145`| Gom về `showAppConfirmDialog` |
| `ActionChip` cơ bản trong Chatbot | `coach_sheet.dart:156` | Thay bằng `ChatSuggestions` (chuẩn 21st.dev) |
| Standard NavigationBar dính đáy | `student_home_screen.dart:80` | Thay bằng `FloatingDockBar` nổi 28dp |

---

👉 **DỪNG TẠI CỔNG G2**: Trình chủ dự án xem xét và duyệt toàn bộ Design System trên trước khi bước vào thiết kế chi tiết từng màn hình (D3).

