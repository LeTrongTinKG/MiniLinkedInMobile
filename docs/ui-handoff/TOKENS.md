# Tokens, Hệ Thống Theme & Các Giá Trị Hardcode (TOKENS.md)

## 1. Thiết Kế Hệ Thống Tokens (Design System Tokens)

### A. Bảng Màu Chuẩn (Color Palette)
Được định nghĩa tại `core/theme/app_colors.dart:6-33` và `ui_kit/ui_tokens.dart:6-25`:
- **Primary (Chủ đạo)**: `#2952CC` (`AppColors.primary` / `UiTokens.primary`) - Màu xanh thương hiệu MiniLinkedIn.
- **Primary Container**: `#EBF0FF` (`AppColors.primaryContainer`) - Nền nhạt cho badge, highlight, banner.
- **On Primary Container**: `#193CB8` (`AppColors.onPrimaryContainer`) - Chữ/Icon tương phản trên nền nhạt.
- **Surface (Bề mặt)**: `#FFFFFF` (`AppColors.surface` / `UiTokens.surface`) - Nền card, bottom bar, app bar.
- **Background (Nền app)**: `#F7F9FC` (`AppColors.background` / `UiTokens.background`) - Nền toàn màn hình.
- **Muted (Vùng làm mờ)**: `#F1F5F9` (`UiTokens.muted`) - Nền nút phụ, input hover.
- **Border / Outline**: `#E2E8F0` (`AppColors.border` / `UiTokens.border`) - Viền card, input, separator.
- **Text Primary**: `#0F172A` (`AppColors.textPrimary` / `UiTokens.foreground`) - Tiêu đề, chữ chính (Slate 900).
- **Text Secondary / Muted**: `#64748B` (`AppColors.textMuted` / `UiTokens.mutedForeground`) - Chữ phụ, caption (Slate 500).
- **Destructive / Error**: `#EF4444` (`AppColors.error` / `UiTokens.destructive`) - Nút xóa, trạng thái lỗi.
- **Success / Salary**: `#10B981` (`AppColors.salary` / `AppColors.success`) - Mức lương, xác thực thành công.
- **Warning**: `#F59E0B` (`AppColors.warning`) - Cảnh báo hạn mức, dữ liệu chờ duyệt.

### B. Typography & Font Family
- **Font gia đình**: `Be Vietnam Pro` (thông qua `GoogleFonts.beVietnamProTextTheme()` tại `core/theme/app_theme.dart:23`).
- **Phân cấp kiểu chữ**:
  - `Display Large`: 32sp, SemiBold (`w600`), line-height 1.25.
  - `Title Medium`: 18sp, SemiBold (`w600`) cho AppBar & Card Title (`app_theme.dart:54`).
  - `Body Large`: 16sp, Regular (`w400`), màu `#0F172A`.
  - `Body Medium`: 14sp, Regular (`w400`), màu `#0F172A`.
  - `Body Small / Caption`: 12sp, Regular (`w400`), màu `#64748B`.

### C. Khoảng Cách & Bo Góc (Spacing & Border Radius)
Định nghĩa tập trung tại `core/theme/app_spacing.dart:5-30`:
- **Khoảng cách (Spacing)**:
  - `spaceTiny`: 4.0 dp
  - `spaceSmall`: 8.0 dp
  - `spaceMedium`: 16.0 dp
  - `spaceLarge`: 24.0 dp
  - `spaceXLarge`: 32.0 dp
- **Bo góc (Border Radius)**:
  - `radiusChip`: 8.0 dp (Dùng cho Badge, Tag)
  - `radiusInput` & `radiusButton`: 12.0 dp (`UiTokens.radius`)
  - `radiusCard`: 16.0 dp (Dùng cho Thẻ việc làm, Thẻ bài viết)
  - `radiusLarge`: 24.0 dp (Dùng cho BottomSheet bo góc trên)
- **Đổ bóng (Elevations / Shadows)**:
  - Thiết kế phẳng hiện đại (Flat / Subtle border): Card `elevation: 0`, đường viền `BorderSide(color: AppColors.border, width: 1)` (`app_theme.dart:59-65`).

### D. Chế độ Giao diện (Theme Mode)
- Hiện tại hệ thống **CHỈ HỖ TRỢ CHẾ ĐỘ SÁNG (Light Mode)**: `Brightness.light` (`ui_kit/app_shad_theme.dart:11`, `core/theme/app_theme.dart:26`). Không có Dark Mode token.

---

## 2. Danh Sách Giá Trị Hardcode Rải Rác Ngoài Theme (Hardcoded Audit)

Agent dựng lại UI cần thay thế toàn bộ các giá trị tự định nghĩa sau bằng token chuẩn:

| Vị trí (File:Dòng) | Giá trị bị viết cứng | Ý nghĩa thực tế | Đề xuất thay thế bằng Token |
|---|---|---|---|
| `features/auth/.../splash_screen.dart:17` | `Color(0xFF0A66C2)` | Màu xanh cũ LinkedIn | `AppColors.primary` (`#2952CC`) |
| `features/auth/.../splash_screen.dart:108`| `Color(0xFF1A1A1A)` | Màu đen tiêu đề | `AppColors.textPrimary` |
| `features/auth/.../splash_screen.dart:129`| `Color(0xFF666666)` | Màu xám báo lỗi | `AppColors.textMuted` |
| `features/profile/profile_page.dart:124` | `Color(0xFFCFDAF7)` | Nền Avatar mặc định | `AppColors.primaryContainer` |
| `features/profile/edit_profile_page.dart:45`| `Color(0xFFF0FDF4)` | Nền xanh lá nhạt hộp riêng tư | `AppColors.surface` hoặc Success Container |
| `features/profile/edit_profile_page.dart:47`| `Color(0xFF86EFAC)` | Viền xanh lá hộp riêng tư | `AppColors.success.withOpacity(0.3)` |
| `features/jobs/.../job_list_screen.dart:42`| `max-width: 1200` | Giới hạn khung web | `AppSpacing.maxContentWidth = 1200.0` |
| `features/jobs/.../job_list_screen.dart:65`| `EdgeInsets.all(12)` | Padding lưới việc làm | `EdgeInsets.all(AppSpacing.spaceSmall + 4)` |
| `features/social/.../social_feed_screen.dart:88`| `SizedBox(height: 10)` | Giãn cách bài viết | `SizedBox(height: AppSpacing.spaceSmall)` |
| `features/auth/.../login_screen.dart:72` | `EdgeInsets.all(24)` | Padding màn hình auth | `EdgeInsets.all(AppSpacing.spaceLarge)` |
| `features/social/.../post_card.dart:34` | `BorderRadius.circular(12)` | Bo góc card bài viết | `BorderRadius.circular(AppSpacing.radiusCard)` |
| `features/coach/.../coach_sheet.dart:110`| `Colors.amber.shade100` | Cảnh báo hết câu hỏi | `AppColors.warning.withOpacity(0.2)` |
| `features/profile/profile_page.dart:89` | `fontSize: 22, fontWeight: bold` | Tên user tiêu đề | `Theme.of(context).textTheme.titleLarge` |

