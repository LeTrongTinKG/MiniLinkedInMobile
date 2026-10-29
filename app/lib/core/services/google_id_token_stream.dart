import 'package:google_sign_in/google_sign_in.dart';

/// Luồng idToken khi người dùng đăng nhập Google bằng NÚT CHÍNH THỨC của Google trên web.
///
/// Trên web, Google không cho app tự gọi hộp chọn tài khoản (`authenticate()` bị chặn).
/// Thay vào đó app hiện nút của Google, và khi người dùng đăng nhập xong thì Google "bắn" một
/// sự kiện. Hàm này lọc các sự kiện đó và chỉ lấy ra idToken.
/// Ví với React: giống lắng nghe một sự kiện `onCredentialResponse` rồi lấy field `credential`.
Stream<String> googleIdTokenStream() {
  return GoogleSignIn.instance.authenticationEvents
      .where((event) => event is GoogleSignInAuthenticationEventSignIn)
      .map((event) {
        final signIn = event as GoogleSignInAuthenticationEventSignIn;
        return signIn.user.authentication.idToken ?? '';
      })
      .where((idToken) => idToken.isNotEmpty);
}
