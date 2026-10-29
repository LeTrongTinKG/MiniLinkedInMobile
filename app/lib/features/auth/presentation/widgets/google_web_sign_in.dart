import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/services/google_id_token_stream.dart';
import '../providers/auth_provider.dart';
import 'google_web_button.dart';

/// Đăng nhập Google trên WEB, gồm 3 bước:
///  1. Khởi tạo Google SDK rồi hiện nút chính thức của Google.
///  2. Người dùng bấm nút, đăng nhập xong thì Google gửi về một idToken.
///  3. Gửi idToken lên server qua `AuthProvider.googleLogin` (giống luồng Android/iOS).
/// Ví với React: một component tự đăng ký lắng nghe sự kiện trong useEffect và gỡ khi unmount.
class GoogleWebSignIn extends StatefulWidget {
  const GoogleWebSignIn({
    super.key,
    this.onSuccess,
    this.tokens,
    this.clientIdConfigured,
  });

  final VoidCallback? onSuccess;

  /// Luồng idToken. Mặc định lấy từ Google; test truyền luồng giả vào đây.
  final Stream<String>? tokens;

  /// Đã truyền GOOGLE_CLIENT_ID khi chạy chưa. Mặc định đọc từ AppConfig; test truyền giá trị giả.
  final bool? clientIdConfigured;

  @override
  State<GoogleWebSignIn> createState() => _GoogleWebSignInState();
}

class _GoogleWebSignInState extends State<GoogleWebSignIn> {
  StreamSubscription<String>? _subscription;
  bool _ready = false; // SDK đã khởi tạo xong chưa (giống useState(false))
  Widget? _googleButton; // nút Google: tạo MỘT lần rồi dùng lại, vẽ lại giao diện không dựng lại nút

  bool get _configured => widget.clientIdConfigured ?? AppConfig.googleClientId.isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (_configured) _start();
  }

  // Khởi tạo SDK trước, rồi mới bắt đầu nghe sự kiện đăng nhập
  Future<void> _start() async {
    await context.read<AuthProvider>().prepareGoogleSignIn();
    if (!mounted) return;
    _subscription = (widget.tokens ?? googleIdTokenStream()).listen(_onToken, onError: _onError);
    setState(() => _ready = true);
  }

  // Có idToken: gửi lên server; thành công thì báo cho màn hình cha (thường là chuyển trang)
  Future<void> _onToken(String idToken) async {
    final auth = context.read<AuthProvider>();
    await auth.googleLogin(idToken);
    if (mounted && auth.isAuthenticated) widget.onSuccess?.call();
  }

  void _onError(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      const SnackBar(content: Text('Đăng nhập Google không thành công. Vui lòng thử lại.')),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel(); // dọn như return cleanup trong useEffect
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Chưa truyền GOOGLE_CLIENT_ID: nói rõ thiếu gì thay vì để nút im lặng không chạy
    if (!_configured) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Chưa cấu hình đăng nhập Google. Chạy lại app với --dart-define=GOOGLE_CLIENT_ID=<web client id>',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
      );
    }

    final loading = context.select<AuthProvider, bool>((auth) => auth.isLoading);
    return SizedBox(
      height: 50,
      child: Center(
        child: (loading || !_ready)
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.2),
              )
            : (_googleButton ??= buildGoogleWebButton()),
      ),
    );
  }
}
