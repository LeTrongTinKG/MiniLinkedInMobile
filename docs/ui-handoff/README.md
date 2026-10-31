# MiniLinkedIn Mobile - Tài liệu bàn giao giao diện (UI Handoff)

Tài liệu kỹ thuật tổng hợp toàn bộ kiến trúc giao diện, màn hình, thành phần dùng chung, tokens, bản sao chuỗi và các ràng buộc từ mã nguồn thực tế của MiniLinkedInMobile để bàn giao cho agent bên ngoài dựng lại UI.

## 1. Thông số công nghệ & Nền tảng
- **Framework & Ngôn ngữ**: Flutter SDK 3.47.7, Dart 3.13.5 (`app/pubspec.yaml:7-9`).
- **Nền tảng mục tiêu**: Mobile (iOS, Android) và Web responsive (hỗ trợ layout 1-3 cột, max-width 1200px, `app/lib/features/jobs/presentation/screens/job_list_screen.dart:40-42`).
- **Kiến trúc phân lớp**: Clean Architecture kết hợp chuẩn MVVM tách biệt: `presentation/screens` (UI) -> `presentation/viewmodels` (ChangeNotifier) -> `domain/usecases` (hoặc Repositories) -> `data/datasources` (`app/lib/core/di/app_providers.dart:29-67`).
- **Quản lý trạng thái**: `provider: ^6.1.5+1` (`app/pubspec.yaml:26`) với `ChangeNotifier` ViewModel riêng biệt cho từng màn hình (`app/lib/core/di/app_providers.dart:55-66`).
- **Điều hướng**: Declarative named routes trong `MaterialApp` kết hợp `GoRouter` 18.1.2 (`app/lib/main.dart:178-188`, `app/lib/core/router/app_router.dart:1-50`).
- **Đa ngôn ngữ**: Hỗ trợ 2 ngôn ngữ Việt / Anh runtime tức thì qua ARB, 100% không hardcode chuỗi màn mới (`app/lib/core/localization/locale_view_model.dart:6-35`, `app/lib/l10n/app_vi.arb`, `app/lib/l10n/app_en.arb`).
- **Quy mô giao diện**: 15 màn hình độc lập và 6 modal bottom sheets tương tác (`app/lib/main.dart:178-188`).

## 2. Mục lục bộ hồ sơ bàn giao UI (`docs/ui-handoff/`)
1. [SCREENS.md](file:///Users/hosynguyen/MiniLinkedInMobile/docs/ui-handoff/SCREENS.md): Bản đồ toàn bộ màn hình, sơ đồ điều hướng Mermaid, chi tiết 12 tiêu chí cho từng màn hình có code thật.
2. [COMPONENTS.md](file:///Users/hosynguyen/MiniLinkedInMobile/docs/ui-handoff/COMPONENTS.md): Danh mục widget dùng chung, UI kit (shadcn_ui wrapper) và các widget trùng lặp cần gom gọn.
3. [TOKENS.md](file:///Users/hosynguyen/MiniLinkedInMobile/docs/ui-handoff/TOKENS.md): Bảng màu, typography, spacing, radius, shadow, font Be Vietnam Pro và danh sách giá trị hardcode rải rác.
4. [COPY.md](file:///Users/hosynguyen/MiniLinkedInMobile/docs/ui-handoff/COPY.md): Bản đồ chuỗi l10n theo màn hình, các chuỗi hardcode và nhóm chuỗi có tính cam kết bảo vệ dữ liệu/pháp lý.
5. [CONSTRAINTS.md](file:///Users/hosynguyen/MiniLinkedInMobile/docs/ui-handoff/CONSTRAINTS.md): Hợp đồng ViewModel công khai, bất biến phải giữ nguyên, hard rules dự án và danh mục dependency UI.
6. [GAPS.md](file:///Users/hosynguyen/MiniLinkedInMobile/docs/ui-handoff/GAPS.md): Đánh giá khiếm khuyết UX từ code (P0-P2), danh sách ảnh chụp cần bổ sung, câu hỏi cho PO và thứ tự dựng lại.

