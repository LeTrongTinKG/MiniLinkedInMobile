# ADR-0005 · Skill phải có bằng chứng; trích skill bằng quy tắc

- **Trạng thái:** Đề xuất · 2026-10-31
- **Liên quan:** `server/src/services/ai/cvTextAnalyzer.js` (`withEvidence`), `server/src/services/skills/`, `server/src/services/skill.service.js`, `/api/v1/skills`, bảng `skill_suggestions`, cột `user_skills.source` / `evidence`, `app/lib/features/skills/`
- **Nguồn:** chép cách làm từ dự án Atom (ADR-0010 của Atom: trích skill bằng bộ quy tắc tự xây).

## Bối cảnh
- Khi không đọc được file PDF, mock gán sẵn `flutter, dart, git` cho mọi người. Nhà tuyển dụng thấy skill mà ứng viên không hề khai.
- AI thật trả danh sách skill nhưng không nói lấy từ đâu; không ai kiểm được.
- Bảng `user_skills` có sẵn nhưng chưa có đường nào để điền.

## Phương án đã cân nhắc
| Phương án | Ưu | Nhược |
|---|---|---|
| **A. Quy tắc + từ điển; mỗi skill kèm bằng chứng; skill từ GitHub phải được người dùng đồng ý** | Không bịa; kiểm được; không gửi dữ liệu ra ngoài; dễ test | Chỉ nhận skill có dấu hiệu rõ |
| B. Giữ như cũ, tin kết quả AI | Không tốn công | Skill bịa vẫn lọt vào hồ sơ và chấm điểm job |
| C. Gọi mô hình ngôn ngữ lớn để trích | Hiểu được câu tự do | Có thể bịa; tốn tiền; gửi CV ra bên thứ ba |

## Quyết định
Chọn **A**:
1. **CV:** sau khi AI (thật hoặc mock) trả skill, server đọc lại chữ trong PDF và chỉ giữ skill có câu nhắc tới nó. Mỗi skill lưu kèm câu trích (`extractedSkills.evidence = [{ skill, quote }]`, tối đa 160 ký tự). PDF không đọc được thì không có skill nào.
2. **GitHub:** người dùng đã đăng nhập GitHub bấm "Quét GitHub". Server đọc tối đa 5 repo công khai của chính tài khoản đó (lấy theo `githubId`, không nhận tên tài khoản từ app), không lấy fork hay repo lưu trữ. Dấu hiệu: ngôn ngữ chiếm ≥ 10% số byte, thư viện trong `pubspec.yaml` / `package.json`, chủ đề repo, file ở gốc, từ khóa trong README (từ khóa < 3 ký tự không tính). Bộ 13 quy tắc chép nguyên từ Atom (`skillRules.json`).
3. Đề xuất lưu ở `skill_suggestions` với bằng chứng `[{ repo, url, signals }]`; database từ chối đề xuất không có bằng chứng. Skill chỉ vào `user_skills` khi người dùng bấm "Thêm vào hồ sơ" (`source = 'github'`, bằng chứng chép theo).

## Hệ quả
- Không cần khóa API AI. GitHub không có token cho 60 lượt gọi/giờ mỗi IP; một lần quét tốn tối đa 27 lượt. Đặt `GITHUB_READ_TOKEN` (token chỉ đọc, không cần quyền gì) trong `.env` của server để lên 5.000 lượt/giờ.
- Skill đã bấm "Bỏ qua" sẽ không được đề xuất lại, kể cả khi có repo mới (Atom đề xuất lại khi bằng chứng đổi; để sau).
- Chưa làm (đều có ở Atom): chấm độ tin cậy theo lịch sử commit (ADR-0011 của Atom), hạn mức số lần quét, hỏi đồng ý trước khi phân tích.
- Chấm điểm job vẫn dùng skill trong CV, chưa dùng skill đã duyệt từ GitHub. Muốn dùng thì cần quyết định riêng.
- Chạy `prisma/skill_evidence_ext.sql` (hoặc `prisma db push`) rồi `prisma/rls_lockdown.sql` trên database thật.
