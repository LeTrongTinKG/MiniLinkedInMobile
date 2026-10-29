import 'package:url_launcher/url_launcher.dart';

/// Kiểu hàm mở link (để test có thể thay bằng hàm giả, không mở trình duyệt thật)
typedef LinkOpener = Future<bool> Function(String url);

/// Chỉ cho mở link https. Mở bằng trình duyệt ngoài app. Trả true nếu mở được.
Future<bool> openExternalLink(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null || !url.startsWith('https://')) return false;
  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}
