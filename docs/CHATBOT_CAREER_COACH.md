# CƠ CHẾ CHATBOT AI CAREER COACH (ATOM PROJECT)

> **Tài liệu Kỹ thuật & Học thuật Dự án Atom (ADR-0008)**  
> Phiên bản: 1.0.0 — Cập nhật: 2026-11-03  
> Phục vụ: Thuyết trình, bảo vệ đồ án và thẩm định kiến trúc trước hội đồng giảng viên.

---

## 1. TRIẾT LÝ THIẾT KẾ VÀ MÔ HÌNH HYBRID AI

Trong các ứng dụng giáo dục nghề nghiệp thông thường, việc sử dụng LLM tự do (Naive LLM Prompting) gây ra 3 vấn đề lớn:
1. **Ảo giác thông tin (Hallucination)**: Mô hình tự ý sáng tác ra số tuần học, bịa ra công nghệ ngoài chương trình hoặc đưa ra lời khuyên mơ hồ.
2. **Nguy cơ Tấn công & Rò rỉ Dữ liệu (Prompt Injection & Cross-user Leak)**: Người dùng có thể bẫy bot để đọc dữ liệu sinh viên khác hoặc bắt bot làm việc ngoài phạm vi.
3. **Chi phí và Phần cứng**: Các mô hình lớn (GPT-4) tốn chi phí token liên tục và không bảo đảm quyền riêng tư theo GDPR/PDPA.

### Triết lý Thiết kế của Atom:
> **"Deterministic Facts, Local LLM for Tone"**  
> *"Dữ liệu sự thật, số tuần học, lộ trình và khoảng cách kỹ năng do Server tính toán chính xác 100% bằng quy tắc. Mô hình ngôn ngữ lớn (LLM) cục bộ chỉ đóng vai trò người biên tập (Paraphraser) làm mềm văn phong tiếng Việt cho sinh viên."*

---

## 2. KIẾN TRÚC PIPELINE 7 TẦNG (7-LAYER CHATBOT ARCHITECTURE)

```
 [Flutter Mobile Client]
           |
           | HTTP POST /api/v1/coach/ask { question, jobId? }
           v
+----------------------------------------------------------------------------------------------------+
|                                    NODE.JS BACKEND PIPELINE                                        |
|                                                                                                    |
|  [TẦNG 1: XÁC THỰC & BẢO MẬT (Security & Consent Gate)]                                            |
|   - Xác thực danh tính sinh viên qua JWT Access Token                                              |
|   - Kiểm tra quyền riêng tư GDPR: coachConsentAt != null (Bắt buộc người dùng đồng ý trước)        |
|                                                                                                    |
|  [TẦNG 2: PHÂN LOẠI INTENT & CHỐNG TẤN CÔNG (intent.js)]                                           |
|   - Chặn Prompt Injection: /ignore previous instructions/, /system prompt/, /từ giờ bạn là/,...   |
|   - Chặn rò rỉ chéo: /sinh viên khác/, /người dùng kia/                                            |
|   - Chặn câu hỏi ngoài luồng: /thời tiết/, /chính trị/, /lương/, /viết code hộ/                    |
|   - Phân loại chính xác 10 Intent nghiệp vụ                                                        |
|                                                                                                    |
|  [TẦNG 3: BỘ ĐIỀU TIẾT HẠN MỨC (coach.repository.js)]                                              |
|   - Hạn mức 10 câu/ngày theo giờ Việt Nam (Reset vào 00:00 Asia/Ho_Chi_Minh)                       |
|   - Khóa nguyên tử (Atomic transaction lock) - Câu bị từ chối KHÔNG bị trừ lượt                    |
|                                                                                                    |
|  [TẦNG 4: HỢP NHẤT NGỮ CẢNH DỮ LIỆU (Context Aggregation - progress.js, roadmaps.js)]             |
|   - Phân cấp kỹ năng: evidenced (GitHub đạt chuẩn) > cv (trong PDF) > unverified (tự khai)         |
|   - Tính toán bước hiện tại, số tuần dự kiến còn lại, kỹ năng còn thiếu theo lộ trình              |
|                                                                                                    |
|  [TẦNG 5: MÁY SINH CÂU TRẢ LỜI QUY TẮC (Deterministic Generator - answers.js)]                    |
|   - Tạo câu trả lời gốc chính xác 100% về mặt dữ liệu kỹ thuật và trích dẫn                        |
|                                                                                                    |
|  [TẦNG 6: TẬP TRUNG HÓA LỜI VĂN BẰNG LLM CỤC BỘ (ollamaWriter.js)]                                 |
|   - Gọi Ollama chạy cục bộ (qwen3.5:2b-q4_K_M) - Nhiệt độ thấp 0.2, thời gian chờ 10 giây          |
|                                                                                                    |
|  [TẦNG 7: BỘ KIỂM SOÁT ĐẦU RA 3 LỚP (Output Guardrail - acceptable())]                             |
|   - Check 1: Độ dài văn bản <= 150 từ                                                              |
|   - Check 2: Bảo toàn kỹ năng (Không chứa kỹ năng bịa đặt)                                         |
|   - Check 3: Bảo toàn số liệu (Không chứa con số sai lệch)                                         |
|   -> VI PHẠM BẤT KỲ CHECK NÀO: HỦY KẾT QUẢ LLM, TRẢ VỀ NGUYÊN VĂN BẢN QUY TẮC CỦA TẦNG 5!          |
+----------------------------------------------------------------------------------------------------+
           |
           | JSON { answer, sources, mode: "ollama" | "rules", remaining, resetsAt }
           v
 [Flutter Mobile Client - Hiển thị phản hồi và Thẻ Tiến độ Milestone]
```

