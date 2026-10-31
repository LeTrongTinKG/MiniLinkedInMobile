# Danh sách Đặc tả Tính năng (Feature Specifications)

Tài liệu đặc tả các tính năng chính thức của nền tảng Mini LinkedIn Mobile.

---

### F-001 · Xác thực người dùng đa kênh
- **Mô tả:** Đăng ký và đăng nhập bảo mật qua Email/Mật khẩu, Google OAuth và GitHub OAuth.
- **Quy chuẩn:** [ADR-0002](adr/0002-custom-jwt-auth.md) · **Ticket:** [Ticket 01](tickets/01-email-auth.md)

### F-002 · Chỉnh sửa hồ sơ & Mặc định riêng tư (Private by Default)
- **Mô tả:** Chỉnh sửa thông tin cá nhân; mặc định tài khoản ở chế độ riêng tư để bảo vệ dữ liệu ứng viên.
- **Quy chuẩn:** [ADR-0009](adr/0009-private-by-default-profile.md) · **Ticket:** [Ticket 02](tickets/02-edit-profile-private-default.md)

### F-003 · Chuyển đổi ngôn ngữ tức thì (vi / en)
- **Mô tả:** Hỗ trợ song ngữ Tiếng Việt và Tiếng Anh với 100% chuỗi UI quản lý qua ARB chuẩn đối xứng.
- **Quy chuẩn:** **Ticket:** [Ticket 03](tickets/03-instant-language-switch.md)

### F-004 · Kỹ năng tự khai (Self-claimed Skills)
- **Mô tả:** Ứng viên chủ động thêm hoặc xóa các kỹ năng kỹ thuật cá nhân.
- **Quy chuẩn:** [ADR-0005](adr/0005-skills-need-evidence.md) · **Ticket:** [Ticket 04](tickets/04-skill-confidence-3-tiers.md)

### F-005 · Up Repo GitHub thay vì CV (Repo Evidence)
- **Mô tả:** Gắn link kho mã nguồn GitHub làm bằng chứng năng lực thực tế.
- **Quy chuẩn:** [ADR-0010](adr/0010-rule-based-skill-extraction.md) · **Ticket:** [Ticket 10](tickets/10-repo-upload-evidence.md)

### F-006 · Xin phép phân tích tự động (AI Consent)
- **Mô tả:** Minh bạch dữ liệu được đọc và không bao giờ đọc trước khi phân tích hồ sơ.
- **Quy chuẩn:** [ADR-0010](adr/0010-rule-based-skill-extraction.md) · **Ticket:** [Ticket 06](tickets/06-ai-analysis-consent.md)

### F-007 · Xác nhận kỹ năng (Skill Endorsement)
- **Mô tả:** Đồng nghiệp hoặc mentor xác nhận kỹ năng dựa trên bằng chứng minh bạch.
- **Quy chuẩn:** [ADR-0007](adr/0007-confidence-quota-and-match.md) · **Ticket:** [Ticket 04](tickets/04-skill-confidence-3-tiers.md)

### F-008 · Kỹ năng 3 cấp độ tin cậy (3-tier Confidence)
- **Mô tả:** Phân loại rõ ràng 3 cấp độ: Tự khai (`self_claimed`), Có bằng chứng (`evidenced`), Được xác nhận (`endorsed`).
- **Quy chuẩn:** [ADR-0007](adr/0007-confidence-quota-and-match.md) · **Ticket:** [Ticket 04](tickets/04-skill-confidence-3-tiers.md)

### F-014 · Tra cứu lương ẩn danh (Anonymous Salary Sharing)
- **Mô tả:** Mô hình Cho - Nhận (Give-to-get) chia sẻ mức lương thực tế với ngưỡng bảo mật danh tính N >= 5.
- **Quy chuẩn:** **Ticket:** [Ticket 13](tickets/13-anonymous-salary-sharing.md)

### F-019 · Chuẩn tiếp cận (A11y Baseline)
- **Mô tả:** Vùng bấm tối thiểu 48x48 dp, gắn nhãn Semantics cho trình đọc màn hình TalkBack/VoiceOver.
- **Quy chuẩn:** Áp dụng trên toàn bộ thành phần giao diện.

