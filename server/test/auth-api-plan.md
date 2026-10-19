# 🔐 Implementation Plan: Auth API (Register, Login, Google Login, Access/Refresh Token)

## Quy Tắc Làm Việc (Bắt Buộc)

Thực hiện task này theo `CONTRIBUTING.md` của repository:

1. **Nhánh Git**
   - Không làm việc trực tiếp trên `main` và tuyệt đối không push trực tiếp lên `main`.
   - Tạo nhánh riêng từ `main` mới nhất trước khi sửa code: `feature/B2-auth-api`.
   - Nếu không thể cập nhật `main` từ remote, dừng để đánh giá chênh lệch thay vì tự ý ghi đè hoặc làm trên nhánh không phù hợp.
2. **Commit**
   - Nếu tạo commit, dùng Conventional Commits theo mẫu `<type>(<scope>): <mô tả ngắn>`, ví dụ `feat(server): thêm API xác thực`.
   - Không commit thay đổi ngoài phạm vi task. Việc tạo commit/push/PR chỉ thực hiện khi được yêu cầu.
3. **Kiểm tra trước khi bàn giao**
   - Đảm bảo server chạy được và không có lỗi cú pháp/runtime; chạy kiểm tra phù hợp với scripts hiện có trong `server/`.
   - Cập nhật hướng dẫn hoặc tài liệu liên quan nếu thay đổi làm ảnh hưởng cách dùng API/cấu hình.
   - Khi tạo PR, tiêu đề theo `[B2] ...`, mô tả gồm tóm tắt và hướng dẫn test; thay đổi giao diện Flutter phải đính kèm ảnh/GIF/video. PR cần ít nhất một thành viên khác review/approve trước khi squash merge.
4. **Sử dụng code do AI hỗ trợ**
   - Người thực hiện phải đọc, hiểu và có thể giải thích toàn bộ code được tạo hoặc chỉnh sửa; không chấp nhận copy-paste mà chưa hiểu.
5. **Theo dõi tiến độ**
   - Task bám theo mã `B2` và cập nhật GitHub Projects theo trạng thái `To do` → `Doing` → `In Review` → `Done` khi có quyền truy cập.
   - Mỗi thành viên không làm quá 2 task đồng thời; nếu vướng quá 2 ngày, báo nhóm để pair-programming hoặc điều chỉnh phạm vi.

## Mục Tiêu
Xây dựng hệ thống xác thực (Authentication) hoàn chỉnh cho backend Node.js Express bao gồm:
1. **Register** — Đăng ký tài khoản bằng email/password
2. **Login** — Đăng nhập bằng email/password
3. **Google Login** — Đăng nhập bằng Google (Flutter gửi idToken, server verify)
4. **Access Token + Refresh Token** — Cơ chế token kép (access 15 phút, refresh 7 ngày lưu DB)
5. **Refresh endpoint** — Cấp lại access token khi hết hạn
6. **Logout** — Thu hồi (revoke) refresh token

## Quyết Định Thiết Kế Đã Chốt

| Quyết định | Lựa chọn |
|---|---|
| Ngôn ngữ backend | JavaScript CommonJS |
| Register fields | `email`, `password`, `fullName`, `role` (student/recruiter) |
| Access Token TTL | **15 phút** |
| Refresh Token TTL | **7 ngày** |
| Refresh Token storage | Bảng `RefreshToken` trong PostgreSQL (revocable) |
| Google Sign-In flow | Flutter `google_sign_in` → gửi idToken → Server verify bằng `google-auth-library` |
| Google first-login | Tự động tạo tài khoản mới với role mặc định `student` |
| Password hashing | `bcryptjs` (đã cài sẵn) |
| JWT signing | `jsonwebtoken` (đã cài sẵn) |

---

## Luồng Xác Thực (Authentication Flow)

