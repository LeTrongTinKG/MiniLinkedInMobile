# Security Review — CV Upload API (feature/B4-cv-api)

**Ngày:** 2026-10-21
**Nhánh:** feature/B4-cv-api
**Người review:** HoangAnh-ToiChoi

---

## Phạm vi review

Các file liên quan đến tính năng upload và quản lý CV:

- `server/src/middleware/upload.js`
- `server/src/services/cv.service.js`
- `server/src/services/storage/storage.service.js`
- `server/src/repositories/cv.repository.js`
- `server/src/controllers/cv.controller.js`
- `server/src/routes/cv.routes.js`

---

## Kết quả: Không có lỗ hổng khai thác được trong context hiện tại

Toàn bộ frontend là Flutter (native widgets, không phải HTML), nên các attack vector XSS không có browser context để thực thi. Tuy nhiên có **3 code smells bảo mật nghiêm trọng** sẽ trở thành lỗ hổng thật nếu team thêm web frontend.

---

## Code smells cần sửa

### 1. OR logic trong file filter — `upload.js:17`

**Vấn đề:** File chỉ cần thỏa một trong hai điều kiện (MIME *hoặc* extension) là qua được.

```js
// Hiện tại — sai
if (!isPdfMime && !isPdfExt) { reject; }

// Đúng — phải thỏa cả hai
if (!isPdfMime || !isPdfExt) { reject; }
```

**Rủi ro nếu có web:** Attacker upload file HTML đặt tên `.pdf` → qua filter → Stored XSS.

---

### 2. Client-controlled MIME type đẩy vào Supabase — `storage.service.js:68`

**Vấn đề:** `file.mimetype` từ HTTP header (client tự khai) được dùng làm `contentType` khi upload lên Supabase. Supabase lưu và serve lại đúng Content-Type đó.

```js
// Hiện tại — nguy hiểm
contentType: mimeType,  // client kiểm soát hoàn toàn

// Fix — hardcode
contentType: "application/pdf",
```

**Rủi ro nếu có web:** Attacker set `Content-Type: text/html` → Supabase serve HTML → browser execute script → Stored XSS.

---

### 3. `file.originalname` lưu thẳng vào DB không sanitize — `cv.service.js:49`

**Vấn đề:** Tên file từ multipart header được lưu nguyên vào DB không qua xử lý.

```js
// Hiện tại — nguy hiểm
fileName: file.originalname,

// Fix
fileName: file.originalname
  .replace(/[^a-zA-Z0-9._\- ]/g, "_")
  .slice(0, 128),
```

**Rủi ro nếu có web:** Attacker đặt tên file là `"><img src=x onerror=alert(1)>.pdf` → lưu vào DB → web frontend render không escape → Second-order XSS.

---

### 4. Thiếu magic byte validation — `upload.js`

**Vấn đề:** Server không kiểm tra nội dung thực của file, chỉ tin vào MIME type và tên file do client gửi lên — cả hai đều có thể giả mạo dễ dàng bằng `curl`.

```js
// Thêm vào uploadCvMiddleware sau khi có req.file
const PDF_MAGIC = Buffer.from([0x25, 0x50, 0x44, 0x46]); // %PDF
if (!req.file.buffer.slice(0, 4).equals(PDF_MAGIC)) {
  return next(new ApiError(400, "INVALID_FILE_TYPE", "File không phải định dạng PDF hợp lệ"));
}
```

---

## Kiến thức nền liên quan

### Tại sao không dùng `application/pdf` cho toàn bộ request?

- `multipart/form-data` = cách đóng gói nhiều field (file + metadata) trong một request
- `application/pdf` = loại nội dung bên trong một part cụ thể
- Raw binary (`Content-Type: application/pdf` trên request) chỉ gửi được mỗi file, không kèm metadata

### Tại sao mobile an toàn hơn web với XSS?

Flutter render bằng native widgets / CanvasKit — không có HTML parser. Payload `<script>` chỉ hiển thị như text literal, không được execute.

### Làm sao kẻ tấn công biết API endpoint?

1. **Decompile APK** bằng `apktool` / `jadx` → đọc được base URL và toàn bộ endpoint trong code
2. **MITM proxy** (Charles Proxy, Burp Suite) → chặn traffic → thấy toàn bộ request/response
3. **Đọc repo public** → `.env.example`, README

