# Tiêu Chí Nghiệm Thu Tổng Thể Toàn Dự Án (05-ACCEPTANCE.md)

Bộ checklist nghiệm thu nghiêm ngặt trước khi hoàn tất toàn bộ quá trình tái thiết kế UI/UX app MiniLinkedIn.

---

## 1. Trợ Năng (Accessibility & A11y Baseline)
- [ ] **Vùng chạm tối thiểu**: 100% nút bấm, ô nhập, icon tương tác đạt kích thước chạm $\ge 48 \times 48\text{dp}$.
- [ ] **Tỷ lệ tương phản (WCAG AA)**: Văn bản chính so với nền đạt $\ge 4.5:1$; văn bản lớn và thành phần UI đạt $\ge 3:1$.
- [ ] **Nhãn ngữ nghĩa (Semantics)**: Mọi icon hành động độc lập, nút bấm và chip kỹ năng đều có `Semantics(label: ...)` rõ ràng, thân thiện với trình đọc màn hình TalkBack / VoiceOver.
- [ ] **Không dựa vào màu sắc**: Mọi trạng thái cảnh báo, lỗi, cấp độ tin cậy đều đi kèm icon hoặc nhãn chữ cụ thể.

---

## 2. Thích Ứng Thiết Bị & Co Giãn Phông Chữ (Responsive & Text Scale)
- [ ] **Màn hình nhỏ (360dp)**: Không xuất hiện lỗi tràn pixel (`RenderFlex overflowed`) trên thiết bị có độ phân giải nhỏ.
- [ ] **Màn hình lớn / Web / Tablet**: Danh sách việc làm tự động co giãn từ 1 cột sang 2-3 cột cân đối.
- [ ] **Phóng đại cỡ chữ (Text Scaling 1.3x - 2.0x)**: Toàn bộ layout co giãn an toàn, văn bản tự động xuống dòng hoặc cuộn nội dung mà không bị cắt cụt.
- [ ] **Khoảng đệm tai thỏ / Home Indicator**: `FloatingDockBar` và nội dung cuộn đáy hiển thị hoàn hảo trên cả Android và iOS có Dynamic Island / Home Bar.

---

## 3. Trạng Thái Ngoại Tuyến & Xóa Bỏ Luồng Cụt
- [ ] **Không có màn hình cụt**: 100% trạng thái rỗng (`EmptyStateView`) đều có thông điệp hướng dẫn và nút điều hướng sang tính năng liên quan.
- [ ] **Xử lý sự cố mạng chân thật**: Khi mất mạng, hiển thị card cảnh báo mạng nhẹ nhàng kèm nút "Thử lại", không gây cảm giác sập app.
- [ ] **Dữ liệu cục bộ / Cache**: Tin tức và danh sách việc làm đã tải trước đó vẫn hiển thị được khi ngoại tuyến.

---

## 4. Tính Nhất Quán Thị Giác (Clay Executive Minimalist)
- [ ] **Bảng màu chủ đạo**: Nền Slate 50 `#F8FAFC`, bề mặt trắng tuyết `#FFFFFF`, điểm nhấn xanh `#2952CC`, chữ Slate 900 `#0F172A`.
- [ ] **Hệ thống bo góc (Border Radius)**: Chip lọc 8dp, ô nhập/composer 12dp, thẻ card 16dp, nút pill 20dp, bottom sheet 24dp, Floating Dock 28dp.
- [ ] **Viền & Bóng đổ**: 100% thẻ sử dụng viền mỏng 1px `#E2E8F0` và đổ bóng cực nhẹ `0 1px 3px rgba(0,0,0,0.05)`.
- [ ] **Đệm chống che lấp**: Tất cả màn hình cuộn chính đều có `bottomPadding: 88dp`, bảo vệ nội dung không bị `FloatingDockBar` che lấp.

---

## 5. Rà Soát Giá Trị Cứng & Chất Lượng Mã Nguồn
- [ ] **Không còn mã màu cứng**: Không còn `Color(0xFF...)` xuất hiện rải rác ngoài thư mục `lib/core/theme/`.
- [ ] **Khoảng cách theo chuẩn 4/8dp**: Thay thế toàn bộ số đo padding tùy tiện bằng `AppSpacing`.
- [ ] **Kiểm tra mã nguồn tĩnh**: Lệnh `flutter analyze` đạt 0 error, 0 warning.
- [ ] **Kiểm thử hồi quy**: Toàn bộ unit tests và widget tests hiện có tiếp tục PASS 100%.

---

## 6. Tuân Thủ Ràng Buộc Sản Phẩm & Đạo Đức AI
- [ ] **Bảo toàn hợp đồng ViewModel**: Giữ nguyên 100% logic, tên method, route và logic nghiệp vụ hiện có.
- [ ] **Quyền riêng tư mặc định Atom**: Hồ sơ sinh viên luôn khởi tạo ở chế độ riêng tư `isPrivate: true` (ADR-0010).
- [ ] **Trung thực về bằng chứng**: 3 cấp độ tin cậy kỹ năng (`VERIFIED`, `EVIDENCE_BASED`, `SELF_CLAIMED`) được hiển thị minh bạch; không tự phong "thành thạo" hay hiển thị như chứng chỉ.
- [ ] **Minh bạch Chatbot**: Phân biệt rành mạch giữa Trợ lý kỹ năng sinh viên (F-013, AI nội bộ 0 USD) và Chatbot tuyển dụng (F-018).

