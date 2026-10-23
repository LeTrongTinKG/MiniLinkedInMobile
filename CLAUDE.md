# CLAUDE.md — MiniLinkedIn Mobile

Đây là dự án đồ án nhóm. Claude vừa viết code cho **mình** vừa thường xuyên **review code của đồng đội**. Đọc file này trước mọi thao tác.

---

## Dự án là gì

App mobile Flutter giúp sinh viên IT biết CV của mình hợp bao nhiêu % với tin tuyển dụng, thiếu kỹ năng gì, và ứng tuyển ngay trong app. Backend Node/Express, AI Python FastAPI, DB PostgreSQL trên Supabase.

**Scope hiện tại (còn ~2 tuần):** Auth, CV, Job, Application (task B2–B9, F1–F8). Các task B10–B13 và F12–F15 tạm hoãn.

---

## Cấu trúc monorepo

```
app/          Flutter mobile app
server/       Node.js + Express backend (CommonJS, không dùng TypeScript)
ai/           Python FastAPI AI service (team riêng)
review/       File review code hàng ngày
```

---

## Quy tắc code — BẮT BUỘC

### Giới hạn file

- **Tối đa 200 dòng mỗi file.** File vượt ngưỡng → tách ngay, không để sau.
- Mỗi file chỉ làm một việc (Single Responsibility).

### Không viết lại code đã có

Trước khi viết logic mới, tìm xem đã có chưa:
- Utility: `server/src/utils/`
- Error handling: `server/src/middleware/error.js` — dùng `ApiError` và `asyncHandler`
- Auth: `server/src/middleware/auth.js` — dùng `authenticate`, `authorize`, `optionalAuthenticate`
- Response: `server/src/controllers/response.js` — dùng `sendSuccess`
- Prisma client: `server/src/lib/prisma.js`
- AI client: `server/src/services/ai/aiClient.js` — **không import mockAdapter hay httpAdapter trực tiếp**

### Tái sử dụng

- Hàm dùng 2 nơi trở lên → extract ra utils hoặc module riêng.
- Pattern lặp trong cùng file → extract thành helper function ngay trong file đó.
- Test helper (dispatch, createMockRes) → `server/test/helpers.js`.

### Đặt tên

- File: `kebab-case.js` (server), `snake_case.dart` (app)
- Hàm/biến: `camelCase`
- Constant: `UPPER_SNAKE_CASE`
- Commit: Conventional Commits tiếng Việt — `feat(server): thêm endpoint upload CV`

---

## Kiến trúc server (3 tầng)

```
routes/       Chỉ khai báo path + middleware + controller
controllers/  Chỉ đọc req, gọi service, gọi sendSuccess — không có business logic
services/     Toàn bộ business logic, validation nghiệp vụ
repositories/ Chỉ chứa Prisma query — không có logic
```

**Vi phạm phổ biến cần tránh:**
- Controller gọi thẳng repository (bỏ qua service)
- Service import repository của module khác thay vì nhận qua tham số
- Repository chứa if/else business logic

---

## API conventions (từ API plan)

```
Base URL: /api/v1
Auth:     Authorization: Bearer <accessToken>  (token 7 ngày)
JSON:     camelCase
Thời gian: ISO 8601 UTC

Response thành công:  { "data": {...}, "meta": { "page", "limit", "total" } }
Response lỗi:         { "error": { "code": "JOB_NOT_FOUND", "message": "..." } }

HTTP status: 200 OK, 201 Created, 400 Bad Request, 401 Unauthorized,
             403 Forbidden, 404 Not Found, 409 Conflict, 500 Server Error
```

Upload file: `multipart/form-data`. CV chỉ nhận PDF ≤ 5MB (kiểm tra cả magic bytes `%PDF`).

---

## AI service contract (đừng đổi tùy tiện)

