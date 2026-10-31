# ADR-0004 · Gọi AI qua một lớp adapter, mặc định chạy mock

- **Trạng thái:** Ghi lại sau (đã áp dụng) · 2026-10-31
- **Liên quan:** `server/src/services/ai/` (`aiClient.js`, `httpAdapter.js`, `mockAdapter.js`, `cvTextAnalyzer.js`), `ai/main.py`

## Bối cảnh
AI service Python (`/analyze-cv`, `/match`) chưa xong khi app và server đã cần dữ liệu để chạy.

## Phương án đã cân nhắc
| Phương án | Ưu | Nhược |
|---|---|---|
| **A. Một cửa `aiClient.js`, chọn adapter theo `AI_MODE`; mock đọc chữ PDF và dò từ điển** | Chạy được ngay, không tốn tiền; đổi sang AI thật không sửa service | Mock chỉ nhận đúng tên trong từ điển |
| B. Gọi thẳng AI service | Ít lớp | Không chạy được khi AI service tắt |

## Quyết định
Chọn **A**. `AI_MODE=mock` là mặc định; `AI_FALLBACK_TO_MOCK=true` thì lỗi AI thật sẽ chuyển sang mock thay vì trả 500.

## Hệ quả
- Mọi kết quả trích skill từ CV, dù từ AI thật hay mock, đều phải qua bước kiểm bằng chứng (ADR-0005).
- Trước ADR-0005, mock trả sẵn `flutter, dart, git` khi không đọc được PDF; ADR-0005 bỏ hành vi này.