```mermaid
sequenceDiagram
    participant App as Flutter App
    participant Server as Node.js Server
    participant DB as Supabase PostgreSQL
    participant Google as Google OAuth

    Note over App,Server: === ĐĂNG KÝ ===
    App->>Server: POST /api/v1/auth/register {email, password, fullName, role}
    Server->>Server: Validate input, hash password (bcryptjs)
    Server->>DB: INSERT User + INSERT StudentProfile/RecruiterProfile
    Server->>Server: Tạo accessToken (JWT 15m) + refreshToken (UUID)
    Server->>DB: INSERT RefreshToken
    Server-->>App: 201 {user, accessToken, refreshToken}

    Note over App,Server: === ĐĂNG NHẬP ===
    App->>Server: POST /api/v1/auth/login {email, password}
    Server->>DB: SELECT User by email
    Server->>Server: bcrypt.compare password
    Server->>Server: Tạo accessToken + refreshToken
    Server->>DB: INSERT RefreshToken
    Server-->>App: 200 {user, accessToken, refreshToken}

    Note over App,Google: === ĐĂNG NHẬP GOOGLE ===
    App->>Google: google_sign_in → lấy idToken
    App->>Server: POST /api/v1/auth/google {idToken}
    Server->>Google: verifyIdToken (google-auth-library)
    Google-->>Server: {email, name, picture, sub}
    Server->>DB: UPSERT User (tạo mới nếu chưa có)
    Server->>Server: Tạo accessToken + refreshToken
    Server->>DB: INSERT RefreshToken
    Server-->>App: 200 {user, accessToken, refreshToken, isNewUser}

    Note over App,Server: === REFRESH TOKEN ===
    App->>Server: POST /api/v1/auth/refresh {refreshToken}
    Server->>DB: SELECT RefreshToken (kiểm tra tồn tại + chưa hết hạn)
    Server->>Server: Tạo accessToken mới
    Server-->>App: 200 {accessToken}

    Note over App,Server: === LOGOUT ===
    App->>Server: POST /api/v1/auth/logout {refreshToken}
    Server->>DB: DELETE RefreshToken
    Server-->>App: 200 {message: "Logged out"}
```

---

## Proposed Changes

### 1. Cập nhật Prisma Schema — Thêm bảng `RefreshToken` và field `googleId`

#### [MODIFY] schema.prisma

Thêm model `RefreshToken` và field `googleId` cho User:

```diff
 model User {
   id           String   @id @default(uuid())
   email        String   @unique
-  passwordHash String
+  passwordHash String?  // Null khi user chỉ dùng Google login
+  googleId     String?  @unique // Google sub ID cho đăng nhập Google
   role         Role     @default(student)
   fullName     String
   avatarUrl    String?
   createdAt    DateTime @default(now())
   updatedAt    DateTime @updatedAt

   // Quan hệ 1-1 Profiles
   studentProfile   StudentProfile?
   recruiterProfile RecruiterProfile?

   // Quan hệ 1-N dành cho Sinh viên
   workExperiences WorkExperience[]
   educations      Education[]
   skills          UserSkill[]
   cvs             Cv[]
   applications    Application[]

   // Quan hệ 1-N dành cho Nhà tuyển dụng
   postedJobs Job[]

+  // Refresh tokens
+  refreshTokens RefreshToken[]
+
   @@map("users")
 }
```

Thêm model mới `RefreshToken` ở cuối file:

```prisma
model RefreshToken {
  id        String   @id @default(uuid())
  token     String   @unique      // UUID v4 dùng làm refresh token
  userId    String
  expiresAt DateTime             // Thời điểm hết hạn (7 ngày kể từ lúc tạo)
  createdAt DateTime @default(now())

  user User @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@index([token])
  @@map("refresh_tokens")
}
```

> [!IMPORTANT]
> Sau khi sửa schema, chạy `npx prisma validate` và `npx prisma generate` để kiểm tra/cập nhật Prisma Client. `npx prisma db push` sẽ thay đổi database được cấu hình; chỉ chạy sau khi xác nhận đúng database đích và được cho phép.

---

### 2. Cập nhật `.env` — Thêm biến môi trường cho Token & Google

#### [MODIFY] .env

```env
# ... (giữ nguyên DATABASE_URL, PORT, AI_SERVICE_URL)

# JWT Configuration
JWT_SECRET="replace-with-a-unique-random-secret-of-at-least-32-characters"
JWT_ACCESS_EXPIRES_IN="15m"
JWT_REFRESH_EXPIRES_DAYS=7

# Google OAuth - Client ID từ Google Cloud Console
GOOGLE_CLIENT_ID="YOUR_GOOGLE_CLIENT_ID_HERE"
```

