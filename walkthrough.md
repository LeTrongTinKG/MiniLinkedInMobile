# Walkthrough B9 — Phân quyền 401/403/409 & sửa backend Application

Dành cho team lead review. Plan gốc: `backend-auth-and-fixes-plan.md` (task B9).

| Mục | Giá trị |
| --- | --- |
| Nhánh | `feature/B9-application-auth-and-fixes` |
| Base | `dev` @ `9392f0f` |
| Remote | https://github.com/LeTrongTinKG/MiniLinkedInMobile |
| Người làm | agent (Cursor) theo plan B9 |
| Ngày | 28/10/2026 |

---

## 1. Mục tiêu đã chốt từ plan

1. Siết state machine đơn ứng tuyển (không duyệt đơn đã rút / đã có kết quả).
2. AI match lỗi → lưu `matchScore: null`, không giả `0`.
3. Service layer không import `mockAdapter`; chỉ đi qua `aiClient`.
4. Rút gọn `application.repository.js` dưới 200 dòng.
5. Tách `application.controller.test.js` (1114 dòng) thành 5 file theo nghiệp vụ.
6. Phủ ma trận 401 / 403 / 409 / 400 / 404 cho các endpoint Application.

Hai endpoint rút đơn và xem chi tiết đã có sẵn trên `dev` (`PATCH /applications/:id/withdraw`, `GET /recruiter/applications/:id`). Phần này không viết lại, chỉ bổ sung ràng buộc và test.

---

## 2. Kết quả nghiệp vụ

### 2.1. State machine

Bảng chuyển trạng thái nằm ở `server/src/utils/application.util.js`:

| Từ | Được phép sang |
| --- | --- |
| `submitted` | `viewed`, `shortlisted`, `accepted`, `rejected` |
| `viewed` | `shortlisted`, `accepted`, `rejected` |
| `shortlisted` | `accepted`, `rejected` |
| `accepted` / `rejected` / `withdrawn` | không chuyển tiếp |

`updateApplicationStatus` gọi `assertCanUpdateStatus` **sau** khi đã check role + ownership:

| Tình huống | HTTP | `error.code` |
| --- | --- | --- |
| Đơn `withdrawn` | 400 | `CANNOT_UPDATE_WITHDRAWN` |
| Đơn `accepted` hoặc `rejected` | 400 | `CANNOT_UPDATE_FINALIZED` |
| Chuyển không hợp lệ (vd. `shortlisted` → `viewed`) | 400 | `INVALID_STATUS_TRANSITION` |
| Status body không thuộc `viewed/shortlisted/accepted/rejected` | 400 | `INVALID_STATUS` |

Sinh viên rút đơn giữ nguyên rule cũ: chỉ `submitted/viewed/shortlisted`; đã rút → `ALREADY_WITHDRAWN`; đã có kết quả → `CANNOT_WITHDRAW`.

### 2.2. Fallback AI

| Chỗ | Trước | Sau |
| --- | --- | --- |
| `POST /applications` | `matchScore: 0` khi AI lỗi | `matchScore: null` |
| `GET /jobs/:id` match cho student | fallback `mockAdapter` | `match: null` |
| `POST /cvs` | fallback `mockAdapter` | `extractedSkills: null`, upload vẫn 201 |

`cv.service` và `job.service` không còn `require("./ai/mockAdapter")`. Mock chỉ còn trong `aiClient` (đúng CLAUDE.md).

### 2.3. Ma trận phân quyền đã test

| Endpoint | 401 | 403 | 409 | 400 / 404 |
| --- | --- | --- | --- | --- |
| `POST /api/v1/applications` | thiếu token | recruiter; dùng CV người khác | ứng tuyển lần 2 | thiếu jobId / job closed / chưa có CV / job 404 |
| `GET /api/v1/applications/my` | thiếu token | recruiter | — | danh sách đúng chủ sở hữu |
| `PATCH /api/v1/applications/:id/withdraw` | thiếu token | recruiter; rút đơn SV khác | — | đã rút; đã accepted/rejected; 404 |
| `GET /api/v1/recruiter/jobs/:jobId/applications` | thiếu token | student; recruiter không phải chủ job | — | job 404; sort `matchScore` desc; alias `?jobId=` |
| `GET /api/v1/recruiter/applications/:id` | thiếu token | recruiter không phải chủ job | — | 404; `submitted` → `viewed`; giữ viewed/shortlisted/accepted |
| `PATCH /api/v1/recruiter/applications/:id/status` | thiếu token | recruiter khác | — | withdrawn / finalized / status sai / transition sai / duyệt hợp lệ |

---

## 3. Clean code / SOLID / CLAUDE.md

