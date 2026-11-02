# Tổng Kết Lô 2: Việc Làm & Tuyển Dụng (00-BATCH-2.md) - Cổng G3

Tổng kết thiết kế 5 màn hình/sheet nghiệp vụ việc làm & tuyển dụng:
1. [S-05-JOBS.md](file:///Users/hosynguyen/MiniLinkedInMobile/docs/ui-redesign/03-screens/S-05-JOBS.md): Danh sách việc làm sinh viên.
2. [M-02-JOB-DETAIL.md](file:///Users/hosynguyen/MiniLinkedInMobile/docs/ui-redesign/03-screens/M-02-JOB-DETAIL.md): Modal chi tiết công việc & nộp đơn ứng tuyển.
3. [M-03-JOB-FILTER.md](file:///Users/hosynguyen/MiniLinkedInMobile/docs/ui-redesign/03-screens/M-03-JOB-FILTER.md): Bộ lọc công việc danh mục có cấu trúc kiểu Clay.
4. [S-14-APPLICATIONS.md](file:///Users/hosynguyen/MiniLinkedInMobile/docs/ui-redesign/03-screens/S-14-APPLICATIONS.md): Theo dõi đơn ứng tuyển của sinh viên.
5. [S-15-RECRUITER.md](file:///Users/hosynguyen/MiniLinkedInMobile/docs/ui-redesign/03-screens/S-15-RECRUITER.md): Bảng điều khiển nhà tuyển dụng.

---

## Bảng Đối Chiếu Tính Nhất Quán Trong Lô 2

| Tiêu chí | Màn S-05 Việc làm | Sheet M-02 Chi tiết & M-03 Lọc | Màn S-14 Đơn ứng tuyển | Màn S-15 Nhà tuyển dụng |
|---|---|---|---|---|
| **Vị trí nút chính (Primary CTA)** | Nút lọc trên search bar + Thẻ việc làm chạm mở modal | Nút Sticky "Ứng tuyển ngay" / Nút "Áp dụng lọc" ở chân trang | Nút "Khám phá việc làm" (khi rỗng) hoặc thẻ đơn | Nút "Đăng tin tuyển dụng mới" màu xanh Primary |
| **Thể hiện mức lương** | Tag màu xanh lá `#10B981` trên nền nhạt | Tag nổi bật trong header chi tiết | Hiển thị mức lương kèm thông tin vị trí đã nộp | Mức lương hiển thị trong tóm tắt tin đăng |
| **Xử lý trạng thái rỗng** | `EmptyStateView` có nút xóa bộ lọc | Không áp dụng (Sheet theo dữ liệu) | `EmptyStateView` có nút dẫn sang tab Việc làm | `EmptyStateView` có nút đăng tin đầu tiên |
| **Bo góc & Viền** | Card: 16dp, Search: 12dp, Viền 1px | Sheet bo trên: 24dp, Chip lọc: 8dp | Card: 16dp, Tabs: 12dp | Card thống kê & tin: 16dp |
| **Tương thích Floating Dock** | Đệm cuộn đáy `bottomPadding: 88dp` | Không (Modal phủ lên trên Dock) | Đệm cuộn đáy `bottomPadding: 88dp` | Đệm cuộn đáy `bottomPadding: 88dp` |

---

## Kế Hoạch Tiếp Theo: Lô 3 (Mạng Xã Hội, Tin Tức & Chatbot Tương Tác)
- **S-04**: Khung Shell điều hướng trung tâm với Floating Dock (`StudentHomeScreen`).
- **S-06**: Dòng tin mạng xã hội tuyển dụng (`SocialFeedScreen`).
- **S-07**: Màn hình soạn thảo bài viết mới (`CreatePostScreen`).
- **S-08**: Trang tin tức công nghệ sinh viên (`NewsPage`).
- **M-01**: Chatbot AI gia sư kỹ năng chuẩn `ChatSuggestions` (`CoachSheet`).

---

👉 **DỪNG TẠI CỔNG G3 (Lô 2)**: Đệ trình chủ dự án duyệt 5 màn nghiệp vụ Việc làm & Tuyển dụng trên trước khi bước sang Lô 3.

