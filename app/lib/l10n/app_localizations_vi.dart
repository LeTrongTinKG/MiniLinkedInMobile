// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Atom';

  @override
  String get save => 'Lưu';

  @override
  String get cancel => 'Hủy';

  @override
  String get loading => 'Đang tải...';

  @override
  String get retry => 'Thử lại';

  @override
  String get delete => 'Xóa';

  @override
  String get edit => 'Sửa';

  @override
  String get success => 'Thành công';

  @override
  String get signIn => 'Đăng nhập';

  @override
  String get signOut => 'Đăng xuất';

  @override
  String get email => 'Email';

  @override
  String get password => 'Mật khẩu';

  @override
  String get loginTitle => 'Đăng nhập vào Atom';

  @override
  String get registerTitle => 'Đăng ký tài khoản';

  @override
  String get profileTitle => 'Hồ sơ cá nhân';

  @override
  String get editProfile => 'Chỉnh sửa hồ sơ';

  @override
  String get fullName => 'Họ và tên';

  @override
  String get headline => 'Chức danh / Headline';

  @override
  String get location => 'Khu vực';

  @override
  String get school => 'Trường đại học';

  @override
  String get major => 'Chuyên ngành';

  @override
  String get about => 'Giới thiệu bản thân';

  @override
  String get privateProfile => 'Hồ sơ riêng tư (Mặc định)';

  @override
  String get privateProfileDesc =>
      'Mặc định ở chế độ riêng tư. Nhà tuyển dụng cần bạn đồng ý trước khi xem chi tiết.';

  @override
  String get saveProfileSuccess => 'Đã cập nhật hồ sơ thành công!';

  @override
  String get nameCannotBeEmpty => 'Họ và tên không được để trống';

  @override
  String get skillsTitle => 'Kỹ năng & Bằng chứng';

  @override
  String get skillsSubTitle =>
      '3 cấp độ tin cậy: Tự khai, Có bằng chứng, hoặc Được xác nhận';

  @override
  String get addSkill => 'Thêm kỹ năng';

  @override
  String get skillNameHint => 'Nhập tên kỹ năng (vd: Flutter, Go)';

  @override
  String get confidenceSelfClaimed => 'Tự khai';

  @override
  String get confidenceEvidenced => 'Có bằng chứng';

  @override
  String get confidenceEndorsed => 'Được xác nhận';

  @override
  String get repoUploadTitle => 'Up Repo GitHub làm bằng chứng';

  @override
  String get repoUploadDesc =>
      'Dán URL repo GitHub của bạn làm bằng chứng năng lực thực tế thay cho CV truyền thống.';

  @override
  String get githubRepoUrl => 'Đường dẫn GitHub Repository';

  @override
  String get scanRepoButton => 'Trích xuất kỹ năng & Gắn bằng chứng';

  @override
  String get consentTitle => 'Đồng ý phân tích dữ liệu tự động';

  @override
  String get consentDesc =>
      'Chúng tôi tôn trọng quyền riêng tư. Minh bạch dữ liệu nào được đọc và không bao giờ đọc.';

  @override
  String get agreeButton => 'Tôi đồng ý';

  @override
  String get withdrawButton => 'Rút lại sự đồng ý';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get vietnamese => 'Tiếng Việt';

  @override
  String get english => 'English';

  @override
  String get switchLanguage => 'Chuyển đổi ngôn ngữ';
}
