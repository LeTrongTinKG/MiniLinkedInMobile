# ui_kit — lớp bọc giao diện dùng chung

## Mục đích

Gói các widget giao diện (nút, ô nhập, thẻ...) vào MỘT thư mục. Màn hình chỉ dùng `AppButton`, `AppCard`... chứ không gọi trực tiếp `shadcn_ui`. Sau này đổi thư viện giao diện chỉ sửa trong thư mục này.

Ví với React: giống thư mục `components/ui` bọc quanh shadcn/ui hoặc MUI.

- Thư mục ĐỘC LẬP: không import gì từ `features/` hay `core/`, copy sang dự án khác là chạy (cần `shadcn_ui` trong pubspec).
- Màu/độ bo/khoảng cách nằm ở `ui_tokens.dart` (như file theme.js).
- API công khai KHÔNG lộ kiểu của `shadcn_ui`.

## Dùng thế nào

```dart
import 'package:app/ui_kit/ui_kit.dart';   // chỉ cần 1 dòng import
```

| Component | Ví dụ |
|---|---|
| `AppButton` | `AppButton(label: 'Lưu', variant: AppButtonVariant.outline, icon: Icons.save, loading: busy, fullWidth: true, onPressed: save)` |
| `AppIconButton` | `AppIconButton(icon: Icons.share, tooltip: 'Chia sẻ', onPressed: share)` |
| `AppAvatar` | `AppAvatar(imageUrl: user.avatar, name: user.fullName, size: 48)` |
| `AppCard` | `AppCard(title: 'Tiêu đề', child: Text('Nội dung'))` |
| `AppBadge` | `AppBadge('Remote', variant: AppBadgeVariant.outline)` |
| `AppTextField` | `AppTextField(controller: c, placeholder: 'Email', obscureText: false)` |
| `AppTextArea` | `AppTextArea(controller: c, placeholder: 'Viết gì đó...', maxLength: 500)` |
| `showAppConfirmDialog` | `final ok = await showAppConfirmDialog(context, title: 'Xóa?', message: '...', confirmLabel: 'Xóa', destructive: true);` |
| `showAppBottomSheet` | `showAppBottomSheet(context, builder: (_) => MyForm())` |
| `showAppSuccess / showAppError` | `showAppSuccess(context, 'Đã lưu')` |
| `AppDivider` | `const AppDivider()` |
| `AppSkeleton` | `AppSkeleton(width: 120, height: 16)` hoặc `circle: true` |
| `AppEmptyState` | `AppEmptyState(title: 'Chưa có dữ liệu', actionLabel: 'Tải lại', onAction: reload)` |

Lưu ý: component Shad (nút, ô nhập, dialog...) cần gốc app có `ShadApp.custom` (đã gắn ở `main.dart`).

## Gắn vào gốc app

`main.dart` bọc `MaterialApp` bằng `ShadApp.custom(theme: buildAppShadTheme(), appBuilder: ...)`. `MaterialApp` bên trong vẫn dùng `AppTheme.lightTheme` nên màn hình cũ (Material 3) không đổi. Theme shad nằm ở `app_shad_theme.dart`, chỉ có bản sáng.

## Xem thử toàn bộ component

```bash
cd app
flutter run -t lib/ui_kit/gallery_main.dart            # chọn thiết bị
flutter run -d chrome -t lib/ui_kit/gallery_main.dart  # chạy trên web
```

Gallery (`ui_kit_gallery.dart`) KHÔNG gắn vào điều hướng của app.

## Thêm component mới

1. Tạo `app_ten_moi.dart` (snake_case, ≤ 200 dòng, comment tiếng Việt).
2. Màu/bo/khoảng cách lấy từ `UiTokens`, không viết số cứng.
3. Tham số công khai chỉ dùng kiểu của Flutter hoặc enum riêng (`AppXxxVariant`), không dùng kiểu `Shad...`.
4. Thêm `export` vào `ui_kit.dart`, thêm vào gallery và `test/ui_kit_test.dart`.

## Đổi thư viện bên dưới

Chỉ sửa trong `ui_kit/`: thay phần `Shad...` bên trong từng file `app_*.dart` (hoặc dựng bằng Material + `UiTokens`), thay `app_shad_theme.dart` và bỏ `ShadApp.custom` ở `main.dart`. Nơi dùng (`AppButton(...)`) không phải sửa.

## Vì sao pin phiên bản shadcn_ui

API của `shadcn_ui` (0.x) đổi nhiều giữa các bản. Dự án dùng đúng `0.57.3` (không có dấu `^`) vì code đã được kiểm chứng với bản đó.

Cảnh báo: `flutter pub add shadcn_ui` không ghi version thì pub có thể chọn nhầm bản `0.0.0` (bản rỗng). Luôn pin `shadcn_ui: ^0.57.3` hoặc đúng phiên bản đã thử.
