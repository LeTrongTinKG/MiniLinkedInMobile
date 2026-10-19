# Auth Code Review — Hướng Fix

---

## CODE (auth controller / service / repository)

---

### 1. Thông tin nội bộ bị lộ ra ngoài

**File:** `server/src/repositories/user.repository.js` — dòng 3–12

**Vấn đề xảy ra như thế nào:**
Khi user đăng ký hoặc đăng nhập thành công, app nhận về thông tin user. Nhìn vào response thực tế sẽ thấy kèm theo 2 field `loginAttempts` và `loginLockedUntil` — đây là thông tin hệ thống dùng để theo dõi nội bộ, user không cần biết và không nên biết. Giống như khi bạn đăng ký tài khoản ngân hàng, họ không trả về cho bạn biết hệ thống đang theo dõi bạn bao nhiêu lần đăng nhập sai.

**Hướng fix:**
Tách làm 2 danh sách field riêng:
- Danh sách **trả ra ngoài cho client** — chỉ gồm những gì app cần hiển thị: tên, email, role, ảnh...
- Danh sách **dùng nội bộ** — gồm thêm `loginAttempts`, `loginLockedUntil`, `passwordHash`, `googleId` — chỉ dùng bên trong server khi cần kiểm tra, không bao giờ gửi ra ngoài

---

### 2. Đếm sai số lần đăng nhập sai khi có nhiều người cùng thử

**File:** `server/src/repositories/user.repository.js` — hàm `incrementLoginAttempts`, dòng 57–68

**Vấn đề xảy ra như thế nào:**
Giả sử tài khoản đang có 4 lần sai, chỉ cần thêm 1 lần nữa là bị khóa. Nhưng nếu ai đó dùng tool tấn công gửi 2 request sai cùng một lúc — cả 2 request đều đọc được số 4, cả 2 cùng tính ra 5, cùng ghi 5 vào DB. Kết quả vẫn là 5 thay vì 6, mất đi 1 lần đếm. Với kịch bản tấn công hàng loạt, điều này có thể khiến tài khoản không bao giờ bị khóa dù đã sai đủ số lần.

**Hướng fix:**
Thay vì tự tính rồi ghi, để DB tự cộng. DB xử lý từng thao tác tuần tự nên không bao giờ bị ghi đè lẫn nhau. Prisma hỗ trợ cú pháp `{ increment: 1 }` cho đúng mục đích này. Sau khi tăng, đọc lại giá trị mới từ kết quả trả về để kiểm tra có cần khóa tài khoản không.

---

### 3. User có thể mất đăng nhập oan vì server gặp sự cố

**File:** `server/src/services/auth.service.js` — hàm `refresh`, dòng 225–237

**Vấn đề xảy ra như thế nào:**
Khi app tự động lấy token mới (refresh), server làm 2 việc: xóa token cũ, rồi tạo token mới. Nếu sau khi xóa token cũ xong mà server bị mất kết nối, hết điện, hoặc DB bị timeout — token cũ đã mất, token mới chưa kịp tạo. User mở app lên sẽ thấy bị đăng xuất, dù họ không làm gì sai.

**Hướng fix:**
Gói 2 thao tác đó vào cùng 1 "giao dịch" (transaction) — tức là bảo DB: "2 việc này phải cùng thành công hoặc cùng thất bại, không có chuyện 1 thành 1 bại". Nếu có sự cố giữa chừng, DB tự động hoàn tác lại như chưa có gì xảy ra — token cũ vẫn còn, user không bị mất đăng nhập.

---

### 4. Đăng xuất rồi nhưng tài khoản vẫn bị dùng được trong vòng 1 tiếng

**File:** `server/src/services/auth.service.js` — hàm `logout`, dòng 240–246
**File:** `server/src/middleware/auth.js` — hàm `authenticate`

**Vấn đề xảy ra như thế nào:**
Khi user bấm đăng xuất, server xóa refresh token khỏi DB — đúng. Nhưng access token thì không lưu ở đâu nên không thể xóa được. Access token sống 1 tiếng, nếu trong 1 tiếng đó có ai đó lấy được access token này (ví dụ thiết bị bị mất, bị cài phần mềm theo dõi), họ vẫn gọi được API bình thường dù user đã đăng xuất rồi.

**Hướng fix — dùng số phiên bản token (`tokenVersion`):**

Cách hoạt động giống như "đổi khóa nhà" — mỗi khi đăng xuất là đổi khóa, chìa cũ dù còn hạn cũng không mở được nữa:

- **Bước 1 — DB:** Thêm cột `tokenVersion` (số nguyên, mặc định 0) vào bảng `User` trong schema Prisma
- **Bước 2 — Khi cấp token:** Ghi số `tokenVersion` hiện tại của user vào bên trong access token
- **Bước 3 — Khi dùng token:** Mỗi lần nhận request, server so sánh số version trong token với số version hiện tại trong DB — nếu khác nhau thì từ chối
- **Bước 4 — Khi đăng xuất:** Tăng `tokenVersion` trong DB lên 1 — tất cả token cũ mang số version cũ hơn đều bị vô hiệu ngay lập tức

Đánh đổi: mỗi request cần xác thực sẽ tốn thêm 1 lần đọc DB để lấy `tokenVersion`. Với quy mô nhóm sinh viên thì không đáng lo.

---

### 5. Hệ thống vô tình tiết lộ email nào đã đăng ký

**File:** `server/src/services/auth.service.js` — hàm `login`, dòng 76–83

