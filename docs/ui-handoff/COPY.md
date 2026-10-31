# Bản Sao Nội Dung & Chuỗi Bản Địa Hóa (COPY.md)

## 1. Ngôn Ngữ Hỗ Trợ
- **Tiếng Việt (`vi`)**: Ngôn ngữ mặc định (`app/lib/l10n/app_vi.arb`).
- **Tiếng Anh (`en`)**: Ngôn ngữ thứ hai (`app/lib/l10n/app_en.arb`).
- Hệ thống hỗ trợ chuyển đổi runtime tức thì 100% qua `LocaleViewModel` (`app/lib/core/localization/locale_view_model.dart:6-35`).

## 2. Danh Sách Khóa l10n Tập Trung Theo Màn Hình

| Khóa l10n | Màn hình | Ý nghĩa (Tiếng Việt) | Ý nghĩa (Tiếng Anh) |
|---|---|---|---|
| `editProfileTitle` | S-10 EditProfile | Chỉnh sửa hồ sơ | Edit Profile |
| `fullNameLabel` | S-10 EditProfile | Họ và tên | Full Name |
| `fullNameHint` | S-10 EditProfile | Nhập họ và tên đầy đủ | Enter your full name |
| `fullNameRequired` | S-10 EditProfile | Vui lòng nhập họ và tên | Full name is required |
| `privateProfileTitle` | S-10 EditProfile | Hồ sơ riêng tư (Mặc định) | Private Profile (Default) |
| `privateProfileSubtitle` | S-10 EditProfile | Chỉ nhà tuyển dụng được bạn ứng tuyển mới xem được | Only recruiters you apply to can view |
| `privateProfileBadge` | S-10 EditProfile | Quyền riêng tư được bảo vệ mặc định | Privacy protected by default |
| `saveChangesButton` | S-10 EditProfile | Lưu thay đổi | Save Changes |
| `saveSuccessMessage` | S-10 EditProfile | Cập nhật hồ sơ thành công | Profile updated successfully |
| `saveErrorMessage` | S-10 EditProfile | Không thể lưu thay đổi, vui lòng thử lại | Failed to save changes, please try again |
| `languageSwitchTooltip` | S-09, S-10 | Chuyển đổi ngôn ngữ | Switch Language |
| `confirm` / `cancel` | Toàn app | Đồng ý / Hủy | Confirm / Cancel |
| `retry` | Toàn app | Thử lại | Retry |

## 3. Các Chuỗi Chưa Qua l10n (Cần Bổ Sung Vào ARB)
Các màn hình cũ hiện đang hardcode tiếng Việt trực tiếp trong mã nguồn giao diện:
- **Việc làm (Jobs - S-05)**: `"Tìm kiếm việc làm..."`, `"Bộ lọc"`, `"Địa điểm"`, `"Mức lương"`, `"Ứng tuyển ngay"`, `"Đã nộp đơn"`, `"Không tìm thấy việc làm phù hợp"`.
- **Mạng xã hội (Social - S-06, S-07)**: `"Bạn đang nghĩ gì?"`, `"Đăng bài"`, `"Thích"`, `"Bình luận"`, `"Chia sẻ"`, `"Viết bình luận..."`, `"Chưa có bài viết nào"`.
- **Tin tức (News - S-08)**: `"Tin tức công nghệ"`, `"Không thể tải tin tức"`, `"Kéo để làm mới"`.
- **Xác thực (Auth - S-02, S-03)**: `"Chào mừng trở lại"`, `"Đăng nhập với Google"`, `"Đăng nhập với GitHub"`, `"Tôi là sinh viên"`, `"Tôi là nhà tuyển dụng"`.
- **Đơn ứng tuyển (Applications - S-14)**: `"Đơn ứng tuyển của tôi"`, `"Đang xét duyệt"`, `"Được mời phỏng vấn"`, `"Bị từ chối"`.

---

## 4. CHUỖI CÓ TÍNH CAM KẾT, KHÔNG ĐƯỢC ĐỔI Ý NGHĨA (Critical Commitments)

> [!CAUTION]
> Các chuỗi dưới đây mang tính cam kết pháp lý, bảo vệ quyền riêng tư dữ liệu và kiến trúc AI 0 USD. Agent dựng lại UI **TUYỆT ĐỐI KHÔNG ĐƯỢC THAY ĐỔI Ý NGHĨA**:

1. **Quyền riêng tư & Đồng ý AI (AI Consent - ADR-0010, F-006, Ticket 14)**:
   - *Vị trí*: `features/consent/presentation/screens/analysis_consent_screen.dart:40-95`.
   - *Nội dung cam kết*: "Hệ thống AI nội bộ chỉ đọc các kỹ năng và thông tin trong CV/Repo được bạn cấp phép để gợi ý lộ trình; **TUYỆT ĐỐI KHÔNG** gửi dữ liệu cá nhân ra mô hình thương mại bên ngoài và **KHÔNG** dùng để huấn luyện mô hình bên thứ ba".
2. **Hồ sơ riêng tư theo mặc định (Private by default - ADR-0009, Ticket 02)**:
   - *Vị trí*: `features/profile/edit_profile_page.dart:45-80`.
   - *Nội dung cam kết*: Tài khoản tạo mới luôn có cờ `is_private = true`. Giao diện phải giải thích rõ: "Chỉ nhà tuyển dụng của vị trí bạn chủ động nộp đơn mới có quyền truy cập hồ sơ chi tiết".
3. **Kỹ năng 3 cấp độ tin cậy (3-Tier Skill Confidence - F-008..010, Ticket 04)**:
   - *Vị trí*: `features/skills/presentation/widgets/confidence_badge.dart:15-40`.
   - *Nội dung cam kết*:
     - `Verified (Cấp 1)`: Đã xác thực qua bài test hoặc chứng chỉ uy tín.
     - `Evidence (Cấp 2)`: Có minh chứng từ dự án thật / commit code trên GitHub Repo.
     - `Self-claimed (Cấp 3)`: Kỹ năng do người dùng tự khai báo.
4. **Quét GitHub Repository thay CV (Repo Evidence Upload)**:
   - *Vị trí*: `features/skills/presentation/screens/repo_upload_screen.dart:35-85`.
   - *Nội dung cam kết*: "Chỉ quét phân tích cấu trúc thư mục, ngôn ngữ và dependencies công khai; không sao chép hay giữ bản quyền mã nguồn của ứng viên".
5. **Phân biệt rạch ròi 2 Chatbot trong ứng dụng**:
   - *Bot 1 - Coach Sheet (`features/coach/presentation/coach_sheet.dart`)*: "Gia sư kỹ năng & luyện phỏng vấn AI - Hạn mức nghiêm ngặt 10 câu hỏi/ngày/tài khoản".
   - *Bot 2 - RAG Doc Bot (F-026..028)*: "Trợ lý tra cứu chính sách tuyển dụng & quy chế nội bộ 0 USD - Trả lời có trích dẫn nguồn văn bản".
6. **Báo cáo, Chặn & Xóa tài khoản vĩnh viễn**:
   - *Vị trí*: `ui_kit/app_confirm_dialog.dart`, `features/social/.../post_card.dart`.
   - *Nội dung cam kết*: "Hành động chặn sẽ ngăn đối phương tương tác và xem bài viết. Xóa tài khoản sẽ xóa toàn bộ dữ liệu ứng tuyển và hồ sơ không thể khôi phục".

