# ADR-0009 · Mặc định hồ sơ ở chế độ riêng tư (Private by Default)

- **Trạng thái:** Được chấp nhận · 2026-10-31
- **Người đề xuất:** boppyorca & Antigravity Pair
- **Liên quan:** [F-002](../SPEC.md#f-002), Ticket 02

## Bối cảnh
Khi người dùng (đặc biệt là sinh viên công nghệ thông tin) tham gia nền tảng Mini LinkedIn, dữ liệu học vấn, vị trí, hồ sơ và kinh nghiệm có thể bị thu thập mà không có sự kiểm soát rõ ràng nếu mặc định công khai.
Để tuân thủ các nguyên tắc bảo vệ quyền riêng tư hiện đại (như GDPR và tinh thần thiết kế của dự án Atom), hệ thống cần đặt quyền riêng tư làm ưu tiên hàng đầu.

## Quyết định
1. **Private by default**: Mọi tài khoản người dùng khi tạo mới hoặc cập nhật thông tin đều có cờ `isPrivate: true` theo mặc định.
2. **Quyền kiểm soát của người dùng**: Người dùng có thể bật/tắt (toggle) trạng thái này trong màn hình Chỉnh sửa hồ sơ (Edit Profile).
3. **Hiển thị có điều kiện**: Khi ở chế độ riêng tư, thông tin chi tiết chỉ được chia sẻ cho nhà tuyển dụng khi ứng viên chủ động nộp đơn ứng tuyển (Apply) vào công việc của nhà tuyển dụng đó.
4. **Chuẩn vùng bấm (A11y)**: Công tắc chuyển đổi phải đáp ứng vùng chạm tối thiểu 48x48 dp và gắn Semantics giải thích rõ ràng.

## Hệ quả
- **Tích cực**: Bảo vệ quyền riêng tư ứng viên tối đa, tăng độ tin cậy của nền tảng.
- **Tiêu cực**: Nhà tuyển dụng cần nhận được ứng tuyển hoặc sự đồng ý từ ứng viên mới có thể xem toàn bộ chi tiết hồ sơ.

