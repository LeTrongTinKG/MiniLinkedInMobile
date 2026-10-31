# ADR-0010 · Trích xuất kỹ năng bằng bộ quy tắc nội bộ chi phí 0 USD

- **Trạng thái:** Được chấp nhận · 2026-10-31
- **Người đề xuất:** boppyorca & Antigravity Pair
- **Liên quan:** [F-006](../SPEC.md#f-006), [F-009](../SPEC.md#f-009), Ticket 14, Ticket 10

## Bối cảnh
Khi ứng viên tải lên kho mã nguồn GitHub (Up Repo thay vì CV) hoặc tải lên tệp CV PDF, việc gọi trực tiếp qua các mô hình ngôn ngữ lớn (LLM API thương mại như OpenAI GPT-4) cho mỗi file tạo ra chi phí tính toán đáng kể và độ trễ cao (từ 3 đến 8 giây mỗi yêu cầu).

## Quyết định
1. **Rule-based Extraction (Chi phí 0 USD)**: Sử dụng hệ thống phân tích cú pháp nội bộ dựa trên từ điển kỹ năng chuẩn hóa (`skillsDictionary.js` và `githubReader.js`), quét trực tiếp các dependency manifests (`pubspec.yaml`, `package.json`, `requirements.txt`, `go.mod`, `pom.xml`, v.v.).
2. **Gán nhãn độ tin cậy**:
   - Kỹ năng trích xuất từ repo GitHub hoặc CV được xếp vào mức `evidenced` (Có bằng chứng) kèm trích dẫn file nguồn.
   - Ứng viên có quyền xem xét, chấp nhận hoặc từ chối đề xuất trước khi lưu vào hồ sơ chính thức.
3. **Phân tầng xử lý**: Chỉ gọi mô hình AI/LLM khi người dùng cần tư vấn lộ trình học tập chuyên sâu (AI Coach), giảm thiểu 95% chi phí API.

## Hệ quả
- **Tích cực**: Thời gian trích xuất giảm xuống dưới 100ms, chi phí vận hành 0 USD, hoàn toàn độc lập với các dịch vụ đám mây bên thứ ba.
- **Tiêu cực**: Không nhận diện được những kỹ năng nằm ngoài từ điển nếu chưa được bổ sung vào tập quy tắc.
