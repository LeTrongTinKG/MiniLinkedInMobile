# ADR-0006 · Đóng cửa sau database bằng khóa dòng (RLS)

- **Trạng thái:** Đề xuất · 2026-10-31
- **Liên quan:** `server/prisma/rls_lockdown.sql`, `server/scripts/check-rls.js`, ADR-0002, ADR-0003
- **Nguồn:** Atom khóa từng dòng bằng `auth.uid()` (ADR-0006 của Atom). MiniLinkedIn không dùng Supabase Auth nên chỉ lấy được một phần.

## Bối cảnh
- Mọi dự án Supabase đều mở REST API công khai tại `https://<project>.supabase.co/rest/v1/`. Ai có **anon key** (khóa này được coi là công khai) đều gọi được.
- Bảng tạo trong schema `public` mặc định cấp quyền cho vai trò `anon` / `authenticated`. Nếu bảng chưa bật khóa dòng, người ngoài đọc được `users` (email, mã băm mật khẩu), `refresh_tokens`, CV, đơn ứng tuyển.
- Thử trên database tạm (Postgres 16, giả lập quyền mặc định của Supabase): trước khi khóa, vai trò `anon` đọc được email và `passwordHash` trong `users`.
- Server nối bằng tài khoản chủ bảng (`postgres`). Tài khoản chủ bảng không bị khóa dòng chặn.

## Phương án đã cân nhắc
| Phương án | Ưu | Nhược |
|---|---|---|
| **A. Đóng cửa sau: bật RLS trên mọi bảng `public` và `social`, không viết policy, thu hết quyền của `anon` / `authenticated`** | Chặn toàn bộ truy cập công khai; server không phải sửa gì; chạy lại được | Quyền từng người vẫn chỉ do server kiểm; server có lỗi thì DB không đỡ |
| B. Khóa đúng từng người như Atom: server đổi sang vai trò thường, mỗi request `SET LOCAL app.user_id`, policy theo biến đó | Server sai thì DB vẫn chặn | Sửa mọi chỗ gọi Prisma/`pg` (transaction mỗi request), dễ vỡ tính năng của nhóm, Prisma + pooler cần cấu hình riêng |
| C. Không làm gì | Không tốn công | Lộ dữ liệu nếu anon key lộ (key này nằm trong app nếu sau này app dùng Supabase) |

## Quyết định
Chọn **A** (chủ dự án chọn 2026-10-31). Quyền từng người tiếp tục kiểm ở service ("Ownership check trước mọi write operation" trong `CLAUDE.md`).

## Hệ quả
- Chạy `server/prisma/rls_lockdown.sql` trên database thật (SQL Editor của Supabase hoặc `psql`), rồi `node scripts/check-rls.js` để xác nhận. Thêm bảng mới thì chạy lại.
- Đã thử trên database tạm: sau khi khóa, `anon` bị từ chối đọc `users`, `authenticated` bị từ chối ghi `social.posts`, server vẫn đọc/ghi bình thường; bảng tạo sau đó cũng không tự mở quyền cho `anon`.
- Không đụng schema `storage` (ảnh, CV) của Supabase; quyền bucket là việc riêng.
- Muốn làm B sau này thì viết ADR mới.
- **Việc gấp ngoài ADR này:** `README.md` đang chứa mật khẩu database thật trong `DATABASE_URL`. Phải đổi mật khẩu trên Supabase rồi xóa khỏi README; xóa khỏi README thôi là chưa đủ vì lịch sử git vẫn giữ.
