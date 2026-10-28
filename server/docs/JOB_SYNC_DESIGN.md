# Thiết kế Task Kéo Job (Job Sync)

> Kéo tin tuyển dụng thật từ 3 nguồn API bên ngoài, làm sạch, lọc trùng rồi lưu vào bảng `jobs` để phần Job của app hiển thị.
> Tài liệu chỉ mô tả thiết kế, chưa có code. Không chứa API key: key nằm trong `server/.env` (không commit).

---

## 1. Mục tiêu & phạm vi

**Mục tiêu:** có khoảng **100 job sạch**, đúng đối tượng **sinh viên IT / fresher tại Việt Nam**, mỗi job có **link ứng tuyển gốc** (`applyUrl`). Khi bấm "Ứng tuyển ngay", app mở bài đăng gốc trên LinkedIn, TopCV, ITviec hoặc web công ty.

**Trong phạm vi:**
- Gọi 3 nguồn: JSearch, SerpApi, Remotive.
- Làm sạch, chuẩn hóa, lọc trùng, lưu DB.
- Tự đóng job hết hạn.
- Ghi báo cáo mỗi lần chạy.

**Ngoài phạm vi:**
- Không có API công khai để kích hoạt việc kéo job. Chỉ chạy bằng script hoặc lịch định kỳ.
- Request của người dùng **không bao giờ** gọi trực tiếp tới 3 nguồn. App chỉ đọc từ DB qua các API `/jobs` hiện có.

---

## 2. Ba nguồn dữ liệu & vai trò

| Ưu tiên | Nguồn | Vai trò | Điểm mạnh | Điểm yếu |
|---|---|---|---|---|
| 1 | **JSearch** (RapidAPI) | Nguồn chính | Job VN thật (LinkedIn, TopCV, Indeed, Glassdoor). Dữ liệu có cấu trúc: lương, có remote không, link apply trực tiếp. Lọc được theo ngày đăng | Quota free tier thấp |
| 2 | **SerpApi** (Google Jobs) | Bổ sung | Phủ thêm ITviec, VietnamWorks, CareerViet, Glints | Quota **thấp nhất**. Lương chỉ có dạng chữ |
| 3 | **Remotive** | Phụ | Miễn phí, không cần key, 1 lần gọi lấy cả danh sách | Đa số là job quốc tế và senior. Điều khoản yêu cầu gọi thưa và ghi nguồn Remotive |

> Hạn mức quota chính xác xem trên dashboard của từng tài khoản. Thiết kế giả định **mỗi nguồn trả phí chỉ có vài trăm request/tháng**.

---

## 3. Chiến lược ưu tiên & quota

**Không kéo càng nhiều càng tốt.** Quota có hạn, và phần lớn kết quả thô là job senior hoặc không thuộc ngành IT. Mục tiêu là **đủ job sạch, tốn ít request nhất**.

### 3.1 Danh sách từ khóa có thứ tự

Từ khóa chạy theo thứ tự nhóm, từ trên xuống:

1. **Cấp độ + stack phổ biến:** "intern Flutter", "fresher Java", "junior Node.js", "thực tập sinh lập trình"...
2. **Công ty ưu tiên:** FPT Software, VNG, Shopee...
3. **Từ khóa rộng:** "lập trình viên", "software engineer Vietnam"...

Danh sách nằm trong file config, sửa được mà không phải động vào code.

### 3.2 Phân bổ nguồn

- **JSearch** chạy trước cho mọi từ khóa.
- **SerpApi** chỉ chạy cho những từ khóa mà JSearch trả về ít job sạch, để lấp phần thiếu.
- **Remotive** gọi 1 lần mỗi lượt. Job từ Remotive chiếm **tối đa ~20%** tổng số job hiển thị.

### 3.3 Ngân sách & điều kiện dừng

- Mỗi lượt có ngân sách request cố định cho từng nguồn, ví dụ JSearch ≤ 10, SerpApi ≤ 3. Hết ngân sách thì dừng nguồn đó.
- Đủ số job sạch mục tiêu thì dừng, không chạy tiếp các từ khóa còn lại.
- **Lần đầu kéo đầy đủ. Các lần sau chỉ kéo phần mới** (bộ lọc "đăng trong 3 ngày gần nhất"), nên chi phí mỗi lần sync về sau rất thấp.

### 3.4 Tự học hiệu suất từ khóa

Mỗi lượt lưu **tỉ lệ giữ lại** của từng từ khóa (số job sạch chia số job kéo về). Lần chạy sau, từ khóa có tỉ lệ thấp bị đẩy xuống cuối hàng. Từ khóa liên tục ra rác thì được đánh dấu để người phụ trách xem và bỏ.

