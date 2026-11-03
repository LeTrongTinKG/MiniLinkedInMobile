# BÁO CÁO KỸ THUẬT CHI TIẾT: FEATURE AI SERVICES & CHATBOT CAREER COACH
**Dự án:** Hệ thống Mạng xã hội tuyển dụng & Cố vấn nghề nghiệp sinh viên (**Atom**)  
**Tác giả:** Kỹ sư phụ trách AI Services  
**Đối tượng báo cáo:** Giảng viên hướng dẫn & Hội đồng bảo vệ đồ án  

---

## MỤC LỤC
1. [TỔNG QUAN KIẾN TRÚC HỆ THỐNG AI SERVICES](#1-tổng-quan-kiến-trúc-hệ-thống-ai-services)
2. [CHI TIẾT 5 MODULE CỐT LÕI CỦA AI SERVICES](#2-chi-tiết-5-module-cốt-lõi-của-ai-services)
   - [Module 1: Trích xuất kỹ năng từ CV (CV Skill Extraction)](#module-1-trích-xuất-kỹ-năng-từ-cv-cv-skill-extraction)
   - [Module 2: Tính điểm phù hợp việc làm (Smart Job Matching)](#module-2-tính-điểm-phù-hợp-việc-làm-smart-job-matching)
   - [Module 3: Xây dựng từ điển kỹ năng (Skills Dictionary & Alias Mapping)](#module-3-xây-dựng-từ-điển-kỹ-năng-skills-dictionary--alias-mapping)
   - [Module 4: Đọc README và phân tích commit GitHub (Git AST & Evidence Scan)](#module-4-đọc-readme-và-phân-tích-commit-github-git-ast--evidence-scan)
   - [Module 5: Triển khai dịch vụ AI (FastAPI Microservice & Adapter Pattern)](#module-5-triển-khai-dịch-vụ-ai-fastapi-microservice--adapter-pattern)
3. [CƠ CHẾ HOẠT ĐỘNG CỦA AI CAREER COACH CHATBOT (ADR-0008)](#3-cơ-chế-hoạt-động-của-ai-career-coach-chatbot-adr-0008)
   - [3 Lớp Hàng Rào Bảo Vệ (3-Tier Guardrails)](#3-lớp-hàng-rào-bảo-vệ-3-tier-guardrails)
   - [Quy trình nạp ngữ cảnh và sinh câu trả lời](#quy-trình-nạp-ngữ-cảnh-và-sinh-câu-trả-lời)
   - [Bộ 30 kịch bản đánh giá chuẩn (eval-30.md)](#bộ-30-kịch-bản-đánh-giá-chuẩn-eval-30md)
4. [TỔNG HỢP CÁC TICKET VÀ MINH CHỨNG MÃ NGUỒN](#4-tổng-hợp-các-ticket-và-minh-chứng-mã-nguồn)
5. [CÂU HỎI THƯỜNG GẶP CỦA GIẢNG VIÊN & CÁCH PHẢN BIỆN](#5-câu-hỏi-thường-gặp-của-giảng-viên--cách-phản-biện)

---

## 1. TỔNG QUAN KIẾN TRÚC HỆ THỐNG AI SERVICES

Hệ thống AI Services trong dự án Atom được xây dựng theo mô hình **Hybrid Microservice Architecture** kết hợp giữa tính linh hoạt của Python trong xử lý dữ liệu và hiệu năng cao của Node.js:

```mermaid
flowchart TD
    Client["Flutter Client (Web / Mobile)"] -->|REST API (HTTPS)| Gateway["Node.js Backend (Express + Prisma)"]
    
    subgraph AI_Subsystem ["Hệ Thống Trí Tuệ Nhân Tạo (Atom AI)"]
        direction TB
        Gateway -->|HTTP Adapter| FastAPI["FastAPI AI Microservice (Python 3)"]
        Gateway -->|Rules + Ollama Client| Coach["AI Career Coach Engine (Qwen 2B LLM)"]
        
        FastAPI --> FastParse["PDF Parser (pdfplumber)"]
        FastAPI --> FastMatch["Match Score Algorithm"]
        
        Coach --> Guard1["Lớp 1: Intent & Refusal Filter"]
        Guard1 --> Guard2["Lớp 2: Rules Engine Grounding"]
        Guard2 --> Guard3["Lớp 3: Ollama Post-Validator"]
    end
    
    Gateway --> DB[("PostgreSQL Database (Supabase)")]
```

- **Python FastAPI Microservice** ([`ai/`](file:///Users/hosynguyen/MiniLinkedInMobile/ai)): Chịu trách nhiệm bóc tách văn bản thô từ PDF, nhận diện kỹ năng bằng regex ranh giới từ (word boundary) và tính điểm tương đồng.
- **Node.js Gateway & Adapter** ([`server/src/services/ai/`](file:///Users/hosynguyen/MiniLinkedInMobile/server/src/services/ai)): Áp dụng **Adapter Pattern** (`AiClient`) để điều phối giữa `httpAdapter` (gọi sang Python thật) và `mockAdapter` (tự động dự phòng nếu AI microservice bận hoặc khởi động chậm).
- **Career Coach Subsystem** ([`server/src/services/coach/`](file:///Users/hosynguyen/MiniLinkedInMobile/server/src/services/coach)): Hệ thống cố vấn nghề nghiệp thông minh chạy Qwen LLM kết hợp cơ chế kiểm soát hallucination tuyệt đối theo tiêu chuẩn ADR-0008.

---

## 2. CHI TIẾT 5 MODULE CỐT LÕI CỦA AI SERVICES

### Module 1: Trích xuất kỹ năng từ CV (CV Skill Extraction)
- **Tập tin phụ trách:** [`ai/extractor.py`](file:///Users/hosynguyen/MiniLinkedInMobile/ai/extractor.py), [`server/src/services/cv.service.js`](file:///Users/hosynguyen/MiniLinkedInMobile/server/src/services/cv.service.js).
- **Mục tiêu:** Nhận diện tự động toàn bộ kỹ năng chuyên môn, trình độ học vấn và số tháng kinh nghiệm từ file CV PDF do ứng viên tải lên.
- **Quy trình hoạt động (Workflow):**
  1. Ứng viên tải file CV PDF lên qua endpoint `POST /api/v1/cvs/upload`.
  2. Server kiểm tra MIME type và magic bytes (`%PDF`).
  3. Dữ liệu nhị phân (binary bytes) được chuyển tới hàm `analyze_pdf(file_bytes: bytes)`.
  4. Sử dụng thư viện `pdfplumber` để bóc tách từng trang văn bản: `page.extract_text()`.
  5. Chạy thuật toán so khớp regex ranh giới từ để trích xuất kỹ năng: `find_skills(text)`.
  6. Phân tích số năm/tháng kinh nghiệm: `find_experience_months(text)`.
  7. Tìm kiếm trường đại học / cao đẳng: `find_education(text)`.
- **Cú pháp kỹ thuật trọng tâm:**
  ```python
  # Regex ranh giới từ chống nhầm lẫn (ví dụ: tránh nhầm 'go' trong 'good', 'java' trong 'javascript')
  regex = re.compile(rf"(?<![a-z0-9]){re.escape(term)}(?![a-z0-9])")
  ```

---

### Module 2: Tính điểm phù hợp việc làm (Smart Job Matching)
- **Tập tin phụ trách:** [`ai/main.py`](file:///Users/hosynguyen/MiniLinkedInMobile/ai/main.py#L70-L93), [`server/src/services/ai/mockAdapter.js`](file:///Users/hosynguyen/MiniLinkedInMobile/server/src/services/ai/mockAdapter.js#L55-L75).
- **Mục tiêu:** Tính toán độ tương thích giữa bộ kỹ năng của ứng viên (trong CV/Hồ sơ) với yêu cầu tuyển dụng của doanh nghiệp, đưa ra điểm số (0 - 100%) và gợi ý học tập cải thiện hồ sơ.
- **Hàm thực thi:** `match_cv_job(request: MatchRequest) -> MatchResponse`.
- **Công thức thuật toán:**
  $$\text{Match Score} = \left\lfloor \frac{|\text{Matched Skills}|}{|\text{Required Skills}|} \times 100 \right\rfloor$$
- **Cấu trúc dữ liệu Response:**
  ```json
  {
    "score": 75,
    "matched_skills": ["flutter", "dart", "rest api"],
    "missing_skills": ["bloc"],
    "suggestion": "Bạn nên bổ sung hoặc học thêm về: bloc"
  }
  ```
- **Ứng dụng thực tế:** Điểm số này được lưu vào bảng `applications.matchScore` khi ứng viên nộp đơn và dùng để sắp xếp ứng viên tiềm năng giảm dần cho nhà tuyển dụng xem xét ([`recruiter.service.js`](file:///Users/hosynguyen/MiniLinkedInMobile/server/src/services/recruiter.service.js)).

---

### Module 3: Xây dựng từ điển kỹ năng (Skills Dictionary & Alias Mapping)
- **Tập tin phụ trách:** [`server/src/services/ai/skillsDictionary.js`](file:///Users/hosynguyen/MiniLinkedInMobile/server/src/services/ai/skillsDictionary.js), [`server/src/services/coach/roadmaps.js`](file:///Users/hosynguyen/MiniLinkedInMobile/server/src/services/coach/roadmaps.js#L12-L18).
- **Mục tiêu:** Chuẩn hóa hơn 50+ nhóm công nghệ lập trình, giải quyết triệt để bài toán biến thể tên gọi (ví dụ: `NodeJS`, `node.js`, `node js` đều quy về `nodejs`; `provider` và `riverpod` quy về nhóm `state management`).
- **Cấu trúc Từ điển:**
  ```javascript
  const SKILLS = [
    ["flutter"], ["dart"], ["git", "github", "gitlab"], ["firebase"],
    ["rest api", "restful", "restful api", "rest"], ["react", "reactjs", "react.js"],
    ["javascript", "es6"], ["html", "html5"], ["css", "css3"], ["typescript"],
    ["state management", "provider", "riverpod"],
    ["postgresql", "postgres", "psql"], ["docker"], ["kubernetes", "k8s"]
  ];
  ```
- **Hàm chuẩn hóa:** `canonicalSkill(name)` — tra cứu `ALIAS_TO_NAME` Map với độ phức tạp $O(1)$.

---

### Module 4: Đọc README và phân tích commit GitHub (Git AST & Evidence Scan)
- **Tập tin phụ trách:**
  - Trích xuất từ file gốc: [`server/src/services/skills/extractRules.js`](file:///Users/hosynguyen/MiniLinkedInMobile/server/src/services/skills/extractRules.js)
  - Đọc repo từ xa qua GitHub API: [`server/src/services/skills/githubReader.js`](file:///Users/hosynguyen/MiniLinkedInMobile/server/src/services/skills/githubReader.js)
  - Phân tích lịch sử commit: [`server/src/services/skills/commitScan.js`](file:///Users/hosynguyen/MiniLinkedInMobile/server/src/services/skills/commitScan.js)
- **Mục tiêu (ADR-0005 & ADR-0007):** Loại bỏ tình trạng sinh viên tự điền kỹ năng khống. Kỹ năng được đưa vào hồ sơ phải có bằng chứng kiểm chứng từ mã nguồn thực tế.
- **Cơ chế phân loại 3 tầng tin cậy (3-Tier Confidence):**
  1. **`evidenced` (Có bằng chứng xác thực)**: Đạt ngưỡng phân tích commit:
     - Tối thiểu **5 commit**.
     - Thêm ít nhất **200 dòng mã nguồn**.
     - Lịch sử phân bổ trải dài tối thiểu **14 ngày**.
     - Tối đa **3 commit/ngày** được tính (chống spam bot commit trong 1 ngày).
  2. **`self_claimed` (Tự khai báo)**: Kỹ năng có xuất hiện trong README hoặc dependencies nhưng chưa đủ ngưỡng commit trên.
  3. **`endorsed` (Đồng môn chứng thực)**: Kỹ năng được sinh viên khác xác nhận (chỉ hợp lệ khi người xác nhận đã đạt `evidenced` ở kỹ năng đó).
- **Các hàm phân tích file cấu hình AST:**
  - `parsePubspec(yaml)`: Bóc tách dependencies của Flutter/Dart từ `pubspec.yaml`.
  - `parsePackageJson(text)`: Bóc tách dependencies và devDependencies của Node.js / React.
  - `languagesOf(source)`: Phân tích tỷ lệ byte ngôn ngữ trong repo (chỉ tính ngôn ngữ $\ge 10\%$).

---

### Module 5: Triển khai dịch vụ AI (FastAPI Microservice & Adapter Pattern)
- **Tập tin phụ trách:** [`ai/main.py`](file:///Users/hosynguyen/MiniLinkedInMobile/ai/main.py), [`server/src/services/ai/aiClient.js`](file:///Users/hosynguyen/MiniLinkedInMobile/server/src/services/ai/aiClient.js), [`server/src/services/ai/httpAdapter.js`](file:///Users/hosynguyen/MiniLinkedInMobile/server/src/services/ai/httpAdapter.js).
- **Mục tiêu:** Cung cấp hạ tầng AI ổn định cao, không bao giờ làm gián đoạn (crash) luồng nghiệp vụ của ứng dụng di động ngay cả khi AI microservice gặp sự cố mạng.
- **Triển khai mô hình Adapter Pattern:**
  ```javascript
  async function withFallback(realFn, mockFn, label) {
    try {
      return await realFn();
    } catch (err) {
      if (isFallbackEnabled()) {
        console.warn(`[aiClient] ${label} — fallback to mock (${err.message})`);
        return await mockFn();
      }
      throw err;
    }
  }
  ```
- **Benchmark hiệu năng đạt được (Stress Test qua `ai/benchmark.py`):**
  - **Trích xuất PDF:** 298 req/s (độ trễ p50: 3.06ms).
  - **Endpoint POST `/analyze-cv`:** 216 req/s (độ trễ p50: 4.0ms).
  - **Endpoint POST `/match`:** 950 req/s (độ trễ p50: 0.92ms).

---

## 3. CƠ CHẾ HOẠT ĐỘNG CỦA AI CAREER COACH CHATBOT (ADR-0008)

Chatbot cố vấn kỹ năng của Atom được thiết kế dựa trên quyết định kiến trúc **ADR-0008** (*Skill Roadmap Coach Ollama*) giải quyết triệt để vấn đề lớn nhất của LLM trong giáo dục: **Hiện tượng bịa đặt (Hallucination) và Jailbreak**.

### 3 Lớp Hàng Rào Bảo Vệ (3-Tier Guardrails)

```
[Câu hỏi người dùng]
         │
         ▼
┌────────────────────────────────────────────────────────┐
│ Lớp 1: Phân loại ý định & Bộ lọc từ chối (intent.js)    │
│ ➔ Chặn: Câu hỏi lạc đề, hỏi code, hỏi lương, tấn công   │
└────────────────────────────────────────────────────────┘
         │ (Hợp lệ)
         ▼
┌────────────────────────────────────────────────────────┐
│ Lớp 2: Rules Engine Answer Generation (answers.js)     │
│ ➔ Bốc đúng dữ liệu thật từ DB + Lộ trình 6 bước        │
│ ➔ Ghép đúng 1 câu giọng mẫu (voiceHint)                │
└────────────────────────────────────────────────────────┘
         │ (Bản câu trả lời gốc bằng quy tắc)
         ▼
┌────────────────────────────────────────────────────────┐
│ Lớp 3: Hậu kiểm duyệt LLM Output (ollamaWriter.js)     │
│ ➔ Cấm LLM thêm bất kỳ kỹ năng hay con số lạ nào        │
│ ➔ Vi phạm hoặc quá 10s: Hủy bỏ, lấy bản quy tắc        │
└────────────────────────────────────────────────────────┘
         │
         ▼
[Phản hồi an toàn cho sinh viên]
```

1. **Lớp 1: Intent Classification & Refusal Filter** ([`intent.js`](file:///Users/hosynguyen/MiniLinkedInMobile/server/src/services/coach/intent.js)):
   - Nhận diện 8 loại câu hỏi nghiệp vụ: `missing_skills`, `evidence_status`, `job_gap`, `step_number`, `what_next`, `how_evidence`, `project_idea`, `time_estimate`.
   - Lập tức từ chối và trả về câu thông báo quy chuẩn nếu người dùng hỏi:
     - Câu hỏi ngoài lề (thời tiết, làm thơ, kể chuyện cười).
     - Hỏi viết code hộ (`Viết giúp tôi đoạn code...`).
     - Hỏi mức lương dev ở Việt Nam.
     - Tấn công Prompt Injection / Jailbreak (`Bỏ qua mọi hướng dẫn trước...`, `Từ giờ bạn là trợ lý tự do...`).
2. **Lớp 2: Rules Engine Grounding** ([`answers.js`](file:///Users/hosynguyen/MiniLinkedInMobile/server/src/services/coach/answers.js)):
   - Câu trả lời được tính toán 100% bằng logic deterministic dựa trên:
     - Kỹ năng đã có của sinh viên trong bảng `user_skills` và `cvs`.
     - Lộ trình 6 bước đã duyệt (`server/src/services/coach/roadmaps/`).
     - Kỹ năng yêu cầu của công việc đang ứng tuyển.
   - Bổ sung đúng 1 câu giọng điệu tương ứng với bước hiện tại ([`knowledge.js`](file:///Users/hosynguyen/MiniLinkedInMobile/server/src/services/coach/knowledge.js)) từ kho 500 câu chuẩn mực.
3. **Lớp 3: Post-Validation của Ollama** ([`ollamaWriter.js`](file:///Users/hosynguyen/MiniLinkedInMobile/server/src/services/coach/ollamaWriter.js)):
   - Mô hình LLM (Qwen 2B qua Ollama) chỉ đóng vai trò **viết lại câu văn cho tự nhiên**, xưng "mình" gọi "bạn".
   - **Hàm `acceptable(original, rewritten)` kiểm tra cực kỳ nghiêm ngặt**:
     - Độ dài vượt quá 150 từ $\rightarrow$ **Bỏ**.
     - Tự ý nhắc đến bất kỳ kỹ năng nào không có trong bản gốc $\rightarrow$ **Bỏ**.
     - Tự ý bịa thêm con số (thời gian, bước) không có trong bản gốc $\rightarrow$ **Bỏ**.
     - Khi bị bỏ hoặc timeout 10s, hệ thống lập tức hoàn trả bản trả lời của Rules Engine.

---

### Bộ 30 Kịch Bản Đánh Giá Chuẩn (eval-30.md)
Tất cả các trường hợp biên được kiểm thử định kỳ và tự động hóa qua test suite [`server/test/coach.test.js`](file:///Users/hosynguyen/MiniLinkedInMobile/server/test/coach.test.js):
- **Nhóm Dữ liệu (Câu 1–8)**: Hỏi về kỹ năng thiếu, kỹ năng có bằng chứng, độ mạnh kỹ năng.
- **Nhóm Lộ trình (Câu 9–14)**: Hỏi đang ở bước mấy, tuần này học gì, dự án chứng minh.
- **Nhóm Thiếu dữ liệu (Câu 15–17)**: Sinh viên chưa có CV, chưa chọn vị trí mục tiêu.
- **Nhóm Tiền đề sai (Câu 18–20)**: Sinh viên khẳng định sai ("Tôi có chứng chỉ Docker rồi đúng không?").
- **Nhóm Lạc đề (Câu 21–26)**: Hỏi thời tiết, làm thơ, hỏi lương.
- **Nhóm Tấn công Prompt Injection (Câu 27–30)**: Ra lệnh bỏ qua quy tắc, hỏi dữ liệu sinh viên khác, chèn lệnh trong CV.

---

## 4. TỔNG HỢP CÁC TICKET VÀ MINH CHỨNG MÃ NGUỒN

| Mã Ticket | Tên chức năng | Mô tả công việc kỹ thuật | Tập tin nguồn minh chứng |
| :--- | :--- | :--- | :--- |
| **Ticket AI-01** | CV PDF Skill Extractor | Bóc tách text PDF bằng `pdfplumber`, regex boundary, tìm số tháng kinh nghiệm và học vấn | [`ai/extractor.py`](file:///Users/hosynguyen/MiniLinkedInMobile/ai/extractor.py) |
| **Ticket AI-02** | Job Match Score Engine | Thuật toán so khớp kỹ năng ứng viên & Job, tính điểm %, tạo khuyến nghị bù đắp Skill Gap | [`ai/main.py`](file:///Users/hosynguyen/MiniLinkedInMobile/ai/main.py#L70-L93) |
| **Ticket AI-03** | Monorepo AI Client Adapter | Áp dụng Adapter Pattern, hỗ trợ chạy song song chế độ mock và real, tự động dự phòng | [`server/src/services/ai/aiClient.js`](file:///Users/hosynguyen/MiniLinkedInMobile/server/src/services/ai/aiClient.js) |
| **Ticket 04** | 3-Tier Skill Confidence | Xây dựng 3 mức độ tin cậy (`evidenced`, `self_claimed`, `endorsed`), chống gian lận kỹ năng | [`server/src/services/skills/confidence.js`](file:///Users/hosynguyen/MiniLinkedInMobile/server/src/services/skills/confidence.js) |
| **Ticket 06** | AI Consent & Privacy | Cơ chế bảo vệ quyền riêng tư: chỉ sinh viên đồng ý bật Consent mới kích hoạt quét AI | [`app/lib/features/consent/`](file:///Users/hosynguyen/MiniLinkedInMobile/app/lib/features/consent/) |
| **Ticket 10** | Custom Repo Upload Evidence | Nộp link repo GitHub bất kỳ, trích xuất AST dependencies và so khớp từ điển kỹ năng | [`server/src/services/skill.service.js`](file:///Users/hosynguyen/MiniLinkedInMobile/server/src/services/skill.service.js#L119-L150) |
| **Ticket Coach-01** | 4 Reviewed Roadmaps | Xây dựng 4 lộ trình chuẩn 6 bước: Flutter, Node.js, React, Data/AI kèm thời gian học | [`server/src/services/coach/roadmaps/`](file:///Users/hosynguyen/MiniLinkedInMobile/server/src/services/coach/roadmaps/) |
| **Ticket Coach-02** | Coach 3-Layer Guardrails | Triển khai 3 lớp bảo vệ: Lọc ý định $\rightarrow$ Rules Generation $\rightarrow$ Ollama Post-validation | [`server/src/services/coach/`](file:///Users/hosynguyen/MiniLinkedInMobile/server/src/services/coach/) |

---

## 5. CÂU HỎI THƯỜNG GẶP CỦA GIẢNG VIÊN & CÁCH PHẢN BIỆN

### Câu 1: Tại sao không dùng AI LLM trực tiếp để parse CV mà lại dùng Regex & pdfplumber?
- **Trả lời phản biện:**
  1. **Hiệu năng & Chi phí:** Regex và `pdfplumber` chạy mất chưa tới **4ms** mỗi CV và thông lượng đạt **300 req/s**, không tốn tiền API OpenAI/Gemini và chạy offline ổn định trên máy chủ.
  2. **Độ chính xác tuyệt đối (Deterministic):** Kỹ năng kỹ thuật là các danh từ riêng cụ thể. Việc dùng Regex với ranh giới từ `(?<![a-z0-9])` và từ điển chuẩn hóa triệt tiêu 100% rủi ro LLM tự "suy diễn" kỹ năng mà ứng viên không có.

### Câu 2: Làm sao để chứng minh sinh viên thực sự sở hữu kỹ năng lập trình chứ không phải chỉ chép vào CV?
- **Trả lời phản biện:**
  - Em đã thiết kế hệ thống **Bằng chứng commit GitHub** ([`commitScan.js`](file:///Users/hosynguyen/MiniLinkedInMobile/server/src/services/skills/commitScan.js)). Để đạt mức `evidenced`, sinh viên phải có tối thiểu 5 commit thực tế trải dài 14 ngày trên repo có sử dụng thư viện đó. Kỹ năng trong CV chỉ được phân loại ở mức tham khảo bước đầu.

### Câu 3: Chatbot có bị jailbreak hoặc rò rỉ dữ liệu người dùng khác không?
- **Trả lời phản biện:**
  - **Không thể bị rò rỉ:** Chatbot hoạt động theo cơ chế ADR-0008. Prompt gửi vào model không bao giờ chứa thông tin của sinh viên khác.
  - **Chống Jailbreak:** Lớp 1 ([`intent.js`](file:///Users/hosynguyen/MiniLinkedInMobile/server/src/services/coach/intent.js)) chặn đứng các mẫu câu "Bỏ qua chỉ dẫn", "In câu lệnh hệ thống". Thậm chí nếu vượt qua Lớp 1, Lớp 3 ([`ollamaWriter.js`](file:///Users/hosynguyen/MiniLinkedInMobile/server/src/services/coach/ollamaWriter.js)) sẽ kiểm tra nếu câu trả lời của model chứa bất kỳ từ khóa lạ nào ngoài dữ liệu đã được Rules Engine tính toán thì sẽ lập tức hủy bỏ kết quả và trả về câu từ chối an toàn.

---
*Tài liệu được cập nhật và kiểm thử thành công 100% trên cả 3 nền tảng (Node.js, Python FastAPI, Flutter Web/Mobile).*
