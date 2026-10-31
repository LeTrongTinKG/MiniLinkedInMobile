# Bảng Đối Chiếu Nhất Quán Lô 3: Điều Hướng, Mạng Xã Hội, Tin Tức & Chatbot (00-BATCH-3.md)

Lô 3 gồm 5 màn hình & modal: `S-04-STUDENT-HOME`, `S-06-SOCIAL-FEED`, `S-07-CREATE-POST`, `S-08-NEWS`, `M-01-COACH-BOT`.

---

## 1. Bảng Đối Chiếu Các Thành Phần Chủ Đạo

| Tiêu Chí | S-04 Student Home | S-06 Social Feed | S-07 Create Post | S-08 News | M-01 Coach Bot |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Vai trò** | Khung Shell điều hướng | Bảng tin cộng đồng | Soạn bài viết | Tin tức công nghệ | Trợ lý kỹ năng AI |
| **Vị trí Hành động chính** | Nút trung tâm Dock (✦ AI) | Ô Composer đầu bảng tin | Nút "Đăng" góc trên phải | Chip lọc đầu trang | Nút gửi mũi tên trong Pill Input |
| **Độ bo góc (Radius)** | Dock 28dp | PostCard 16dp, Composer 12dp | Ô soạn 12dp, Nút Đăng 20dp | NewsCard 16dp, Thumb 12dp | Sheet 24dp, Card gợi ý 16dp |
| **Xử lý khoảng đệm đáy** | Điều phối khoảng đệm 88dp | `bottomPadding: 88dp` | Không cần (toàn màn hình) | `bottomPadding: 88dp` | Chân trang cố định trong Sheet |
| **Xử lý trạng thái rỗng** | Theo tab con | `AppEmptyState` + icon | N/A (màn hình nhập) | `AppEmptyState` + nút xem lại | Khối gợi ý câu hỏi 21st.dev |
| **Xử lý trạng thái lỗi** | Giữ shell, báo ở tab | Banner đỏ nhạt + Nút thử lại | Banner lỗi trên ô soạn | Thông báo lỗi + Nút thử lại | Thông báo lỗi trong khung chat |

---

## 2. Cam Kết Nhất Quán Trải Nghiệm Lô 3

1. **Ngôn ngữ Executive Minimalist**: Toàn bộ thẻ nội dung (`PostCard`, `NewsCard`, `SuggestionCard`) đều sử dụng nền trắng `#FFFFFF`, viền mỏng 1px `#E2E8F0`, đổ bóng cực nhẹ `0 1px 3px rgba(0,0,0,0.05)`, tạo cảm giác cao cấp và hiện đại như ứng dụng Clay.
2. **Bảo vệ nội dung không bị che khuất**: Tất cả các màn hình cuộn nằm trong `StudentHomeScreen` (`JobList`, `SocialFeed`, `NewsPage`) đều được áp dụng khoảng đệm đáy `bottomPadding: 88dp` để không bị `FloatingDockBar` bo 28dp che lấp thông tin.
3. **Phân biệt rành mạch Chatbot**: `M-01` là Trợ lý kỹ năng AI dành cho sinh viên (`F-013`), cam kết AI nội bộ 0 USD, hoàn toàn tách biệt với Chatbot tuyển dụng dành cho doanh nghiệp (`F-018`).
4. **Áp dụng mẫu 21st.dev**: Thiết kế `ChatSuggestions` (từ `@Alwurts/components/chat-suggestions`) được kết hợp hài hòa với phong cách Nexus Clay trên `M-01-COACH-BOT`.

