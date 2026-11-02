# Quy ước kiến trúc FE — MiniLinkedIn Mobile

## Cấu trúc thư mục

```
lib/
├── core/                        # Hạ tầng dùng chung toàn app
│   ├── config/                  # Biến môi trường, base URL
│   ├── error/                   # Exception classes
│   ├── network/                 # DioClient, interceptor
│   ├── storage/                 # SecureStorage wrapper
│   └── theme/                   # AppTheme, màu sắc, typography
│
├── features/                    # Mỗi feature là 1 folder phẳng
│   ├── auth/                    # ← Feature duy nhất dùng Clean Architecture
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── profile/                 # Feature UI: page + widgets
│   │   ├── cv_item.dart         # Model cục bộ (chưa có API)
│   │   ├── profile_page.dart    # Page chính, giữ state
│   │   └── widgets/             # Components nhỏ của feature
│   │
│   ├── jobs/
│   │   └── jobs_page.dart
│   │
│   ├── applications/
│   │   └── applications_page.dart
│   │
│   ├── student_home/
│   │   └── student_home_screen.dart   # Shell: IndexedStack + BottomNav
│   │
│   └── recruiter_home/
│       └── recruiter_home_screen.dart
│
└── main.dart                    # DI thủ công + route definitions
```

---

## Quy tắc tổ chức folder

### 1. Độ sâu tối đa: 4 cấp
`features/<tên_feature>/widgets/<file>.dart`

Không tạo thêm tầng `presentation/`, `pages/`, `screens/` bên trong feature trừ khi feature đó cần Clean Architecture (như auth).

### 2. Khi nào dùng Clean Architecture (data/domain/presentation)?
Chỉ khi feature có **cả 3**:
- Repository pattern với nhiều data source (remote + local)
- Domain entity tách biệt khỏi API model
- UseCase chứa business logic thực sự

→ Hiện tại chỉ có `auth/`. Các feature mới (jobs, profile, applications) thêm Clean Architecture **khi cần**, không làm trước.

### 3. Khi nào tạo `widgets/`?
Khi page có từ **2 widget tách biệt** trở lên. Không tạo `widgets/` cho page chỉ có 1 widget con.

---

## Quy ước đặt tên file

| Loại | Convention | Ví dụ |
|---|---|---|
| Screen (shell có bottom nav) | `<tên>_screen.dart` | `student_home_screen.dart` |
| Page (1 tab trong screen) | `<tên>_page.dart` | `profile_page.dart` |
| Widget con | `<tên>.dart` | `cv_card.dart`, `profile_header.dart` |
| Model cục bộ (chưa có API) | `<tên>_item.dart` hoặc `<tên>_model.dart` | `cv_item.dart` |
| Provider | `<tên>_provider.dart` | `auth_provider.dart` |

---

## Quy ước component (React-style)

### Screen = Shell
- Chỉ chứa `IndexedStack` + `BottomNavigationBar`
- Không có business logic, không import Provider trực tiếp
- Không có AppBar riêng (mỗi page tự quản lý header)

```dart
// student_home_screen.dart — chỉ làm nhiệm vụ điều hướng
class StudentHomeScreen extends StatefulWidget { ... }
// body: IndexedStack(children: [JobsPage(), ApplicationsPage(), ProfilePage()])
```

### Page = Stateful, giữ state
- Wrap nội dung bằng `SafeArea(bottom: false)`
- Tự render header (Container/Row) thay vì dùng `Scaffold.appBar`
- Là nơi duy nhất gọi `Consumer<XxxProvider>` hoặc `context.watch`
- Giao callback xuống widget con, **không** truyền Provider xuống

```dart
// profile_page.dart
class ProfilePage extends StatefulWidget { ... }
// SafeArea → Column → [_ProfileAppBar, Divider, Expanded(SingleChildScrollView)]
```

### Widget = Stateless, nhận data qua constructor
- Không gọi Provider, không gọi API
- Nhận callback (`VoidCallback`, `void Function(...)`) thay vì tự xử lý logic
- Private widget helper (prefix `_`) đặt cùng file nếu chỉ dùng trong 1 file

```dart
// cv_card.dart — nhận CvItem, onDelete, onSetDefault
class CvCard extends StatelessWidget {
  final CvItem cv;
  final VoidCallback onDelete;
  final VoidCallback? onSetDefault; // null = đang là mặc định
  ...
}
```

---

## State management

- Dùng **Provider** (`ChangeNotifier`) cho state chia sẻ toàn app (auth, sau này: jobs, notifications)
- State cục bộ của 1 page (ví dụ: danh sách CV) dùng `StatefulWidget._setState`
- **Không** dùng `context.read` bên trong `build()` — dùng `Consumer` hoặc `context.watch`

---

## Import

Dùng **absolute import** với prefix `package:app/` cho tất cả:

```dart
// ✅ đúng
import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/profile/cv_item.dart';

// ❌ sai
import '../../core/theme/app_theme.dart';
```

---

## Mock data

Khi feature chưa có API:
- Khai báo `List<XxxItem>` trực tiếp trong `_XxxPageState` với comment `// Mock data — thay bằng API khi BX hoàn thành`
- Không tạo file mock riêng
- Model cục bộ đặt cùng folder với page (`cv_item.dart` nằm trong `features/profile/`)

---

## Màu sắc & style

Tất cả màu và style lấy từ `AppTheme`:

```dart
AppTheme.primaryBlue      // #0A66C2
AppTheme.textPrimary      // #191919
AppTheme.textSecondary    // #666666
AppTheme.surfaceGray      // #F3F2EF
AppTheme.divider          // #E0DFDC
AppTheme.errorRed         // #B00020
AppTheme.successGreen     // #057642
```

Không hardcode hex trực tiếp trong widget trừ màu chưa có trong `AppTheme`.