→ API endpoint trên mobile **không thể giấu được**. Server phải validate mọi thứ, không tin client.

---

## Điểm tốt trong code hiện tại

- Authentication + Authorization đầy đủ: `authenticate` + `authorize("student")` trên toàn bộ CV routes
- Ownership check trước mọi thao tác write (`cv.userId !== userId`)
- UUID ngẫu nhiên trong tên file trên Storage → không đoán được path
- `sanitizeFileName` trong storage service ngăn path traversal
- Graceful degradation khi AI service lỗi
- Transaction khi set default CV

---

## Ưu tiên fix (Security)

| # | Issue | File | Độ ưu tiên |
|---|---|---|---|
| 1 | Hardcode `contentType: "application/pdf"` | `storage.service.js:68` | Cao |
| 2 | Đổi OR → AND trong file filter | `upload.js:17` | Cao |
| 3 | Sanitize `originalname` trước khi lưu DB | `cv.service.js:49` | Cao |
| 4 | Thêm magic byte validation | `upload.js` | Trung bình |

---

# Code Review — Tổ chức Code CV API

## Điểm tốt

- **3-layer sạch:** Controller không có business logic, service chứa toàn bộ rule, repository là pure DB access
- **Dependency injection đúng cách:** Mọi hàm service nhận `repo`, `storage`, `ai` là optional param → test được mà không monkey-patch module
- **Transaction cho setDefault:** `repo.setDefaultCv` wrap 2 bước "clear all + set one" trong `$transaction` → không bị mất trạng thái khi crash
- **Ownership check nhất quán** ở cả `setDefaultCv` và `deleteCv`
- **Application-use guard** kiểm tra `_count.applications > 0` trước khi xóa → bảo toàn lịch sử ứng tuyển
- **44/44 tests pass**

---

## Vấn đề tìm được

### Critical — phải sửa ngay

**1. Xóa storage trước khi xóa DB row** — `cv.service.js:139-143`

Nếu `repo.deleteCv` fail sau khi `storage.deleteFile` đã thành công → DB còn row nhưng file đã mất → URL bị broken vĩnh viễn.

```js
// Hiện tại — nguy hiểm
await storage.deleteFile(cv.fileUrl);  // thành công
await repo.deleteCv(cv.id);           // nếu fail → orphaned row

// Fix — đổi thứ tự
await repo.deleteCv(cv.id);           // DB rollback được nếu fail
await storage.deleteFile(cv.fileUrl); // storage làm sau
```

---

### Important — nên sửa

**2. Code lặp: fetch + ownership check** — `cv.service.js:70-95` và `cv.service.js:100-137`

`setDefaultCv` và `deleteCv` có chung 20 dòng logic y hệt nhau. Nên extract ra hàm riêng:

```js
async function fetchOwnedCv(userId, cvId, repo) {
  if (typeof cvId !== "string" || cvId.trim().length === 0)
    throw new ApiError(400, "INVALID_CV_ID", "ID CV không hợp lệ");

  let cv;
  try {
    cv = await repo.findById(cvId.trim());
  } catch (error) {
    if (error?.code === "P2023") throw new ApiError(404, "CV_NOT_FOUND", "Không tìm thấy CV");
    throw error;
  }

  if (!cv) throw new ApiError(404, "CV_NOT_FOUND", "Không tìm thấy CV");
  if (cv.userId !== userId) throw new ApiError(403, "FORBIDDEN", "Bạn không có quyền thao tác trên CV này");
  return cv;
}
```

**3. `findById` dùng `include` thay vì `select`** — `cv.repository.js:32`

Tất cả hàm khác dùng `select: cvSelectFields`, riêng `findById` dùng `include` → trả về tất cả fields không kiểm soát. Sửa thành:

```js
return db.cv.findUnique({
  where: { id },
  select: {
    ...cvSelectFields,
    _count: { select: { applications: true } },
  },
});
```

---

### Minor

- `getMyCvs` check `userId` falsy nhưng 3 hàm còn lại không check → không nhất quán
- Check `file.buffer` trong service bị trùng với middleware (vô hại nhưng thừa)
- 2 test cuối không test middleware thật, chỉ test error handler — nên đổi label hoặc viết lại

---

## Verdict

**Chưa merge được.** Cần sửa issue #1 (thứ tự delete) và #2 (extract `fetchOwnedCv`) trước khi merge.
