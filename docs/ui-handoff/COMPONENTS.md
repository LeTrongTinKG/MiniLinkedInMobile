# Danh mục Widget Dùng Chung & Tái Cấu Trúc (COMPONENTS.md)

## 1. Danh mục Thành phần Dùng Chung (Shared Widgets & UI Kit)

| Tên Widget | File mã nguồn | Tham số chính | Màn hình sử dụng |
|---|---|---|---|
| `AppButton` | `ui_kit/app_button.dart:18` | `label`, `onPressed`, `variant`, `isLoading`, `icon` | S-02, S-03, S-10, S-12, S-13 |
| `AppTextField` | `ui_kit/app_text_field.dart:10` | `label`, `controller`, `hintText`, `errorText`, `obscureText` | S-02, S-03, S-10, S-13 |
| `AppAvatar` | `ui_kit/app_avatar.dart:9` | `imageUrl`, `name`, `size`, `fallbackColor` | S-04 (Drawer), S-06, S-09 |
| `AppSkeleton` | `ui_kit/app_skeleton.dart:10` | `width`, `height`, `borderRadius` | S-05 (Jobs), S-06 (Social), S-08 (News) |
| `AppBottomSheet` | `ui_kit/app_bottom_sheet.dart:10` | `title`, `child` | M-02 (JobDetail), M-03 (JobFilter) |
| `AppConfirmDialog` | `ui_kit/app_confirm_dialog.dart:10` | `title`, `message`, `confirmText`, `cancelText` | Logout, Delete CV, Xóa bài |
| `ConfidenceBadge` | `features/skills/.../confidence_badge.dart:10` | `level` (`verified`, `evidence`, `self_claimed`), `compact` | S-09 (Profile), S-11 (Skills) |
| `LanguageSwitchButton` | `core/localization/language_switch_button.dart:8`| `key`, `compact` | S-09 (AppBar Profile), S-10 |
| `JobCard` | `features/jobs/.../job_card.dart:12` | `job`, `onTap`, `onApply` | S-05 (Job List) |
| `JobBadge` | `features/jobs/.../job_badge.dart:8` | `label`, `color`, `backgroundColor` | S-05, M-02 (Job Detail) |
| `PostCard` | `features/social/.../post_card.dart:18` | `post`, `onLike`, `onComment`, `onShare` | S-06 (Social Feed) |
| `ReactionBar` | `features/social/.../reaction_bar.dart:15` | `reactions`, `userReaction`, `onReact` (6 loại tym/like)| S-06 (Feed), M-05 (Reactors) |
| `CommentBar` | `features/social/.../comment_bar.dart:12` | `commentCount`, `onOpenComments` | S-06, M-04 (CommentsSheet) |
| `CoachSheet` | `features/coach/.../coach_sheet.dart:25` | `CoachProvider`, `dailyLimit = 10` | S-04 (Màn chính) |

## 2. Các Widget Trùng Lặp Cần Gom Gọn (Duplication Audit)

Dưới đây là các phần tử giao diện đang bị triển khai thủ công lặp lại ở nhiều nơi, agent ngoài cần chuẩn hóa gom về widget chung duy nhất:

### A. Hiển thị Avatar Người dùng (User Avatar)
- **Vấn đề**: Tự tạo `CircleAvatar` thủ công với logic fallback chữ cái đầu và xử lý lỗi ảnh độc lập.
- **Vị trí lặp lại**:
  - `ui_kit/app_avatar.dart:9`: Đã chuẩn hóa cache + fallback không ném exception.
  - `features/profile/profile_page.dart:115-128`: Viết thủ công `CircleAvatar(backgroundColor: Color(0xFFCFDAF7))`.
  - `features/student_home/student_home_screen.dart:102-114`: Viết thủ công `CircleAvatar` trong Navigation Drawer.
  - `features/social/presentation/widgets/post_card.dart:45-56`: Viết thủ công trong header bài viết.
- **Khuyến nghị**: Gom toàn bộ về `AppAvatar(imageUrl: ..., name: ...)`.

### B. Hiệu ứng Khung xương Đang tải (Skeleton / Shimmer Loading)
- **Vấn đề**: Nhiều màn tự viết widget Container xám nhấp nháy hoặc placeholder tĩnh không đồng bộ.
- **Vị trí lặp lại**:
  - `ui_kit/app_skeleton.dart:10`: Component chuẩn của Design System.
  - `features/jobs/presentation/screens/job_list_screen.dart:120-138`: Custom placeholder card.
  - `features/social/presentation/screens/social_feed_screen.dart:95-110`: Custom feed shimmer.
  - `features/news/presentation/screens/news_page.dart:82-94`: Custom news placeholder.
- **Khuyến nghị**: Thống nhất dùng `AppSkeleton` hoặc component `JobCardSkeleton`, `PostCardSkeleton` dựng trên `AppSkeleton`.

### C. Hộp thoại Xác nhận Hành động (Action Confirm Dialogs)
- **Vấn đề**: Dùng trực tiếp `showDialog(builder: (context) => AlertDialog(...))` thay vì gọi `showAppConfirmDialog`.
- **Vị trí lặp lại**:
  - `ui_kit/app_confirm_dialog.dart:10`: Hàm chuẩn `showAppConfirmDialog(context, title, message)`.
  - `features/student_home/student_home_screen.dart:145-162`: Gọi `showDialog` tự tạo `AlertDialog` khi đăng xuất.
  - `features/cv/presentation/providers/cv_provider.dart`: Gọi dialog xóa CV thủ công.
- **Khuyến nghị**: Thay toàn bộ bằng lệnh gọi `await showAppConfirmDialog(...)`.

### D. Nút Chuyển đổi Ngôn ngữ (Language Switcher)
- **Vấn đề**: Xuất hiện rải rác nút bấm chuyển đổi locale với logic tự build giao diện cờ.
- **Vị trí lặp lại**:
  - `core/localization/language_switch_button.dart:8`: Nút chuẩn hỗ trợ A11y, hiển thị cờ 🇻🇳 / 🇬🇧 và toggle `LocaleViewModel`.
  - `features/profile/profile_page.dart:36-48`: Viết nút đổi ngôn ngữ trực tiếp trong AppBar hồ sơ.
- **Khuyến nghị**: Dùng duy nhất `const LanguageSwitchButton()` trên AppBar hoặc Settings.

