# ADR-0002 · Server tự quản lý đăng nhập bằng JWT + refresh token

- **Trạng thái:** Ghi lại sau (đã áp dụng) · 2026-10-31
- **Liên quan:** `server/src/utils/token.js`, `server/src/middleware/auth.js`, `server/src/services/auth.service.js`, bảng `users`, `refresh_tokens`

## Bối cảnh
Cần đăng nhập email/mật khẩu, Google, GitHub; phân vai `student` / `recruiter`.

## Phương án đã cân nhắc
| Phương án | Ưu | Nhược |
|---|---|---|
| **A. Server tự cấp JWT (jsonwebtoken) + refresh token lưu DB** | Toàn quyền với vai trò, khóa tài khoản, thu hồi token | Tự lo bảo mật: băm mật khẩu, hết hạn, thu hồi |
| B. Supabase Auth | Có sẵn OAuth, khóa dòng theo `auth.uid()` | Đổi toàn bộ luồng; server phải chuyển sang token của Supabase |

## Quyết định
Chọn **A**, đúng như code hiện tại:
- Access token ký bằng `JWT_SECRET` (≥ 32 ký tự), hạn mặc định 1 giờ (`JWT_ACCESS_EXPIRES_IN`).
- Refresh token là UUID ngẫu nhiên lưu bảng `refresh_tokens`, hạn mặc định 7 ngày (`JWT_REFRESH_EXPIRES_DAYS`).
- `tokenVersion` để thu hồi token khi đăng xuất; `loginAttempts` / `loginLockedUntil` để khóa tạm khi sai mật khẩu nhiều lần.
- Google, GitHub: server đổi mã đăng nhập lấy thông tin rồi tự cấp JWT; lưu `googleId` / `githubId`.

## Hệ quả
- Database **không biết** ai đang gọi: server nối bằng một tài khoản chung. Vì vậy khóa dòng kiểu "mỗi người chỉ thấy dòng của mình" trong Postgres không dùng được ngay; quyền từng người do server kiểm (ADR-0006).
- `CLAUDE.md` ghi "token 7 ngày" là hạn của refresh token; access token mặc định 1 giờ.
