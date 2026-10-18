# 💼 Mini LinkedIn Mobile - Nền Tảng Tìm Việc IT Cho Sinh Viên

Dự án ứng dụng di động hỗ trợ sinh viên ngành Công nghệ Thông tin tìm kiếm cơ hội thực tập và việc làm Fresher. Hệ thống tích hợp AI để phân tích CV, tự động so khớp kỹ năng và chấm điểm độ phù hợp (%) với tin tuyển dụng, đồng thời chỉ ra các kỹ năng còn thiếu để sinh viên trau dồi.

---

## 🏗️ Kiến Trúc Hệ Thống (Architecture)

Dự án được tổ chức theo mô hình **Monorepo** với 3 module độc lập:

```text
MiniLinkedInMobile/
├── app/       # Frontend: Ứng dụng di động Flutter (Android / iOS)
├── server/    # Backend: Node.js + Express + JavaScript (CommonJS) + Prisma ORM (Supabase)
├── ai/        # AI Service: Python FastAPI (Phân tích CV PDF & chấm điểm Job)
├── README.md  # Tài liệu cài đặt & hướng dẫn chạy dự án
└── CONTRIBUTING.md # Quy ước commit, branching và review nhóm
```

### Luồng tương tác:
`Flutter App` ➡️ `Node.js Backend` ➡️ `Supabase PostgreSQL (Database & Storage)`
                                ↘️ `Python AI Service` (Trích xuất CV & chấm điểm độ phù hợp)

---

## 🛠️ Yêu Cầu Môi Trường Cài Đặt (Prerequisites trên Windows)

Trước khi bắt đầu, đảm bảo máy tính của bạn đã cài đặt các công cụ sau:
1. **Git**: [Tải Git cho Windows](https://git-scm.com/download/win)
2. **Node.js**: Phiên bản LTS (Khuyến nghị Node 20.x hoặc 22.x/24.x) - [Tải Node.js](https://nodejs.org/)
3. **Flutter SDK**: Phiên bản 3.x - [Tải Flutter](https://docs.flutter.dev/get-started/install/windows)
4. **Android Studio** (hoặc VS Code với extension Flutter/Dart) và Android Virtual Device (AVD).
5. **Python**: Phiên bản 3.10 trở lên - [Tải Python](https://www.python.org/downloads/)

---

## ⚡ Hướng Dẫn Cài Đặt & Chạy Từng Phần

### 1. 🗄️ Cài đặt & Khởi chạy Backend (`server/`)

Thư mục backend chịu trách nhiệm cung cấp REST API, xác thực JWT và kết nối cơ sở dữ liệu Supabase qua Prisma ORM.

```powershell
# 1. Di chuyển vào thư mục server
cd server

# 2. Cài đặt các thư viện cần thiết
npm install

# 3. Tạo file cấu hình môi trường .env (hoặc copy từ .env.example)
# Đảm bảo DATABASE_URL trỏ đúng tới database Supabase của nhóm:
# DATABASE_URL="postgresql://postgres:doanLTDD@123@db.puxpncrdigjbancnbrzz.supabase.co:5432/postgres"

# 4. Đồng bộ Schema Prisma lên Supabase
npx prisma db push

# 5. Sinh mã Prisma Client
npx prisma generate

# 6. Khởi chạy Server ở chế độ Development
npm run dev
```
> Server sẽ chạy tại địa chỉ: `http://localhost:5000`

API xác thực được mount tại `/api/v1/auth` (`register`, `login`, `google`,
`refresh`, `logout` và `me`). Cấu hình `JWT_SECRET` bằng một chuỗi ngẫu nhiên
riêng dài ít nhất 32 ký tự; thêm `GOOGLE_CLIENT_ID` để bật Google Login.
Tham khảo `server/.env.example` để xem các biến cấu hình.

---

### 2. 📱 Cài đặt & Khởi chạy Mobile App (`app/`)

Ứng dụng di động được viết bằng Flutter.

```powershell
# 1. Di chuyển vào thư mục app
cd app

# 2. Tải các dependencies
flutter pub get

# 3. Kiểm tra thiết bị có sẵn (Emulator hoặc điện thoại cắm cáp USB)
flutter devices

# 4. Chạy ứng dụng
flutter run
```

> ⚠️ **LƯU Ý QUAN TRỌNG KHI KẾT NỐI API TRÊN WINDOWS**:
> - Nếu chạy trên **Android Emulator**: `localhost` của máy tính được ánh xạ thành `10.0.2.2`. Cấu hình Base URL của API là `http://10.0.2.2:5000/api/v1`.
> - Nếu chạy trên **Điện thoại thật (USB)**: Dùng địa chỉ IP LAN của máy tính (vd: `http://192.168.1.x:5000/api/v1`) hoặc dùng công cụ port forwarding:
>   ```powershell
>   adb reverse tcp:5000 tcp:5000
>   ```
> - Nếu chạy trên **Chrome (Web)**: Dùng `http://localhost:5000/api/v1`.

---

### 3. 🧠 Cài đặt & Khởi chạy AI Service (`ai/`)

Dịch vụ AI phân tích file PDF và chấm điểm độ phù hợp kỹ năng bằng Python FastAPI.

```powershell
# 1. Di chuyển vào thư mục ai
cd ai

# 2. Tạo môi trường ảo Python
python -m venv venv

# 3. Kích hoạt môi trường ảo (PowerShell trên Windows)
.\venv\Scripts\Activate.ps1
# (Nếu gặp lỗi Execution Policy, chạy: Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass)

# 4. Cài đặt các thư viện
pip install -r requirements.txt

# 5. Chạy AI service
uvicorn main:app --reload --port 8000
```
> AI Service chạy tại: `http://localhost:8000` (Swagger UI xem tại: `http://localhost:8000/docs`)

---

## 👥 Quy Tắc Làm Việc Nhóm

Tất cả các thành viên vui lòng đọc kỹ tài liệu [CONTRIBUTING.md](./CONTRIBUTING.md) trước khi tạo nhánh, commit code hoặc gửi Pull Request.

- **Không bao giờ push trực tiếp vào `main`**.
- Đặt tên nhánh theo cú pháp `feature/<mã-task>-<tên-task>`.
- Commit message theo chuẩn **Conventional Commits** (`feat:`, `fix:`, `chore:`, ...).
- Mỗi PR cần có ít nhất 1 thành viên review và approve trong 24 giờ.