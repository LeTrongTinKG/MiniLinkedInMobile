# Review Xác minh Fix — B4 CV API (21-10-2026)

**Ngày:** 2026-10-21
**Nhánh:** feature/B6-backend-call-ai
**Commits:** `6753cf4` (security fix), `ba1ce8e` (refactor), `54c985a` (tests)
**Người review:** HoangAnh-ToiChoi

---

## Kết quả: 7/7 fix áp dụng đúng ✅

Tất cả vấn đề từ security review và code organization review ngày 21-10 đã được xử lý chính xác.

---

## Xác minh từng Fix

### Security Fixes (commit `6753cf4`)

**1. OR logic → AND logic — `upload.js:19`** ✅
```js
// Đã sửa đúng
if (!isPdfMime || !isPdfExt) { reject; }
// Comment giải thích rõ: "Phải thỏa mãn CẢ HAI điều kiện"
```

**2. Hardcode contentType — `storage.service.js:68`** ✅
```js
// Đã sửa đúng — không còn dùng client-supplied mimetype
contentType: "application/pdf",
```

**3. Sanitize `originalname` trước khi lưu DB — `cv.service.js:69-72`** ✅
```js
// Đã thêm 2 bước sanitize
.replace(/[^a-zA-Z0-9._\- ]/g, "_")
.slice(0, 128)
```

**4. Magic byte validation — `upload.js:57-66`** ✅
```js
// Đã thêm đúng vị trí, sau khi multer parse xong
const PDF_MAGIC = Buffer.from([0x25, 0x50, 0x44, 0x46]); // %PDF
if (!req.file.buffer.subarray(0, 4).equals(PDF_MAGIC)) { reject 400; }
```

---

### Code Organization Fixes (commit `ba1ce8e`)

**5. Thứ tự delete: DB trước, storage sau — `cv.service.js:147`** ✅
```js
// Đã sửa đúng thứ tự
await repo.deleteCv(cv.id);          // DB trước
await storage.deleteFile(cv.fileUrl); // storage sau, trong try/catch riêng
```

**6. Extract `fetchOwnedCv` — `cv.service.js:20-49`** ✅

Hàm helper được tách ra hoàn chỉnh: validate cvId, handle P2023, check not found, check ownership. Cả `setDefaultCv` và `deleteCv` đều gọi qua 1 dòng. Xóa hoàn toàn 20 dòng lặp.

**7. `findById` dùng `select` thay `include` — `cv.repository.js:35`** ✅
```js
// Đã sửa đúng
select: { ...cvSelectFields, _count: { select: { applications: true } } }
```

---

## Vấn đề mới phát sinh

### Minor

**Double sanitization tên file**

`cv.service.js` sanitize `originalname` → truyền vào `storageService.uploadFile` → `storage.service.js:48` sanitize lần 2 với regex khác (không giữ space và hyphen) và lowercase. Kết quả: `fileName` trong DB và path trên Supabase có thể khác nhau về case/ký tự. Không ảnh hưởng chức năng nhưng là design smell ẩn.

**Magic byte test không gọi middleware thật — `cv.controller.test.js:575`**

Test tự replicate if-condition trong test body thay vì gọi `uploadCvMiddleware` thật. Nếu condition bị xóa khỏi middleware, test vẫn pass. Nên đổi thành gọi middleware thật với mock stream.

**`fetchOwnedCv` export ra ngoài không cần thiết — `cv.service.js:172`**

Hàm nội bộ được export vì test gọi trực tiếp. Nên test qua hành vi của `setDefaultCv`/`deleteCv` thay vì gọi helper trực tiếp.

---

## Test Coverage

- Sanitize XSS filename ✅ — test real service code, verify từng ký tự
- Magic byte ⚠️ — test logic, không test middleware thật
- `fetchOwnedCv` direct ✅ — cover 401, 400 branches
- Buffer trong existing upload tests ✅ — đã cập nhật dùng `%PDF-1.4`
- Delete order — chưa test trường hợp storage fail nhưng DB đã xóa

---

## Verdict

**Fixes hoàn chỉnh.** Một gap nhỏ về test quality (magic byte test không invoke middleware thật) nhưng không block merge.