---

## 4. Pipeline điều phối (Orchestrator)

Pipeline điều phối giống **quản đốc bếp**: không tự đi chợ, không tự nấu, chỉ giao việc theo thứ tự, xử lý sự cố và ghi sổ.

```
[Script / Lịch định kỳ]
        │
  ① Mở sổ ghi chép ............ ghi "lượt N bắt đầu lúc X"
        │
  ② Adapters (3 nguồn song song)
        │   • mỗi adapter gọi 1 nguồn, dịch về 1 định dạng chung (RawJob)
        │   • 1 nguồn lỗi/hết quota → ghi lỗi, các nguồn khác vẫn chạy
        ▼
  ③ Cleaner (từng job) ......... lọc & chuẩn hóa — xem mục 5
        │   • job bị loại được đếm kèm LÝ DO
        ▼
  ④ Lọc trùng .................. trong lượt + so với DB — xem mục 6
        ▼
  ⑤ Lưu DB (1 giao dịch) ....... có rồi → cập nhật, chưa có → thêm
        ▼
  ⑥ Dọn & chốt sổ
        • job 14 ngày không còn thấy trên nguồn → đóng
        • ghi báo cáo lượt chạy — xem mục 8
```

**Định dạng chung RawJob** (đầu ra của mọi adapter):
nguồn, mã job gốc, tiêu đề, tên công ty, logo, địa điểm, mô tả thô, chuỗi lương hoặc lương có cấu trúc, có remote không, danh sách link ứng tuyển, ngày đăng.

**Lý do tách thành từng phần:**
- Thêm nguồn thứ 4 chỉ cần viết thêm 1 adapter.
- Cleaner là các hàm thuần, test được bằng dữ liệu mẫu, không tốn quota.
- Một nguồn hỏng không làm hỏng cả lượt.
- Bước lưu DB nằm trong giao dịch, nên lỗi giữa chừng không để lại dữ liệu dở dang.

---

## 5. Cleaner: các bộ lọc & thuật toán

Các bước chạy theo thứ tự. **Bộ lọc rẻ chạy trước để loại sớm.**

| # | Bộ lọc | Thuật toán | Khi loại |
|---|---|---|---|
| 1 | **Còn mới** | So ngày đăng với hôm nay | Đăng quá 30 ngày |
| 2 | **Địa điểm** | JSearch/SerpApi: phải ở VN. Remotive: vùng tuyển phải là "Worldwide", "Asia" hoặc có "Vietnam" | Sinh viên VN không nộp được |
| 3 | **Link ứng tuyển** | Phân tích URL, chỉ nhận `https`. Nhiều link thì chọn theo ưu tiên: **web công ty > ITviec/TopCV > LinkedIn > trang tổng hợp khác** | Không có link hợp lệ |
| 4 | **Cấp độ** | Xem 5.1 | Không loại, chỉ phân loại |
| 5 | **Xóa HTML** | Dùng thư viện parse HTML (không dùng regex). Giải mã ký tự, gộp khoảng trắng, giữ xuống dòng giữa các đoạn | — |
| 6 | **Trích kỹ năng** | Xem 5.2 | — |
| 7 | **Đúng ngành IT** | Có ít nhất 2 kỹ năng, hoặc tiêu đề chứa từ khóa IT | Job sales, kế toán... lẫn vào kết quả |
| 8 | **Lương** | Xem 5.3 | Không loại, chỉ để trống |
| 9 | **Hình thức làm việc** | Cờ remote của nguồn, kết hợp từ khóa "remote / hybrid / từ xa" trong tiêu đề và mô tả | — |

### 5.1 Suy luận cấp độ

1. **Tiêu đề trước, rồi tới mô tả**, theo luật từ khóa:
   - "intern / thực tập / internship" → `intern`
   - "fresher / mới tốt nghiệp / graduate / entry level" → `fresher`
   - "junior" → `junior`
   - "mid / middle" → `mid`
   - "senior / Sr." → `senior`
   - "lead / manager / principal / architect / head / trưởng" → `lead`
2. Nếu tiêu đề không rõ, đọc **số năm kinh nghiệm** trong mô tả ("3+ years", "từ 3 năm", "at least 2 years"):
   - ≥ 5 năm → `senior`
   - 3–4 năm → `mid`
   - 1–2 năm → `junior`
   - 0 năm hoặc không yêu cầu → `fresher`
3. Vẫn không xác định được thì mặc định `junior`.

### 5.2 Trích kỹ năng

Dùng chung từ điển `server/src/services/ai/skillsDictionary.js` (tên chuẩn kèm các cách viết khác). Từ điển này cũng được dùng khi đọc CV, nên kỹ năng của job và của CV khớp nhau khi tính Match %.

