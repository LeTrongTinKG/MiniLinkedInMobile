# Việc cần làm cho chatbot kỹ năng và lộ trình

Làm trên nhánh `feature/B-skill-roadmap-coach`.

## 01 · Duyệt tài liệu

- **Status:** done · Chủ dự án duyệt 2026-10-31. 4 lộ trình `status: reviewed`. ADR-0008 được chấp nhận. "Sai số dưới 30%" = tối đa 8/30 câu có ít nhất một mục dưới 2 điểm.

## 02 · Đo model trên Mac

- **Status:** done · 4B không đạt 10 giây (18/30). 2B đạt 30/30, chọn 2B cho demo trên máy 8 GB. Kết quả ghi ADR-0008.

## 03 · Database: đồng ý, vị trí mục tiêu, lượt hỏi

- **Status:** done · `coach_ext.sql` + `rls_lockdown.sql` đã chạy trên database nhóm. `check-rls` OK. SQL tăng lượt: 1..10 rồi `null`.

## 04 · Server: trả lời bằng quy tắc

- **Status:** done · `POST /api/v1/coach/ask`, `GET/PUT /api/v1/coach/settings`. Test 39/39 đạt, gồm 30 câu eval.

## 05 · Server: Ollama viết lại

- **Status:** done · `COACH_MODE`, `OLLAMA_URL`, `OLLAMA_MODEL` trong `.env.example`. Lỗi / quá 10 giây / thêm skill lạ thì dùng bản quy tắc.

## 06 · App: nút nổi và khung trả lời

- **Status:** done · Nút "Trợ lý kỹ năng" trên màn sinh viên. Màn đồng ý + chọn vị trí. 8 câu mẫu, ô gõ 300 ký tự, căn cứ, số lượt.

## 07 · Chấm 30 câu

- **Status:** ready-for-human · Bảng máy: `docs/chatbot/eval-runs/2026-10-31-qwen3.5-2b.md` và `...-4b.md`. Chủ dự án chấm tay 3 cột. Mở PR vào `dev` sau khi đạt ngưỡng.
