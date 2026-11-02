# Nghiên Cứu Trải Nghiệm & Khảo Sát Hiện Trạng (00-RESEARCH.md)

## 1. Tóm Tắt Hiện Trạng Từ UI-Handoff (Các Vấn Đề UX Lớn Nhất)

Dựa trên kết quả rà soát từ bộ tài liệu `docs/ui-handoff/GAPS.md`:
1. **Form Validation phân mảnh (P0)**: `login_screen.dart:45-65` dùng `FormKey` chuẩn, nhưng `edit_profile_page.dart:58-75` và `repo_upload_screen.dart:40-62` đẩy việc kiểm tra lỗi vào ViewModel mà không có inline error text màu đỏ dưới ô nhập, chỉ báo SnackBar chung chung.
2. **Đứt gãy bản địa hóa ARB (P0)**: Khi đổi ngôn ngữ sang Tiếng Anh, tab Việc làm (`job_list_screen.dart:55-80`) và Mạng xã hội (`social_feed_screen.dart:70-95`) vẫn hiển thị tiếng Việt do hardcode chuỗi trong widget.
3. **Màu sắc & khoảng cách viết cứng ngoài Theme (P1)**: Màu xanh LinkedIn cũ `#0A66C2` (`splash_screen.dart:17`), nền avatar `#CFDAF7` (`profile_page.dart:124`), nền hộp riêng tư `#F0FDF4` (`edit_profile_page.dart:45`) bị lệch khỏi tông chính `#2952CC`.
4. **Trạng thái rỗng (Empty States) tạo luồng cụt (P1)**: Màn đơn ứng tuyển (`applications_page.dart:45-55`) và tin tức (`news_page.dart:90-98`) khi rỗng chỉ có một dòng chữ xám, không có hình minh họa hay nút dẫn quay lại tab Việc làm.
5. **Điều hướng ẩn giấu tính năng cốt lõi (P1)**: Trang Hồ sơ, Kỹ năng 3 cấp độ và Up Repo thay CV bị đặt sâu trong menu Drawer của `student_home_screen.dart:102`, khiến sinh viên khó tiếp cận tính năng nổi bật.
6. **Vùng chạm dưới chuẩn A11y (P2)**: Các icon cảm xúc tại `reaction_bar.dart:40-60` có kích thước 24dp với padding chỉ 4dp, không đạt kích thước chạm tối thiểu 48x48dp.
7. **Thiếu hỗ trợ responsive (P2)**: Ngoài `job_list_screen.dart:40-42` có chia 1-3 cột, các màn còn lại cố định layout 1 cột cho mobile dọc.

---

## 2. Phân Tích Mẫu Trải Nghiệm Từ Ứng Dụng Tham Chiếu (Clay - clay.earth)

Từ 4 ảnh chụp giao diện thực tế do chủ dự án cung cấp:
- **Ngôn ngữ thị giác chủ đạo**: Phong cách "Executive Minimalist" - thanh lịch, nền trắng tinh khiết (`#FFFFFF`/`#FBFBFB`), kiểu chữ tương phản cao, phân cấp thông tin rõ ràng, loại bỏ hoàn toàn viền đậm và bóng đổ gắt.
- **Thanh điều hướng nổi (Floating Dock Bar)**: Đưa bottom bar thành một floating dock dạng pill bo tròn mềm mại (`Radius: 24-28dp`) với hiệu ứng làm mờ nhẹ (glassmorphism/blur), giúp nội dung danh sách phía dưới tràn viền tự nhiên.
- **Tổ chức tìm kiếm & Bộ lọc theo cấu trúc (Structured Chips)**: Màn tìm kiếm phân nhóm rõ ràng theo danh mục dạng hai cột: `BY LOCATION`, `BY ROLE`, `BY SKILL`, `BY EDUCATION`, đi kèm các chip gợi ý (`INTERN`, `CHIEF SCIENTIST`, v.v.). Đây là mẫu lý tưởng để áp dụng cho bộ lọc việc làm và kỹ năng của MiniLinkedIn.
- **Trợ lý AI Navigator (Nexus Style)**: Giao diện AI sử dụng các thẻ câu hỏi gợi ý (Prompt Cards) bo tròn mềm mại, viền mảnh, căn lề trái tinh tế, tích hợp dải màu gradient nhẹ ở chân trang thể hiện trạng thái hoạt động của AI.

---

## 3. Bảng Nhật Ký Truy Vấn MCP 21st.dev & Bài Học Rút Ra

Tuân thủ quy định: Chỉ dùng công cụ tìm kiếm/lấy cảm hứng (`search_components`), không dùng công cụ ghi file hay sinh mã:

| Thời điểm | Truy vấn MCP | Kết quả đáng chú ý | Bài học & Chuyển đổi sang Flutter |
|---|---|---|---|
| 21:05 | `search "chat-suggestions" --author "Alwurts"` | Component `Chat Suggestions` [id: 19162] | Bố cục thẻ gợi ý: Header icon + Description + Wrap các nút bấm bo góc 12dp, viền mỏng 1px, hiệu ứng hover/press nhẹ. Đã chuyển hóa thành `ChatSuggestions` widget. |
| 21:27 | `search "dock navigation"` | Component `Dock Nav` [id: 19177] | Thanh điều hướng nổi độc lập với Scaffold body: Dùng `Container` bo tròn 28dp, viền `BorderSide(color: border)`, `BackdropFilter` mờ nền, căn giữa mép dưới màn hình. |
| 21:27 | `search "badge"` | Component `Badge Delta` [id: 514] | Huy hiệu trạng thái kỹ năng: Kết hợp icon ngữ nghĩa (Tick xanh cho Verified, Git Commit cho Evidence, User cho Self-claimed) thay vì chỉ dùng màu sắc. |

---

## 4. Danh Sách UNKNOWN & Điểm Cần Kiểm Chứng Thiết Bị
- **UNKNOWN-1**: Cảm giác cuộn thực tế của Floating Dock khi danh sách chạm đáy màn hình (cần thiết lập `bottomPadding` khoảng 80-90dp cho ListView để không bị dock che khuất dữ liệu).
- **UNKNOWN-2**: Khả năng hiển thị của hiệu ứng kính mờ (BackdropFilter) trên các thiết bị Android tầm trung (cần có fallback nền đặc `#FFFFFF` mờ 95% khi phần cứng không hỗ trợ GPU blur mượt).