> [!IMPORTANT]
> Bạn cần tạo một project trên [Google Cloud Console](https://console.cloud.google.com/), bật Google Sign-In API, tạo OAuth Client ID (loại **Android** và/hoặc **Web application**) rồi điền `GOOGLE_CLIENT_ID` vào file `.env`.
>BTW Tui đã tạo cái client id rồi nhá. Tui chọn là Web Application thay vì Android vì nó đòi xác thực vân tay nên đã thay bằng web application. client ID:380900817945-h1iooij3jlk7cakj6br9ok0g99o5jpvi.apps.googleusercontent.com
client Secret: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
---

### 3. Cài thêm package `google-auth-library`

```powershell
cd server
npm install google-auth-library
```

---

### 4. Tổ Chức Cấu Trúc Thư Mục Server

```text
server/src/
├── index.js                    # Entrypoint (đã có, sẽ thêm mount router)
├── lib/
│   └── prisma.js               # Prisma singleton (đã có)
├── middleware/
│   └── auth.js                 # [NEW] Middleware xác thực JWT (protect routes)
├── routes/
│   └── auth.routes.js          # [NEW] Định nghĩa routes cho /api/v1/auth/*
├── controllers/
│   └── auth.controller.js      # [NEW] Logic xử lý register/login/google/refresh/logout
└── utils/
    └── token.js                # [NEW] Hàm tạo accessToken, refreshToken, verify
```

---

### 5. Chi Tiết Từng File Mới

#### [NEW] `src/utils/token.js`
Chứa các hàm tiện ích tạo và verify JWT:

```js
const jwt = require("jsonwebtoken");
const crypto = require("crypto");

/**
 * Tạo Access Token (JWT, hết hạn 15 phút)
 */
function generateAccessToken(user) {
  return jwt.sign(
    { userId: user.id, email: user.email, role: user.role },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_ACCESS_EXPIRES_IN || "15m" }
  );
}

/**
 * Tạo Refresh Token (UUID ngẫu nhiên, lưu vào DB)
 */
function generateRefreshToken() {
  return crypto.randomUUID();
}

/**
 * Verify Access Token → trả về payload hoặc throw error
 */
function verifyAccessToken(token) {
  return jwt.verify(token, process.env.JWT_SECRET);
}

module.exports = { generateAccessToken, generateRefreshToken, verifyAccessToken };
```

---

#### [NEW] `src/middleware/auth.js`
Middleware bảo vệ các route cần đăng nhập:

```js
const { verifyAccessToken } = require("../utils/token");

/**
 * Middleware: Kiểm tra header Authorization: Bearer <accessToken>
 * Nếu hợp lệ → gắn req.user = { userId, email, role }
 * Nếu không → trả 401
 */
function authenticate(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return res.status(401).json({ error: "Access token is required" });
  }

  const token = authHeader.split(" ")[1];
  try {
    const payload = verifyAccessToken(token);
    req.user = payload; // { userId, email, role }
    next();
  } catch (err) {
    if (err.name === "TokenExpiredError") {
      return res.status(401).json({ error: "Access token expired", code: "TOKEN_EXPIRED" });
    }
    return res.status(401).json({ error: "Invalid access token" });
  }
}

module.exports = { authenticate };
```

> [!TIP]
> Trả về `code: "TOKEN_EXPIRED"` để Flutter client biết cần gọi API `/auth/refresh` để lấy accessToken mới thay vì bắt user đăng nhập lại.

---

#### [NEW] `src/controllers/auth.controller.js`
Logic xử lý 5 endpoints chính:

| Endpoint | Method | Body | Mô tả |
|---|---|---|---|
| `/api/v1/auth/register` | POST | `{email, password, fullName, role}` | Đăng ký tài khoản mới |
| `/api/v1/auth/login` | POST | `{email, password}` | Đăng nhập bằng email/password |
| `/api/v1/auth/google` | POST | `{idToken}` | Đăng nhập/đăng ký bằng Google |
| `/api/v1/auth/refresh` | POST | `{refreshToken}` | Cấp accessToken mới |
| `/api/v1/auth/logout` | POST | `{refreshToken}` | Thu hồi refreshToken |
| `/api/v1/auth/me` | GET | — (Bearer token) | Lấy thông tin user hiện tại |

**Chi tiết logic cho từng endpoint:**

##### `register`
1. Validate: email hợp lệ, password ≥ 6 ký tự, fullName không rỗng, role phải là `student` hoặc `recruiter`.
2. Kiểm tra email đã tồn tại chưa → nếu có, trả 409 Conflict.
3. Hash password bằng `bcryptjs` (saltRounds = 10).
4. Dùng Prisma transaction để tạo User và StudentProfile rỗng nếu role là `student`. Với role `recruiter`, chỉ tạo User; tạo RecruiterProfile sau khi có `companyName` vì trường này đang bắt buộc trong schema.
5. Tạo accessToken + refreshToken, lưu refreshToken vào DB.
6. Trả về `{ user, accessToken, refreshToken }`.

##### `login`
1. Tìm User theo email → nếu không có, trả 401.
2. `bcrypt.compare(password, user.passwordHash)` → nếu sai, trả 401.
3. Tạo cặp token, lưu refreshToken vào DB.
4. Trả về `{ user, accessToken, refreshToken }`.

##### `google`
1. Nhận `idToken` từ body.
2. Dùng `google-auth-library` gọi `verifyIdToken({ idToken, audience: GOOGLE_CLIENT_ID })`.
3. Lấy `{ sub, email, name, picture }` từ payload.
4. Tìm user theo `googleId = sub` hoặc `email`.
5. Nếu chưa có → tạo user mới (role mặc định `student`, `passwordHash = null`) + tạo StudentProfile rỗng. Gắn `isNewUser = true`.
6. Nếu đã có user bằng email nhưng chưa có `googleId` → cập nhật `googleId`.
7. Tạo cặp token, lưu refreshToken vào DB.
8. Trả về `{ user, accessToken, refreshToken, isNewUser }`.

##### `refresh`
1. Nhận `refreshToken` từ body.
2. Tìm trong bảng `RefreshToken` → nếu không tìm thấy hoặc đã hết hạn, trả 401.
3. Tạo accessToken mới.
4. Trả về `{ accessToken }`.

##### `logout`
1. Nhận `refreshToken` từ body.
2. Xóa record trong bảng `RefreshToken` → kể cả không tìm thấy cũng trả 200 OK.

##### `me` (GET, cần authenticate middleware)
1. Dùng `req.user.userId` để query User từ DB (kèm include profile tương ứng).
2. Trả về thông tin user (loại bỏ `passwordHash`).

> RecruiterProfile là tùy chọn khi đăng ký; recruiter chỉ có profile sau khi cung cấp `companyName` qua luồng cập nhật hồ sơ.

---

#### [NEW] `src/routes/auth.routes.js`

```js
const { Router } = require("express");
const authController = require("../controllers/auth.controller");
const { authenticate } = require("../middleware/auth");

const router = Router();

router.post("/register", authController.register);
router.post("/login", authController.login);
router.post("/google", authController.googleLogin);
router.post("/refresh", authController.refresh);
router.post("/logout", authController.logout);
router.get("/me", authenticate, authController.getMe);

module.exports = router;
```

---

#### [MODIFY] `src/index.js`
Thêm mount auth routes:

```diff
+const authRoutes = require("./routes/auth.routes");

 // Middlewares
 app.use(cors());
 app.use(express.json());
 app.use(express.urlencoded({ extended: true }));

+// Routes
+app.use("/api/v1/auth", authRoutes);

 // Health check endpoint
 app.get("/health", async (_req, res) => {
```

---

### 6. Cập nhật `.env.example`

#### [MODIFY] .env.example

```env
# Database Supabase IPv4 Pooler
DATABASE_URL="postgresql://postgres.puxpncrdigjbancnbrzz:YOUR_PASSWORD@aws-0-ap-northeast-1.pooler.supabase.com:5432/postgres"

# Server Port
PORT=5000

# JWT Configuration
JWT_SECRET="replace-with-a-unique-random-secret-of-at-least-32-characters"
JWT_ACCESS_EXPIRES_IN="15m"
JWT_REFRESH_EXPIRES_DAYS=7

# Google OAuth Client ID (từ Google Cloud Console)
GOOGLE_CLIENT_ID="your_google_client_id_here"

# AI Service (FastAPI) URL
AI_SERVICE_URL="http://localhost:8000"
```

---

## API Response Format

Tất cả các response đều theo chuẩn JSON nhất quán:

### Thành công (Register / Login / Google):
```json
{
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "fullName": "Nguyễn Văn A",
    "role": "student",
    "avatarUrl": null,
    "createdAt": "2026-10-18T..."
  },
  "accessToken": "eyJhbG...",
  "refreshToken": "550e8400-e29b-..."
}
```

### Lỗi:
```json
{
  "error": "Mô tả lỗi ngắn gọn",
  "code": "ERROR_CODE_OPTIONAL"
}
```

### HTTP Status Codes sử dụng:
| Code | Ý nghĩa |
|---|---|
| `200` | Thành công (Login, Refresh, Logout, GetMe) |
| `201` | Tạo mới thành công (Register) |
| `400` | Dữ liệu đầu vào không hợp lệ |
| `401` | Không xác thực được (sai password, token expired/invalid) |
| `409` | Email đã được sử dụng (Register) |
| `500` | Lỗi server nội bộ |

---

## Verification Plan

### Automated Tests
Chạy unit test và kiểm tra schema/client mà không cần ghi dữ liệu lên Supabase:

```powershell
cd server
npm test
npx prisma validate
npx prisma generate
```

### Manual Verification
Chỉ gọi các endpoint làm thay đổi dữ liệu trên một database test riêng đã được xác nhận:

```powershell
cd server
npm run dev
```

Sau đó test bằng curl/PowerShell:

#### 1. Test Register
```powershell
Invoke-RestMethod -Method POST -Uri "http://localhost:5000/api/v1/auth/register" `
  -ContentType "application/json" `
  -Body '{"email":"test@example.com","password":"123456","fullName":"Test User","role":"student"}'
```

#### 2. Test Login
```powershell
Invoke-RestMethod -Method POST -Uri "http://localhost:5000/api/v1/auth/login" `
  -ContentType "application/json" `
  -Body '{"email":"test@example.com","password":"123456"}'
```

#### 3. Test Refresh
```powershell
Invoke-RestMethod -Method POST -Uri "http://localhost:5000/api/v1/auth/refresh" `
  -ContentType "application/json" `
  -Body '{"refreshToken":"<refreshToken_từ_bước_2>"}'
```

#### 4. Test GetMe (Protected route)
```powershell
Invoke-RestMethod -Method GET -Uri "http://localhost:5000/api/v1/auth/me" `
  -Headers @{ Authorization = "Bearer <accessToken_từ_bước_2>" }
```

#### 5. Test Logout
```powershell
Invoke-RestMethod -Method POST -Uri "http://localhost:5000/api/v1/auth/logout" `
  -ContentType "application/json" `
  -Body '{"refreshToken":"<refreshToken_từ_bước_2>"}'
```

#### 6. Test Register trùng email (409)
```powershell
Invoke-RestMethod -Method POST -Uri "http://localhost:5000/api/v1/auth/register" `
  -ContentType "application/json" `
  -Body '{"email":"test@example.com","password":"654321","fullName":"Another","role":"recruiter"}'
```

#### 7. Test Login sai password (401)
```powershell
Invoke-RestMethod -Method POST -Uri "http://localhost:5000/api/v1/auth/login" `
  -ContentType "application/json" `
  -Body '{"email":"test@example.com","password":"wrong_password"}'
```

> [!NOTE]
> Google Login (`POST /api/v1/auth/google`) cần `GOOGLE_CLIENT_ID` hợp lệ và idToken thật từ Flutter app. Không chạy các lệnh thao tác database hoặc test thủ công trên Supabase dùng chung nếu chưa xác nhận database đích và được cho phép.

---

## Thứ Tự Thực Hiện

1. **Schema** → Sửa `schema.prisma`, chạy `prisma validate` và `prisma generate`; chỉ `prisma db push` sau khi xác nhận database đích và được cho phép
2. **Env** → Cập nhật `.env` và `.env.example`
3. **Package** → `npm install google-auth-library`
4. **Utils** → Tạo `src/utils/token.js`
5. **Middleware** → Tạo `src/middleware/auth.js`
6. **Controller** → Tạo `src/controllers/auth.controller.js`
7. **Routes** → Tạo `src/routes/auth.routes.js`
8. **Entrypoint** → Cập nhật `src/index.js` mount routes
9. **Verify** → Chạy server + test từng endpoint
