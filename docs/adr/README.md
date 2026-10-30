# Tài liệu quyết định (ADR)

Mỗi file ghi **một** quyết định kiến trúc: bối cảnh, các phương án đã cân nhắc, chọn gì, và hệ quả.
Muốn làm ngược một quyết định thì viết ADR mới thay thế, không sửa lặng lẽ ADR cũ.

| Số | Quyết định | Trạng thái |
|---|---|---|
| [0001](0001-monorepo-flutter-node-python.md) | Monorepo 3 phần: Flutter, Node/Express, Python AI | Ghi lại sau (đã áp dụng) |
| [0002](0002-custom-jwt-auth.md) | Server tự quản lý đăng nhập bằng JWT + refresh token | Ghi lại sau (đã áp dụng) |
| [0003](0003-prisma-plus-sql-files.md) | Prisma cho bảng chính, SQL thuần cho schema `social` và file `*_ext.sql` | Ghi lại sau (đã áp dụng) |
| [0004](0004-ai-adapter-mock-default.md) | Gọi AI qua một lớp adapter, mặc định chạy mock | Ghi lại sau (đã áp dụng) |
| [0005](0005-skills-need-evidence.md) | Skill phải có bằng chứng; trích skill bằng quy tắc | Đề xuất |
| [0006](0006-close-database-backdoor.md) | Đóng cửa sau database bằng khóa dòng (RLS) | Đề xuất |

"Ghi lại sau" nghĩa là nhóm đã làm vậy từ trước; ADR chỉ chép lại lý do từ code và tài liệu hiện có.
"Đề xuất" chờ nhóm duyệt qua PR rồi đổi thành "Được chấp nhận".

## Mẫu

```markdown
# ADR-NNNN · Tên quyết định

- **Trạng thái:** Đề xuất | Được chấp nhận | Thay thế bởi ADR-XXXX · YYYY-MM-DD
- **Liên quan:** file, module, task

## Bối cảnh
Vấn đề gì, ràng buộc gì.

## Phương án đã cân nhắc
| Phương án | Ưu | Nhược |

## Quyết định
Chọn gì, vì sao.

## Hệ quả
Được gì, mất gì, việc phải làm thêm.
```