---

## 3. CHI TIẾT CÁC TẦNG KỸ THUẬT

### 3.1. Phân loại Ý định (10 Specialized Intents)
Chatbot Atom hỗ trợ chính xác 10 Intent phục vụ học tập và định hướng nghề nghiệp:

| Intent | Ý nghĩa nghiệp vụ | Ví dụ câu hỏi thực tế |
| :--- | :--- | :--- |
| `missing_skills` | Kỹ năng còn thiếu theo hướng đi | *"Tôi còn thiếu kỹ năng gì để theo hướng Mobile Flutter?"* |
| `current_step` | Vị trí hiện tại trong lộ trình | *"Tôi đang ở bước mấy trong lộ trình?"* |
| `next_learn` | Kỹ năng nên học tiếp theo | *"Tuần này tôi nên học gì tiếp theo?"* |
| `evidence_status` | Tình trạng bằng chứng kỹ năng | *"Những kỹ năng nào của tôi đã có bằng chứng Git?"* |
| `skill_status` | Trạng thái của một kỹ năng cụ thể | *"Kỹ năng Bloc của tôi đã đạt chuẩn chưa?"* |
| `how_evidence` | Cách đạt được bằng chứng tin cậy | *"Làm thế nào để kỹ năng Flutter có bằng chứng?"* |
| `job_gap` | Khoảng cách so với tin tuyển dụng | *"Hồ sơ của tôi thiếu gì so với Job Flutter Intern này?"* |
| `project_for` | Đề xuất đồ án/project mẫu | *"Tôi nên làm dự án gì để chứng minh kỹ năng State Management?"* |
| `time_left` | Thời gian ước tính hoàn thành | *"Còn bao nhiêu tuần nữa thì tôi có thể đi làm được?"* |
| `skill_in_roadmap`| Kiểm tra kỹ năng có trong lộ trình | *"Kỹ năng Docker có nằm trong lộ trình Mobile không?"* |

---

### 3.2. Hàng rào Phòng vệ Đa lớp (Defense-in-Depth)

#### A. Chống Prompt Injection (Jailbreak Detection)
- **Tệp nguồn**: `server/src/services/coach/progress.js`
- Hệ thống áp dụng 2 tầng regex kiểm tra chuỗi có dấu và không dấu:
  ```javascript
  const INSTRUCTION_PATTERN =
    /\b(ai|chatbot|gpt|llm|bot)\b[^.?!\n]{0,30}(hãy|ghi tôi|coi tôi|viết rằng)|bỏ qua (mọi|tất cả|các|hướng dẫn)|ignore (all|previous|the)|system prompt|câu lệnh hệ thống|hướng dẫn trước|từ giờ bạn là|bạn là trợ lý/i;
  ```
- **Chống chèn mã ẩn trong CV (Indirect Injection)**: Nếu kẻ xấu chèn text điều khiển vào CV nhằm ép AI công nhận kỹ năng, hàm `cvSkillNames()` đánh dấu `tainted` câu trích dẫn và loại bỏ kỹ năng đó khỏi ngữ cảnh.

#### B. Ngăn chặn Rò rỉ Dữ liệu giữa các Sinh viên (Cross-User Isolation)
- Nếu câu hỏi chứa các cụm từ:
  ```javascript
  const OTHER_USER = /\b(sinh vien|nguoi dung|nguoi|ban)\s+(khac|kia)\b/;
  ```
  Hệ thống lập tức trả về `{ refuse: "attack" }`, từ chối trả lời và bảo vệ tuyệt đối dữ liệu người khác.

#### C. Lọc Chủ đề Ngoài luồng (Off-Topic Filter)
- Chặn câu hỏi thời tiết, đùa vui, chính trị, viết code hộ (`\bcode mau\b`), lương bổng (`/lương/i`) hoặc dụ dỗ mô hình bỏ qua lộ trình của trường (`PRIOR_KNOWLEDGE`).
- **Nguyên tắc bảo vệ sinh viên**: Các câu hỏi bị từ chối do vi phạm quy tắc **không bao giờ bị trừ vào hạn mức 10 câu/ngày**.

---

