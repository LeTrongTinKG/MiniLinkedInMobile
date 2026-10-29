// Chọn đúng bản theo nền tảng khi biên dịch:
//  - Chạy trên web  -> google_web_button_web.dart  (nút Google chính thức)
//  - Android/iOS/test -> google_web_button_stub.dart (không vẽ gì)
// Cần tách file vì thư viện của web không biên dịch được trên điện thoại.
export 'google_web_button_stub.dart'
    if (dart.library.js_interop) 'google_web_button_web.dart';
