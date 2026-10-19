# 🚀 Walkthrough: Hoàn thành Task B2 - Auth API

## 1. Tổng Quan Quá Trình Thực Hiện
Theo đúng quy tắc nhóm tại [`CONTRIBUTING.md`](file:///d:/BaiTapLapTrinhDiDong/MiniLinkedInMobile/CONTRIBUTING.md):
- Công việc được thực hiện trên nhánh độc lập: **`feature/B2-auth-api`**.
- Toàn bộ thay đổi được chia nhỏ thành **4 commit nguyên tử (atomic commits)** tuân thủ chuẩn **Conventional Commits**.
- Đã đồng bộ cấu trúc cơ sở dữ liệu lên Supabase qua Prisma.
- Đã viết bộ kiểm thử tự động (8 test cases) và chạy kiểm tra thực tế (live test) thành công 100%.

---

## 2. Lịch Sử Commit Trên Nhánh `feature/B2-auth-api`

| Hash | Loại | Nội dung Commit |
|---|---|---|
| `3f898c3` | `feat(db)` | Thêm model `RefreshToken` và trường `googleId` vào schema Prisma |
| `ef29cd6` | `chore(server)` | Cài `google-auth-library` và cập nhật cấu hình `env.example` |
| `e725fe5` | `feat(server)` | Tạo token utils và middleware xác thực JWT |
| `7c50e50` | `feat(server)` | Tạo API đăng ký, đăng nhập, google login, token refresh và logout |

---

## 3. Danh Sách Các Endpoint Hoàn Thành

| Method | Endpoint | Quyền | Mục đích |
|---|---|---|---|
| `POST` | `/api/v1/auth/register` | Public | Đăng ký tài khoản (hỗ trợ `student` và `recruiter`) |
| `POST` | `/api/v1/auth/login` | Public | Đăng nhập bằng Email & Mật khẩu |
| `POST` | `/api/v1/auth/google` | Public | Đăng nhập bằng Google `idToken` (verify server-side) |
| `POST` | `/api/v1/auth/refresh` | Public | Cấp lại `accessToken` mới từ `refreshToken` hợp lệ |
| `POST` | `/api/v1/auth/logout` | Public | Đăng xuất, xóa `refreshToken` khỏi cơ sở dữ liệu |
| `GET` | `/api/v1/auth/me` | Bearer Token | Lấy thông tin user hiện tại kèm profile chi tiết |

---

## 4. Kết Quả Kiểm Thử (Verification Results)

### A. Kiểm Thử Tự Động (Automated Unit Tests)
Chạy lệnh `npm test` trong thư mục `server/`:
- `register validates input and creates a student session` ➡️ **PASS**
- `register conflicts on duplicate email and defers recruiter profile creation` ➡️ **PASS**
- `login accepts valid credentials and rejects incorrect credentials` ➡️ **PASS**
- `Google login verifies audience and creates a student account` ➡️ **PASS**
- `Google login rejects an unverified email` ➡️ **PASS**
- `refresh rejects expired tokens and logout revokes active tokens` ➡️ **PASS**
- `getMe returns public user data and profile fields only` ➡️ **PASS**
- `authenticate rejects missing tokens and attaches verified claims` ➡️ **PASS**
- **Tổng cộng: 8/8 test cases PASS (100%)**.

### B. Kiểm Thử Thực Tế End-to-End (Live Database)
Đã chạy kịch bản thực tế kết nối trực tiếp Supabase:
1. Đăng ký tài khoản mới ➡️ Nhận `accessToken` (15m) + `refreshToken` (7d).
2. Đăng nhập lại với email vừa tạo ➡️ Đăng nhập thành công.
3. Gọi `GET /api/v1/auth/me` kèm header `Authorization: Bearer <token>` ➡️ Nhận đúng thông tin sinh viên.
4. Gọi `POST /api/v1/auth/refresh` ➡️ Cấp mới `accessToken`.
5. Gọi `POST /api/v1/auth/logout` ➡️ Thu hồi thành công token khỏi database.