### 3.3. Thuật toán Đo lường Tiến độ Lộ trình (`roadmapProgress`)
- **Tệp nguồn**: `server/src/services/coach/progress.js`
- **Nguyên lý**:
  - `done`: Là các bước mà tất cả nhóm kỹ năng trong bước đó đều đã đạt trạng thái `evidenced` hoặc `cv`.
  - `current`: Bước đầu tiên mà sinh viên chưa hoàn thành đầy đủ các nhóm kỹ năng.
  - `weeksLeft`: Tổng số tuần học dự kiến của các bước từ bước hiện tại đến cuối lộ trình.
  - Hỗ trợ lựa chọn nhánh tương đương: Ví dụ ở Bước 5 của Lộ trình Flutter, sinh viên chọn học `bloc` **HOẶC** `riverpod` đều được công nhận hoàn thành bước.

---

### 3.4. Mô hình Ngôn ngữ Cục bộ (Local LLM via Ollama)
- **Tệp nguồn**: `server/src/services/coach/ollamaWriter.js`
- **Mô hình lựa chọn**: `qwen3.5:2b-q4_K_M` (Lượng tử hóa 4-bit, kích thước bộ nhớ $< 1.8\text{ GB RAM}$).
- **Cấu hình suy luận**:
  - `temperature = 0.2`: Giữ nhiệt độ rất thấp để đảm bảo câu trả lời mang tính quy chuẩn, không sáng tạo bừa bãi.
  - `num_predict = 300`: Giới hạn token sinh tối đa.
  - `stream = false`, `think = false`: Tắt chain-of-thought để phản hồi siêu tốc ($1.2\text{s} - 1.8\text{s}$).
  - `keep_alive = "30m"`: Giữ mô hình trong RAM máy chủ để không mất thời gian nạp lại giữa các request.

---

### 3.5. Bộ Thẩm định Đầu ra 3 Lớp (Triệt tiêu Hallucination)
Sau khi Ollama trả về văn bản, hàm `acceptable(original, rewritten)` kiểm tra 3 điều kiện toán học:

$$\text{Acceptable}(T_{\text{orig}}, T_{\text{rewritten}}) = C_1 \land C_2 \land C_3$$

1. **Điều kiện 1 (Độ dài văn bản)**:
   $$\text{WordCount}(T_{\text{rewritten}}) \le 150$$
2. **Điều kiện 2 (Bảo toàn Kỹ năng - Zero Fabricated Skills)**:
   $$\text{MentionedSkills}(T_{\text{rewritten}}) \subseteq \text{MentionedSkills}(T_{\text{orig}})$$
3. **Điều kiện 3 (Bảo toàn Số liệu - Zero Fabricated Metrics)**:
   $$\text{NumbersIn}(T_{\text{rewritten}}) \subseteq \text{NumbersIn}(T_{\text{orig}})$$

**Cơ chế Tự phục hồi an toàn (Safe Fallback)**:
Nếu vi phạm bất kỳ điều kiện nào (hoặc máy chủ Ollama bị tắt/timeout 10 giây), hệ thống tự động loại bỏ câu văn của LLM và trả về nguyên văn bản mẫu chuẩn 100% của Rule Engine với cờ `mode: "rules"`.

---

## 4. TÍCH HỢP TRÊN CLIENT FLUTTER MOBILE

- **Màn hình Consent Gate (`coach_consent_view.dart`)**: Bắt buộc sinh viên bấm đồng ý điều khoản quyền riêng tư trước khi kích hoạt khung chat.
- **Quick Suggestion Chips (`coach_chat_view.dart`)**: Cung cấp các nút gợi ý câu hỏi một chạm chuẩn xác, giúp sinh viên không cần gõ bàn phím.
- **Thẻ Tiến độ Milestone (`coach_milestone_card.dart`)**: Trực quan hóa tiến độ lộ trình (Bước hiện tại, số tuần còn lại, các bước đã hoàn tất).

---

## 5. TỔNG KẾT VÀ BẢNG THAM CHIẾU KỸ THUẬT

| Tiêu chí | Chatbot Atom (ADR-0008) | Chatbot truyền thống (OpenAI Wrapper) |
| :--- | :--- | :--- |
| **Kiến trúc** | Hybrid Deterministic Rules + Local LLM Paraphraser | Pure LLM Generation (Prompt-based) |
| **Chi phí API** | **0 USD** (chạy cục bộ qua Ollama) | 0.02$ - 0.05$ / câu hỏi |
| **Rủi ro Bịa đặt (Hallucination)** | **0%** (Được chặn bởi hàm `acceptable()`) | Thường xuyên bịa số tuần và kỹ năng |
| **Bảo mật Dữ liệu** | Tuân thủ GDPR/PDPA, không lưu vết câu hỏi | Dữ liệu cá nhân bị gửi lên Cloud bên thứ ba |
| **Thời gian phản hồi** | $1.2\text{s} - 1.8\text{s}$ (Local) / $< 5\text{ms}$ (Rules fallback) | $2\text{s} - 6\text{s}$ phụ thuộc mạng quốc tế |
| **Tính sẵn sàng khi mất mạng** | Vẫn hoạt động hoàn hảo ở chế độ `rules` | Tê liệt hoàn toàn khi mất mạng hoặc hết quota |
