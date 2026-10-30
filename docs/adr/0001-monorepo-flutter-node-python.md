# ADR-0001 · Monorepo 3 phần: Flutter, Node/Express, Python AI

- **Trạng thái:** Ghi lại sau (đã áp dụng) · 2026-10-31
- **Liên quan:** `app/`, `server/`, `ai/`, `CONTRIBUTING.md`, `CLAUDE.md`

## Bối cảnh
Đồ án môn Lập trình Di động, nhóm nhiều người làm song song app và backend. Cần chạy được cả khi chưa có AI thật.

## Phương án đã cân nhắc
| Phương án | Ưu | Nhược |
|---|---|---|
| **A. Một repo, 3 thư mục: `app/` Flutter, `server/` Node/Express, `ai/` Python FastAPI** | Một PR sửa được cả app lẫn API; dễ review chéo | Repo lớn; mỗi phần một bộ công cụ |
| B. Ba repo riêng | Tách quyền rõ | Đổi API phải mở PR ở 2–3 nơi, dễ lệch phiên bản |
| C. Flutter gọi thẳng Supabase, không có server | Ít code | Logic nghiệp vụ và khóa bí mật (JSearch, SerpApi, GitHub) phải nằm trong app |

## Quyết định
Chọn **A**. App chỉ gọi server qua `/api/v1` (và `/api/social`); app không gọi AI hay database trực tiếp.

## Hệ quả
- Server là nơi duy nhất cầm khóa bí mật và kiểm quyền (xem ADR-0006).
- Nhánh: `feature/<task>`, không push thẳng `main`, PR cần review (`CONTRIBUTING.md`).
