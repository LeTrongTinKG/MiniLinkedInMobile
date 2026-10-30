# ADR-0008 · Chatbot kỹ năng và lộ trình chạy Ollama trên máy, trả lời bằng quy tắc trước

- **Trạng thái:** Được chấp nhận · 2026-10-31
- **Liên quan:** [docs/chatbot/](../chatbot/README.md), ADR-0004 (adapter, mặc định mock), ADR-0005 và ADR-0007 (bằng chứng, độ tin cậy)

## Bối cảnh

Sinh viên cần biết mình thiếu skill gì cho vị trí muốn theo và nên học gì tiếp. Dữ liệu đã có: skill đã duyệt kèm độ tin cậy, skill trong CV kèm câu trích, skill job yêu cầu.
Chủ dự án muốn dùng một model 3–4B chạy bằng Ollama trên Mac (8 GB RAM), không gửi dữ liệu ra ngoài. Model nhỏ dễ bịa và dễ viết tiếng Việt sai lệch (đã thấy khi thử qwen3.5 2B cho Atom).

## Phương án đã cân nhắc

| Phương án | Ưu | Nhược |
|---|---|---|
| **A. Server tính câu trả lời bằng quy tắc; model chỉ viết lại cho tự nhiên** | Số liệu (skill thiếu, bước, thời gian) luôn đúng; tắt model vẫn chạy | Câu trả lời ít linh hoạt |
| B. Đưa dữ liệu cho model tự trả lời | Linh hoạt | Model 4B dễ bịa skill và bước; khó đạt 80% |
| C. Gọi model trên mạng khi Ollama tắt | Luôn có model | Dữ liệu ra ngoài; cần khóa API mới; trái màn đồng ý |

## Quyết định

Chọn **A**.

1. **Phân loại câu hỏi bằng quy tắc** trên server. Câu bấm sẵn mang sẵn loại câu. Câu gõ tự do được so với tên skill trong từ điển, tên vị trí và các từ về lộ trình. Không khớp thì trả câu từ chối cố định, không gọi model.
2. **Server tính phần dữ liệu** của câu trả lời: skill có, skill thiếu, bước hiện tại, thời gian còn lại, căn cứ. Lộ trình đọc từ `server/src/services/coach/roadmaps/*.md` có `status: reviewed`.
3. **Model chỉ viết lại** phần dữ liệu đó thành tối đa 150 từ tiếng Việt. Server kiểm tra lại: câu trả lời không được nhắc skill nào ngoài danh sách đã đưa; sai thì dùng bản quy tắc.
4. **Chế độ** theo biến môi trường `COACH_MODE=rules|ollama`, mặc định `rules`, giống `AI_MODE=mock` của ADR-0004. Ollama lỗi hoặc quá 10 giây thì trả bản quy tắc.
5. **Model**: `qwen3.5:4b-q4_K_M` (3,3 GB). Đo trên bộ 30 câu; chậm quá 10 giây thì lùi về `qwen3.5:2b-q4_K_M`. Gọi `/api/chat` của Ollama bằng `fetch` có sẵn trong Node, không thêm thư viện.
6. **Đồng ý và hạn mức**: chưa bật đồng ý thì không đọc dữ liệu, không gọi model. 10 câu mỗi ngày theo giờ Việt Nam; câu bị chặn không trừ lượt. Không lưu nội dung hội thoại.
7. **Chống chèn lệnh**: chữ từ CV và README không bao giờ đưa vào model; model chỉ nhận tên skill chuẩn và nội dung lộ trình đã duyệt.

## Hệ quả

- Không dùng `aiClient`: `aiClient` gọi service Python `ai/` để đọc CV; chatbot nằm trong server Node theo lựa chọn của chủ dự án.
- Schema: `student_profiles.coachConsentAt`, `student_profiles.targetRole`, bảng `coach_usage`. Chạy `prisma/coach_ext.sql` rồi `rls_lockdown.sql`. Đã chạy trên database nhóm; `check-rls` OK.
- Chỉ chạy được khi server Node chạy trên cùng Mac với Ollama. Bản trên Render để `COACH_MODE=rules`.
- Đo 2026-10-31 trên Mac M2 8 GB (bộ 30 câu, lần nạp không tính):
  - `qwen3.5:4b-q4_K_M`: nạp 188 giây, 18/30 câu dưới 10 giây, chậm nhất 11,1 giây, bộ nhớ trống 11%, model viết lại được dùng 9/21 câu có trả lời.
  - `qwen3.5:2b-q4_K_M`: nạp 58 giây, 30/30 câu dưới 10 giây, chậm nhất 3,1 giây, bộ nhớ trống 22%, model viết lại được dùng 18/21 câu.
  - Chọn **2B cho demo trên máy 8 GB** vì đạt mốc 10 giây. 4B giữ trên ổ để thử khi có máy mạnh hơn. Bảng chấm: `docs/chatbot/eval-runs/`.
- shortcut: lộ trình nằm trong file markdown, không có màn quản trị. Thêm hoặc sửa vị trí thì sửa file và duyệt qua PR.
- shortcut: màn job chưa gửi `jobId`; chatbot lấy job ứng tuyển gần nhất. Gửi `jobId` khi mở khung từ màn chi tiết job.
