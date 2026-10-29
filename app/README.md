# app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Đăng nhập Google trên web (localhost:3000)

Trên web, Google chỉ cho đăng nhập bằng **nút do chính Google vẽ**, nên app tự hiện nút đó
(xem `lib/features/auth/presentation/widgets/google_web_sign_in.dart`). Android và iOS vẫn dùng nút cũ.

**1. Google Cloud Console** → tạo OAuth client ID loại **Web application**:
- Authorized JavaScript origins: `http://localhost:3000` và `http://localhost`
- Authorized redirect URIs: để trống
- OAuth consent screen đang ở chế độ *Testing* thì thêm email của bạn vào **Test users**

**2. Server** (`server/.env`): `GOOGLE_CLIENT_ID` phải đúng **Web client ID** ở bước 1, rồi khởi động lại server.

**3. Chạy app** (cổng phải cố định và trùng origin đã khai báo):

```
flutter run -d chrome --web-port 3000 --no-web-resources-cdn --dart-define=GOOGLE_CLIENT_ID=<web client id> --dart-define=API_URL=http://localhost:5000/api/v1
```

Không truyền `GOOGLE_CLIENT_ID` thì màn đăng nhập sẽ hiện dòng nhắc thiếu cấu hình thay vì nút Google.

| Lỗi thường gặp | Nguyên nhân |
|---|---|
| `origin_mismatch` | Cổng web khác cổng đã khai báo trong Google Cloud |
| Server trả 401 `INVALID_GOOGLE_TOKEN` | `GOOGLE_CLIENT_ID` của server khác ID mà app dùng |
| Email này đăng nhập được, email kia thì không | Consent screen đang ở Testing, email kia chưa vào Test users |

**Cách chạy không phải dán ID bằng tay** (PowerShell, đứng trong thư mục `app`, đọc ID từ `server/.env`):

```powershell
$id = (Select-String -Path ..\server\.env -Pattern '^GOOGLE_CLIENT_ID=(.+)$').Matches[0].Groups[1].Value.Trim('"')
flutter run -d chrome --web-port 3000 --no-web-resources-cdn --dart-define=GOOGLE_CLIENT_ID=$id --dart-define=API_URL=http://localhost:5000/api/v1
```

Trên web, nếu chưa truyền `GOOGLE_CLIENT_ID` thì nút "Tiếp tục với Google" vẫn hiện, bấm vào sẽ báo thiếu cấu hình.

**Cho gọn và nhanh:** đặt `GOOGLE_CLIENT_ID` và `API_URL` vào file `app/dart_defines.local.json` (đừng commit),
rồi chạy `flutter run -d chrome --web-port 3000 --no-web-resources-cdn --dart-define-from-file=dart_defines.local.json`.
Cờ `--no-web-resources-cdn` dùng CanvasKit có sẵn trong Flutter SDK thay vì tải từ internet mỗi lần mở trang.