**Vấn đề xảy ra như thế nào:**
Hiện tại nếu nhập email sai định dạng (ví dụ `"abc"`), server trả lỗi 400. Nếu nhập đúng định dạng nhưng email chưa đăng ký, server trả lỗi 401. Người dùng bình thường không để ý, nhưng kẻ muốn dò thông tin chỉ cần nhìn vào mã lỗi: 400 nghĩa là "email sai định dạng", 401 nghĩa là "email này tồn tại nhưng sai mật khẩu". Từ đó có thể dùng tool để tự động dò xem email nào đã đăng ký tài khoản trong hệ thống.

**Hướng fix:**
Ở màn hình đăng nhập, không cần kiểm tra định dạng email — chỉ cần đảm bảo ô email và mật khẩu không để trống. Mọi trường hợp sai (sai định dạng, email chưa đăng ký, sai mật khẩu) đều trả về cùng 1 thông báo chung chung kiểu "Email hoặc mật khẩu không chính xác" — không tiết lộ cái nào sai.

---

## DATABASE (Prisma Schema)

---

### 6. Thiếu field `tokenVersion` trên bảng `User`

**File:** `server/prisma/schema.prisma` — model `User`

**Vấn đề xảy ra như thế nào:**
Issue #4 bên trên đề xuất thêm `tokenVersion` để giải quyết việc đăng xuất rồi mà token cũ vẫn dùng được. Nhưng nhìn vào schema thì field này chưa có — nếu viết code logic ở service/middleware mà DB chưa có cột này thì sẽ bị lỗi runtime ngay.

**Hướng fix:**
Thêm `tokenVersion Int @default(0)` vào model `User` trong schema, sau đó chạy `prisma generate` và `prisma db push`.

---

### 7. Xóa token theo user chậm vì thiếu index

**File:** `server/prisma/schema.prisma` — model `RefreshToken`

**Vấn đề xảy ra như thế nào:**
Có tính năng xóa toàn bộ token của 1 user (ví dụ: đăng xuất tất cả thiết bị). Khi DB lớn lên, thao tác tìm "tất cả token của user X" sẽ phải duyệt qua toàn bộ bảng vì không có chỉ mục nào trên cột `userId`. Giống như tìm tên người trong danh bạ không có mục lục — phải đọc từng trang một.

**Hướng fix:**
Thêm `@@index([userId])` vào model `RefreshToken`. PostgreSQL khác MySQL ở chỗ nó không tự tạo index cho khóa ngoại — phải khai báo tường minh.

---

### 8. `workMode`, `level`, `status` trên bảng `Job` không được kiểm soát giá trị

**File:** `server/prisma/schema.prisma` — model `Job`, dòng 164–171

**Vấn đề xảy ra như thế nào:**
Ba field này đang là kiểu `String` tự do với ghi chú trong comment: `// onsite | hybrid | remote`. Nghĩa là DB không hề kiểm tra — nếu code vô tình ghi `"Onsite"` (chữ hoa), hay `"on-site"` (có gạch ngang), hay thậm chí `"abc"` thì DB vẫn lưu vào bình thường. Về sau query tìm việc theo `workMode = "onsite"` sẽ không ra kết quả dù data có, chỉ vì bị ghi sai giá trị từ trước.

**Hướng fix:**
Tạo Prisma enum cho từng field giống cách `Role` đang làm — DB sẽ tự động từ chối bất kỳ giá trị nào không nằm trong danh sách cho phép.

---

### 9. `status` trên bảng `Application` cùng vấn đề như trên

**File:** `server/prisma/schema.prisma` — model `Application`, dòng 189

**Vấn đề xảy ra như thế nào:**
`status` của đơn ứng tuyển đang là `String` với 6 giá trị hợp lệ ghi trong comment. Tương tự issue #8 — không có gì ngăn việc ghi sai, dẫn đến data không nhất quán và các tính năng lọc theo trạng thái đơn có thể hoạt động sai.

**Hướng fix:**
Tạo enum `ApplicationStatus` với 6 giá trị đó và dùng thay cho `String`.

---

### 10. Một user có thể thêm trùng kỹ năng

**File:** `server/prisma/schema.prisma` — model `UserSkill`, dòng 129–139

**Vấn đề xảy ra như thế nào:**
Không có gì ngăn việc user thêm "JavaScript" 3 lần. Khi hiển thị danh sách kỹ năng trên profile sẽ bị trùng lặp, trông rất xấu và dữ liệu rác tích tụ theo thời gian.

**Hướng fix:**
Thêm `@@unique([userId, skillName])` vào model — DB sẽ tự từ chối nếu cùng 1 user cố thêm cùng 1 kỹ năng lần 2.

---

### 11. Các bảng con query chậm khi data lớn

**File:** `server/prisma/schema.prisma` — model `WorkExperience`, `Education`, `UserSkill`, `Cv`

**Vấn đề xảy ra như thế nào:**
Khi xem profile của ai đó, app cần lấy toàn bộ kinh nghiệm làm việc, học vấn, kỹ năng, CV của người đó. Các query này đều tìm theo `userId`. Nhưng PostgreSQL không tự tạo index cho khóa ngoại — khi bảng có vài chục nghìn bản ghi trở lên, mỗi lần load profile là phải duyệt toàn bộ bảng thay vì nhảy thẳng đến đúng vị trí.

**Hướng fix:**
Thêm `@@index([userId])` vào cả 4 model trên. Đây là việc cần làm ngay từ đầu với PostgreSQL vì nó không làm tự động như MySQL.
