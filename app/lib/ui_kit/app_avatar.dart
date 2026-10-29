import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'ui_tokens.dart';

// Ảnh đại diện: có ảnh mạng thì hiện ảnh, không thì hiện chữ cái đầu.
// Ví với React: <Avatar src={url} fallback="A" />
//
// Vì sao KHÔNG dùng ShadAvatar: nó tải ảnh bằng mã Dart (XHR) và thử lại mỗi lần vẽ lại. Ảnh đại diện
// Google (lh3.googleusercontent.com) rất dễ trả lỗi 429 "quá nhiều yêu cầu", nên app tự đẩy mình vào
// vòng lặp tải lại và console đầy lỗi đỏ. Bản này: dùng thẻ <img> của trình duyệt (có cache),
// ảnh lỗi thì hiện chữ cái đầu và nhớ địa chỉ lỗi để không gọi lại trong phiên chạy.
class AppAvatar extends StatelessWidget {
  const AppAvatar({super.key, this.imageUrl, this.name = '', this.size = 40});

  final String? imageUrl;
  final String name; // dùng để lấy chữ cái đầu
  final double size;

  // Các địa chỉ ảnh đã từng lỗi trong phiên chạy này: không tải lại, hiện luôn chữ cái đầu
  static final Set<String> _failedUrls = {};

  // Lấy chữ cái đầu của tên, không có tên thì hiện "?"
  String get _initial {
    final t = name.trim();
    return t.isEmpty ? '?' : t.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    // Khối chữ cái: dùng cho "không có ảnh", "đang tải" và "ảnh lỗi"
    final fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: UiTokens.muted,
        shape: BoxShape.circle,
      ),
      child: Text(
        _initial,
        style: TextStyle(
          fontSize: size * 0.4,
          fontWeight: FontWeight.w600,
          color: UiTokens.foreground,
        ),
      ),
    );

    final url = imageUrl;
    if (url == null || url.isEmpty || _failedUrls.contains(url)) return fallback;

    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          // Web: để trình duyệt tự tải bằng thẻ <img> (dùng cache HTTP của trình duyệt)
          webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
          // Điện thoại: giải mã đúng cỡ cần dùng cho đỡ tốn bộ nhớ (web không cần)
          cacheWidth: kIsWeb ? null : (size * MediaQuery.devicePixelRatioOf(context)).round(),
          gaplessPlayback: true,
          // Chưa tải xong thì hiện chữ cái đầu
          frameBuilder: (context, child, frame, wasSyncLoaded) =>
              (wasSyncLoaded || frame != null) ? child : fallback,
          // Lỗi thì hiện chữ cái đầu và ghi nhớ để lần vẽ sau không gọi lại
          errorBuilder: (context, error, stack) {
            _failedUrls.add(url);
            return fallback;
          },
        ),
      ),
    );
  }
}