- Controller không thêm business logic; state machine nằm ở util + service.
- Repository chỉ query Prisma; helper `withStatus` gom điều kiện lọc, file còn **132 dòng** (trước 201).
- Service không import repository module khác mới; `assertCanUpdateStatus` tách khỏi `application.service.js` để file đúng **200 dòng**.
- Test gọi middleware + controller thật qua `dispatch` (`server/test/helpers.js`); mock Prisma inject qua `require.cache`, không replicate logic trong body test.
- File mới đều kebab-case, dưới 200 dòng.

### Số dòng file đụng tới

| File | Dòng |
| --- | --- |
| `src/utils/application.util.js` | 116 |
| `src/services/application.service.js` | 200 |
| `src/repositories/application.repository.js` | 132 |
| `src/services/cv.service.js` | 171 |
| `src/services/job.service.js` | 192 |
| `test/application.harness.js` | 144 |
| `test/application.prisma-mock.js` | 154 |
| `test/application.apply.test.js` | 151 |
| `test/application.recruiter.test.js` | 108 |
| `test/application.detail.test.js` | 84 |
| `test/application.status.test.js` | 107 |
| `test/application.withdraw.test.js` | 93 |

### File vẫn > 200 dòng (có từ trước, không nằm trong scope B9)

- `server/src/services/auth.service.js` (283)
- `server/test/auth.controller.test.js` (417)
- `server/test/cv.controller.test.js` (660)
- `server/test/job.controller.test.js` (567)

---

## 4. Kết quả chạy test

Lệnh:

```bash
cd server
npm test
```

Kết quả lần chạy xác nhận (28/10/2026):

```
ℹ tests 102
ℹ suites 0
ℹ pass 102
ℹ fail 0
ℹ cancelled 0
ℹ skipped 0
ℹ todo 0
```

Một số case mới đáng chú ý (đều PASS):

- `POST /applications lưu matchScore null khi AI lỗi`
- `PATCH .../status 400 CANNOT_UPDATE_WITHDRAWN`
- `PATCH .../status 400 CANNOT_UPDATE_FINALIZED` (accepted và rejected)
- `PATCH .../status 400 khi chuyển shortlisted -> viewed`
- `GET /recruiter/applications/:id tự chuyển submitted -> viewed`
- `POST /cvs lưu extractedSkills null khi AI service lỗi, không trả 500`
- `GET /jobs/:id gán match null khi AI service ném lỗi, không trả về 500`

Log stderr có sẵn từ trước (không fail test):

- pdfjs-dist cảnh báo thiếu `canvas` khi mock đọc PDF.
- `GET /jobs/:id` case DB `P1001` in `Unhandled Error` nhưng assertion 500 vẫn PASS.

---

## 5. File thay đổi (commit trên nhánh này)

### Sửa

- `server/src/utils/application.util.js` — bảng chuyển trạng thái + `assertCanUpdateStatus`
- `server/src/services/application.service.js` — `matchScore` null; gọi state machine khi recruiter cập nhật status
- `server/src/repositories/application.repository.js` — rút gọn query, `withStatus`
- `server/src/services/cv.service.js` — bỏ `mockAdapter`, inject `aiClient`, AI lỗi → `extractedSkills: null`
- `server/src/services/job.service.js` — bỏ `mockAdapter`, AI match lỗi → `match: null`
- `server/test/cv.controller.test.js` / `job.controller.test.js` — assertion theo hành vi mới

### Thêm

- `server/test/application.harness.js`
- `server/test/application.prisma-mock.js`
- `server/test/application.apply.test.js`
- `server/test/application.recruiter.test.js`
- `server/test/application.detail.test.js`
- `server/test/application.status.test.js`
- `server/test/application.withdraw.test.js`
- `walkthrough.md` (file này)

### Xóa

- `server/test/application.controller.test.js` (1114 dòng)

`server/package-lock.json` có diff 1 dòng sẵn trên máy (`"peer": true`) — **không** nằm trong commit B9 vì không phát sinh từ task này.

---

## 6. Cách team lead review nhanh

```bash
git fetch origin
git checkout feature/B9-application-auth-and-fixes
cd server
npm test
```

Đọc theo thứ tự:

1. `server/src/utils/application.util.js` — rule nghiệp vụ
2. `server/src/services/application.service.js` — apply + update status
3. `server/test/application.status.test.js` và `application.apply.test.js` — case mới

Không cần DB / Render để chạy unit test (Prisma mock in-memory).

---

## 7. Commit & push

| | |
| --- | --- |
| Commit | `c96de0a` |
| Message | `feat(server): siết phân quyền Application, state machine và fallback AI null` |
| Files | 16 files, +1116 / −1223 |
| Nhánh remote | `origin/feature/B9-application-auth-and-fixes` |

```
c96de0a feat(server): siết phân quyền Application, state machine và fallback AI null
```

Đề xuất PR:

- Title: `[B9] Siết phân quyền Application, state machine và fallback AI null`
- Base: `dev`
- So sánh: https://github.com/LeTrongTinKG/MiniLinkedInMobile/compare/dev...feature/B9-application-auth-and-fixes