```
POST /analyze-cv  (multipart: file PDF)
→ { "skills": [...], "education": "...", "experience_months": 6 }

POST /match
→ { "score": 72, "matched_skills": [...], "missing_skills": [...], "suggestion": "..." }
```

App không gọi AI trực tiếp. Mọi request đi qua Node.js backend.

**Khi chưa có AI thật:** dùng mock qua `AI_MODE=mock` trong `.env`. Không hardcode import `mockAdapter` trong service layer.

---

## Git workflow

```
main          Code ổn định — KHÔNG push trực tiếp
dev           Nhánh tích hợp — merge từ feature branches
feature/B*    Backend tasks
feature/F*    Frontend tasks
review/DD-MM-YYYY   File review hàng ngày
```

**Branch B8 và các task seed/data:** branch từ nhánh feature chứa schema mới nhất (hiện tại là `feature/B6-backend-call-ai`), không từ `dev` vì dev chưa có CV model.

Trước khi tạo PR: `git rebase origin/dev` để cập nhật, resolve conflict nếu có.

---

## Quy trình review code

Review hàng ngày. File review lưu ở `review/YYYY-MM-DD-be-review.md` (backend) hoặc `review/YYYY-MM-DD-fe-review.md` (frontend), commit lên nhánh `review/DD-MM-YYYY`.

### Spawn agent để review

Dùng 2 agent song song khi review nhiều ngày:

```
Agent 1: Review fixes/refactor của ngày trước — xác minh đúng không
Agent 2: Review feature mới của ngày hiện tại — chức năng + tách file
```

Mỗi agent nhận: mô tả task, SHA range (`git diff BASE..HEAD`), danh sách file cần đọc, kết quả test.

### Checklist review backend

- [ ] File nào > 200 dòng không?
- [ ] Logic nào bị lặp có thể extract không?
- [ ] Controller có business logic không?
- [ ] Repository có if/else không?
- [ ] Import `mockAdapter` trực tiếp trong service không?
- [ ] `delete` storage trước hay sau `delete` DB?
- [ ] Test có gọi middleware/service thật không (không replicate logic trong test)?
- [ ] Ownership check trước mọi write operation?

### Checklist review frontend (Flutter)

- [ ] Widget > 200 dòng không? Tách thành widget nhỏ hơn.
- [ ] Logic gọi API nằm trong provider/datasource, không phải trong Widget build?
- [ ] Hard-code string không? Dùng constant.
- [ ] Dispose controller, subscription chưa?

---

## Testing

**Server:** Node.js built-in test runner (`node:test`). Chạy: `cd server && npm test`.

- Test file: `server/test/<module>.controller.test.js`
- Shared helpers: `server/test/helpers.js` — import `dispatch`, `createMockRes` từ đây, không khai báo lại
- Mock DB qua Prisma mock, mock AI qua `aiClient` injection — không mock module trực tiếp
- Test phải gọi middleware/service thật, không replicate logic trong test body

**Flutter:** `cd app && flutter test`

---

## Bảo mật — không bao giờ bỏ qua

- Validate file upload: MIME type + extension + **magic bytes** (4 byte đầu)
- `contentType` lên Supabase: hardcode `"application/pdf"`, không dùng `file.mimetype`
- Sanitize `originalname` trước khi lưu DB: `replace(/[^a-zA-Z0-9._\- ]/g, "_").slice(0, 128)`
- Ownership check (`cv.userId !== userId`) trước mọi PATCH/DELETE
- Xóa DB row trước, xóa storage sau (DB có thể rollback, storage không thể)
- Không log token, password, hoặc PII

---

## Môi trường

```
server/.env.example   Xem để biết biến cần thiết
DATABASE_URL          PostgreSQL Supabase
SUPABASE_URL + KEY    Storage
JWT_SECRET            Token signing
AI_MODE               "mock" | "http"
AI_FALLBACK_TO_MOCK   "true" | "false"
```

Không commit file `.env`. Không hardcode secret trong code.