- **Khớp cụm dài trước:** "react native" khớp trước "react", tránh bị đếm nhầm thành React.
- **Ranh giới từ:** "java" không được khớp vào "javascript". `c++`, `c#`, `.net`, `node.js` có luật ranh giới riêng.
- **Từ dễ nhầm** ("go", "rest", "spring", "ml"): chỉ nhận khi nằm trong tiêu đề, trong mục Yêu cầu, hoặc viết đúng dạng riêng ("Golang", "Go developer").
- **Chia theo mục của mô tả:**
  - Mục "Yêu cầu / Requirements" → `requiredSkills`
  - Mục "Ưu tiên / Nice to have / Plus" → `niceToHave`
- Kỹ năng lưu theo **tên chuẩn, chữ thường**.

### 5.3 Phân tích lương

1. **Ưu tiên dữ liệu có cấu trúc** (JSearch có min, max, kỳ trả).
2. Nếu không có thì phân tích chuỗi văn bản:
   - **Tiền tệ:** "₫, VND, triệu, tr" → VND. "$, USD" → USD.
   - **Đơn vị:** "k" nhân 1.000, "triệu / tr" nhân 1.000.000.
   - **Dạng:** khoảng ("15 – 25 triệu"), chỉ có trần ("up to $2000"), chỉ có sàn ("từ 10 triệu").
   - **Quy về theo tháng:** lương năm chia 12. Lương theo giờ thì bỏ trống.
3. "Thỏa thuận / Negotiable / Cạnh tranh" → để trống, **không đoán**.

---

## 6. Lọc trùng: 2 tầng

### Tầng 1: trùng tuyệt đối trong cùng nguồn

Khóa duy nhất là **(nguồn, mã job gốc)**. Kéo lại thì cập nhật bản cũ và làm mới thời điểm "lần cuối thấy". Không sinh bản trùng.

### Tầng 2: trùng giữa các nguồn

Ví dụ cùng một tin FPT có trên cả JSearch và SerpApi.

1. **Chuẩn hóa tên công ty:** bỏ dấu, chữ thường, bỏ "công ty, TNHH, cổ phần, JSC, Co., Ltd, Vietnam".
   Ví dụ: "Công ty TNHH FPT Software Việt Nam" → `fpt software`.
2. **Chuẩn hóa tiêu đề:** bỏ dấu, chữ thường, bỏ phần nhiễu: "[HN]", "- Hà Nội", "Lương upto 2000$", "Urgent", "Hot".
3. **Gom nhóm theo công ty (blocking):** chỉ so các job cùng công ty với nhau, không so mọi cặp.
4. **So độ giống tiêu đề bằng Jaccard trên tập từ:** số từ chung chia tổng số từ khác nhau.
   **≥ 80% và cùng thành phố** thì coi là trùng.
   - "flutter developer" và "flutter mobile developer" → 2/3 = 67% → **không trùng**
   - "senior java developer" và "java developer senior" → 100% → **trùng**
5. **Chọn bản giữ lại** bằng điểm:

   | Tiêu chí | Điểm |
   |---|---|
   | Có link ứng tuyển trực tiếp | +3 |
   | Có lương | +2 |
   | Mô tả dài hơn | +1 |
   | Đăng gần đây hơn | +1 |

   **Những trường bản thắng đang thiếu** (ví dụ lương) được lấy từ bản thua bù vào.
6. Áp dụng cho cả job **trong lượt hiện tại** lẫn job **đã có trong DB**.

---

## 7. Lưu trữ

Job được ghi vào bảng `jobs` mà phần Job của nhóm đang đọc. Bảng này hiện **chưa đáp ứng được** job từ nguồn ngoài:

| Vấn đề hiện tại | Đề xuất |
|---|---|
| `recruiterId` bắt buộc, nhưng job ngoài không có recruiter | Cho phép null *(cần chốt)* |
| Chưa có link ứng tuyển gốc | Thêm `applyUrl` |
| Chưa phân biệt nguồn | Thêm `source` (internal / jsearch / serpapi / remotive) và `externalId`, khóa duy nhất (source, externalId) |
| Lương không có đơn vị | Thêm `salaryCurrency` (VND / USD) |
| Chưa lọc trùng được giữa các nguồn | Thêm `dedupeKey` (có index) |
| Chưa biết job còn sống hay không | Thêm `lastSeenAt` |
| Enum cấp độ chỉ có intern / fresher / junior | Thêm `mid`, `senior`, `lead` (giữ tất cả job, không loại theo cấp độ) |

Thêm 1 bảng **nhật ký lượt chạy** (`job_sync_runs`) để lưu báo cáo ở mục 8.

