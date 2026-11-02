# ADR-0003 · Prisma cho bảng chính, SQL thuần cho schema `social` và file `*_ext.sql`

- **Trạng thái:** Ghi lại sau (đã áp dụng) · 2026-10-31
- **Liên quan:** `server/prisma/schema.prisma`, `server/prisma/*_ext.sql`, `server/sql/social/`, `server/src/lib/social/db.js`

## Bối cảnh
Database là Postgres trên Supabase. Nhóm dùng `prisma db push` (không có thư mục migration). Module mạng xã hội cần truy vấn phân trang theo con trỏ và đếm cảm xúc mà Prisma viết khó.

## Phương án đã cân nhắc
| Phương án | Ưu | Nhược |
|---|---|---|
| **A. Prisma cho bảng `public`; SQL thuần (`pg`) cho schema `social`; thay đổi thêm vào bảng cũ bằng file `*_ext.sql` chạy lại được** | Mỗi module chọn công cụ hợp; file ext an toàn khi chạy nhiều lần | Hai cách truy cập DB; phải nhớ chạy file ext |
| B. Chỉ Prisma, dùng `prisma migrate` | Lịch sử thay đổi rõ | Phải đổi cách làm của cả nhóm; khó với truy vấn social |

## Quyết định
Chọn **A**, đúng như hiện tại. File `*_ext.sql` phải chạy lại được nhiều lần (`IF NOT EXISTS`, bắt `duplicate_object`).

## Hệ quả
- Không có lịch sử migration; thứ tự chạy file ext ghi trong tài liệu module.
- Cả Prisma lẫn `pg` đều nối bằng `DATABASE_URL` với tài khoản chủ bảng (liên quan ADR-0006).
- Thêm bảng mới thì chạy lại `prisma/rls_lockdown.sql` (ADR-0006).
