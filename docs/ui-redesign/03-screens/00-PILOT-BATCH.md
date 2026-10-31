# Tổng Kết Lô Thí Điểm & Bảng Nhất Quán (00-PILOT-BATCH.md) - Cổng G3

Tổng kết thiết kế 3 màn hình đại diện đầu tiên trước khi bước vào các lô màn hình tiếp theo:
1. [S-02-AUTH.md](file:///Users/hosynguyen/MiniLinkedInMobile/docs/ui-redesign/03-screens/S-02-AUTH.md): Màn Xác thực / Chào mừng (Đại diện Onboarding & Entry).
2. [S-09-PROFILE.md](file:///Users/hosynguyen/MiniLinkedInMobile/docs/ui-redesign/03-screens/S-09-PROFILE.md): Màn Hồ sơ cá nhân & Quyền riêng tư (Đại diện Màn chính & Thiết lập bảo mật).
3. [S-11-SKILLS.md](file:///Users/hosynguyen/MiniLinkedInMobile/docs/ui-redesign/03-screens/S-11-SKILLS.md): Màn Kỹ năng 3 cấp độ & Quét Repo (Đại diện Năng lực cốt lõi & Tích hợp AI).

---

## Bảng Đối Chiếu Tính Nhất Quán Giữa Các Màn Hình

| Tiêu chí | Màn S-02 Auth | Màn S-09 Profile | Màn S-11 Skills & Repo |
|---|---|---|---|
| **Vị trí nút chính (Primary CTA)** | Dưới cùng của form nhập liệu (`AppButton` full-width 48dp) | Nút outline trên header + Nút nổi tải CV | Nút "Quét kỹ năng" màu xanh đậm trên card đầu |
| **Vị trí nút phụ / Chuyển tab** | `AppSegmentedTab` dạng pill bo tròn đặt đầu màn hình | Nút "Chỉnh sửa" viền mỏng đặt cạnh tên | Chip lọc danh mục kỹ năng dạng trượt ngang |
| **Cách báo lỗi nhập liệu** | Chữ đỏ inline (`errorText`) ngay dưới ô input | Hộp thông báo lỗi có viền đỏ nhạt + nút thử lại | Chữ đỏ inline dưới ô GitHub URL + SnackBar lỗi |
| **Quy chuẩn bo góc** | Input & Nút: 12dp, Khung ngoài: 16dp | Card CV: 16dp, Banner: 12dp, Dock: 28dp | Card Repo: 16dp, Chip skill: 8dp, Dock: 28dp |
| **Thể hiện tính bảo mật** | Icon ổ khóa, nút mắt bảo mật mật khẩu | Banner ổ khóa xanh ngà: *"Riêng tư mặc định"* | Banner cam kết *"AI 0 USD phân tích cục bộ"* |
| **Hỗ trợ Floating Dock** | Không (Màn auth độc lập, không có dock) | Có (Khoảng đệm cuộn đáy `bottomPadding: 88dp`) | Có (Khoảng đệm cuộn đáy `bottomPadding: 88dp`) |

---

## Đề Xuất Phân Chia Các Lô Tiếp Theo Sau Cổng G3 Thí Điểm
- **Lô 2 (Các màn nghiệp vụ việc làm & tuyển dụng - 5 màn)**:
  - S-05: Danh sách việc làm (`JobListScreen`)
  - M-02: Modal chi tiết công việc (`JobDetailSheet`)
  - M-03: Bộ lọc công việc dạng cấu trúc (`JobFilterSheet`)
  - S-14: Đơn ứng tuyển của tôi (`ApplicationsPage`)
  - S-15: Không gian nhà tuyển dụng (`RecruiterHomeScreen`)
- **Lô 3 (Mạng xã hội, Tin tức & Chatbot tương tác - 5 màn)**:
  - S-04: Shell điều hướng trung tâm với Floating Dock (`StudentHomeScreen`)
  - S-06: Dòng tin mạng xã hội (`SocialFeedScreen`)
  - S-07: Màn hình tạo bài viết (`CreatePostScreen`)
  - S-08: Trang tin tức công nghệ (`NewsPage`)
  - M-01: Chatbot gia sư kỹ năng AI (`CoachSheet` & `ChatSuggestions`)

---

👉 **DỪNG TẠI CỔNG G3 (Lô thí điểm)**: Đệ trình chủ dự án xem xét và duyệt 3 màn thí điểm trên trước khi tiến hành thiết kế các lô tiếp theo.