**Ảnh hưởng tới code hiện có:**
- Chỗ nào đọc `job.recruiter` phải xử lý trường hợp null.
- API ứng tuyển nội bộ phải từ chối job có `source` khác `internal` (trả 409 kèm `applyUrl`).

---

## 8. Báo cáo mỗi lượt chạy

Mỗi lượt ghi một dòng nhật ký gồm:
- Thời điểm bắt đầu, kết thúc
- Theo từng nguồn: số request đã dùng, số job kéo về, lỗi (nếu có)
- Số job giữ lại, thêm mới, cập nhật, đóng do hết hạn
- Số job bị loại **theo từng lý do**: quá cũ, sai địa điểm, không có link, không phải IT, trùng
- Tỉ lệ giữ lại theo từng từ khóa (dùng cho mục 3.4)

---

## 9. Cấu trúc thư mục

Theo quy ước "mỗi tầng có folder riêng":

```
server/
├─ Thuật toán/JOB_SYNC_DESIGN.md   tài liệu này
├─ scripts/job-sync/
│  └─ sync-jobs                    lệnh chạy, có chế độ dry-run
├─ src/
│  ├─ services/job-sync/
│  │  ├─ adapters/                 jsearch, serpapi, remotive
│  │  ├─ cleaner/                  freshness, location, url, level, html, skills, salary, work-mode
│  │  ├─ dedupe/                   chuẩn hóa tên, jaccard, chấm điểm & gộp
│  │  ├─ keywords.config           danh sách từ khóa có thứ tự
│  │  └─ job-sync.service          bộ điều phối
│  └─ repositories/job-sync/       lưu job, ghi nhật ký lượt chạy
└─ test/job-sync/                  test cleaner/dedupe trên dữ liệu mẫu
```

Mỗi file tối đa 200 dòng, theo `CLAUDE.md`.

---

## 10. Cấu hình môi trường

Chỉ cần thêm **tên biến** vào `server/.env.example`. Giá trị thật chỉ để trong `server/.env`, không bao giờ commit.

| Biến | Dùng cho |
|---|---|
| `RAPIDAPI_KEY` | JSearch |
| `RAPIDAPI_HOST` | JSearch |
| `SERPAPI_KEY` | SerpApi |
| *(không cần)* | Remotive |

Không log key, không đưa key vào URL ghi ra log. Riêng SerpApi nhận key qua query string, nên khi log lỗi phải che key đi.

---

## 11. Vận hành

- **Chạy thử (dry-run):** in kết quả và báo cáo, **không ghi DB**.
- **Chạy thật:** ghi DB và ghi nhật ký.
- **Lưu cache dữ liệu thô:** lưu JSON thô vào `server/.cache/job-sync/` (thư mục này phải được gitignore), để chỉnh cleaner mà không tốn thêm quota.
- **Lịch:** giai đoạn đầu chạy tay. Khi đã ổn định, chạy tự động 1 lần mỗi ngày.

---

## 12. Rủi ro

| Rủi ro | Cách giảm |
|---|---|
| Hết quota giữa tháng | Ngân sách mỗi lượt, kéo phần mới, cache dữ liệu thô, nhật ký theo dõi số request |
| Nguồn đổi định dạng dữ liệu | Mỗi adapter cô lập. Lỗi chỉ ảnh hưởng 1 nguồn và hiện rõ trong báo cáo |
| Trích kỹ năng sai | Test trên bộ dữ liệu mẫu thật, bổ sung từ điển dần |
| Link ứng tuyển chết | Đóng job sau 14 ngày không còn thấy trên nguồn |
| Lộ key | Key chỉ nằm trong `.env`, che key khi log |

---

## 13. Cần chốt trước khi code

1. Ghi vào bảng `jobs` của nhóm bằng **Prisma** (đồng bộ với nhóm, khuyến nghị) hay **SQL thuần**?
2. `recruiterId` **cho phép null** (khuyến nghị) hay tạo một **user "bot"** làm recruiter?
3. Ngân sách request mỗi lượt và mục tiêu số job (mặc định ~100).

## 14. Thứ tự triển khai

1. Chốt mục 13, cập nhật schema và sửa các chỗ đang giả định `recruiter` luôn có. Test cũ phải vẫn pass.
2. Viết cleaner và dedupe kèm test trên dữ liệu mẫu.
3. Viết 3 adapter, chạy dry-run, đọc báo cáo, chỉnh từ khóa.
4. Chạy thật để có ~100 job.
5. Chặn ứng tuyển nội bộ cho job ngoài. Phía Flutter mở `applyUrl` bằng `url_launcher`.
6. Bật lịch chạy tự động.
