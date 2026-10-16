# 📋 Hướng Dẫn Đóng Góp & Quy Ước Nhóm (CONTRIBUTING)

Tài liệu này quy định các quy chuẩn làm việc chung cho nhóm phát triển dự án **Mini LinkedIn Mobile** (Đồ án Lập trình Di động). Mọi thành viên cần tuân thủ để đảm bảo tiến độ, chất lượng code và tránh xung đột khi làm việc cùng nhau.

---

## 1. 🌳 Cấu Trúc Monorepo & Phân Chia Nhánh (Git Branching)

Dự án sử dụng mô hình **Monorepo** gồm 3 thư mục chính:
- `app/`: Ứng dụng di động (Flutter)
- `server/`: Backend REST API (Node.js + Express + JavaScript CommonJS + Prisma)
- `ai/`: AI Service xử lý & chấm điểm CV (Python + FastAPI)

### Quy tắc nhánh
- **TUYỆT ĐỐI KHÔNG push trực tiếp lên nhánh `main`**. Nhánh `main` luôn là code chạy ổn định.
- Mỗi task/tính năng phải làm trên một nhánh riêng tách ra từ `main` mới nhất:
  ```bash
  git checkout main
  git pull origin main
  git checkout -b <tên-nhánh>
  ```
- **Quy ước đặt tên nhánh**:
  - `feature/<mã-task>-<tên-ngắn-gọn>`: Tính năng mới (ví dụ: `feature/B1-db-schema`, `feature/B2-auth-api`, `feature/F3-login-ui`)
  - `fix/<mã-bug>-<mô-tả>`: Sửa lỗi (ví dụ: `fix/token-expired-issue`, `fix/F5-overflow-error`)
  - `docs/<nội-dung>`: Tài liệu (ví dụ: `docs/update-readme`, `docs/api-contracts`)
  - `chore/<nội-dung>`: Cấu hình, cài package (ví dụ: `chore/setup-typescript`, `chore/add-prisma`)

---

## 2. 📝 Quy Ước Commit Message (Conventional Commits)

Commit message cần rõ ràng, ngắn gọn và tuân thủ theo chuẩn sau:

```
<type>(<scope>): <mô tả ngắn gọn bằng tiếng Việt hoặc tiếng Anh>
```

### Các Type quy ước:
- `feat`: Thêm tính năng mới (ví dụ: `feat(server): tạo API đăng nhập và đăng ký JWT`)
- `fix`: Sửa lỗi (ví dụ: `fix(app): sửa lỗi màn hình chi tiết job bị overflow`)
- `docs`: Thêm/sửa tài liệu hướng dẫn (ví dụ: `docs: bổ sung hướng dẫn chạy server trên Windows`)
- `refactor`: Tái cấu trúc code (không thay đổi logic/chức năng)
- `style`: Định dạng code (whitespace, format, không ảnh hưởng logic)
- `chore`: Cấu hình môi trường, dependencies, scripts (ví dụ: `chore(server): cài đặt prisma client`)
- `test`: Thêm hoặc cập nhật unit test

### Scope gợi ý:
- `app`: Thay đổi trong ứng dụng Flutter
- `server`: Thay đổi trong backend Node.js
- `ai`: Thay đổi trong AI service Python
- `db`: Thay đổi liên quan đến schema Prisma / Supabase
- `docs`: Thay đổi tài liệu

### Ví dụ commit hợp lệ:
```bash
git commit -m "feat(server): thêm model Prisma cho User và Profile"
git commit -m "fix(app): sửa lỗi không lưu được token sau khi đăng nhập"
git commit -m "chore(server): cấu hình tsconfig và script chạy nodemon"
```

---

## 3. 🚀 Quy Trình Tạo Pull Request (PR) & Code Review

1. **Trước khi tạo PR**:
   - Đảm bảo code chạy được trên máy cá nhân, không có lỗi runtime.
   - Nếu sửa code Flutter: chạy `flutter analyze` ở thư mục `app/` để kiểm tra cảnh báo.
   - Nếu sửa code Server: chạy thử `node src/index.js` hoặc `npm run dev` ở thư mục `server/` để đảm bảo không có lỗi cú pháp hoặc crash.
   - Cập nhật nhánh của mình theo `main` mới nhất:
     ```bash
     git fetch origin
     git rebase origin/main # hoặc git merge origin/main
     ```

2. **Tạo PR trên GitHub**:
   - Đặt tiêu đề theo cú pháp: `[Mã Task] Tên tóm tắt tính năng` (ví dụ: `[B1] Khởi tạo Prisma schema và đồng bộ Supabase`).
   - Điền mô tả PR:
     - Tóm tắt những gì đã làm.
     - **BẮT BUỘC đính kèm ảnh chụp màn hình / GIF / video** nếu có thay đổi giao diện Flutter.
     - Hướng dẫn ngắn cách test nhanh (ví dụ: "Gọi POST /api/v1/auth/login với body mẫu...").

3. **Quy định Review**:
   - Cần ít nhất **1 thành viên khác** trong nhóm review và Approve trước khi merge.
   - Người được gán review phải phản hồi trong vòng **24 giờ**.
   - Sau khi được approve, sử dụng tính năng **Squash and merge** để lịch sử nhánh `main` được gọn gàng.

---

## 4. 🤖 Quy Định Về Sử Dụng Code Do AI Sinh Ra

- Được phép sử dụng công cụ AI (Gemini, Claude, ChatGPT, GitHub Copilot) để hỗ trợ viết code và học hỏi.
- **NGUYÊN TẮC QUAN TRỌNG**: Người tạo PR phải đọc, hiểu và tự giải thích được 100% đoạn code mình gửi lên. Tuyệt đối không copy-paste mã nguồn AI sinh ra khi chưa hiểu cách thức hoạt động.

---

## 5. 📌 Quản Lý Công Việc & Tiến Độ (GitHub Projects)

- Mọi công việc bám sát theo bảng phân rã Task trong kế hoạch (S1–S4, B1–B9, F1–F11, A1–A5, R1–R5).
- Bảng Kanban gồm 4 cột:
  - `To do`: Các task đang chờ thực hiện.
  - `Doing`: Task đang được làm (Mỗi người tối đa **2 task** cùng lúc).
  - `In Review`: Đã tạo PR và đang chờ thành viên khác duyệt.
  - `Done`: PR đã được merge vào `main`.
- **Cảnh báo kẹt tiến độ**: Nếu một task bị vướng quá **2 ngày**, lập tức thông báo lên nhóm chat để cùng pair-programming gỡ rối hoặc điều chỉnh phạm vi.

