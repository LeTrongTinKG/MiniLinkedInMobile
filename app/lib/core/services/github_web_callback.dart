// Chọn đúng bản theo nền tảng khi biên dịch (cùng cách với google_web_button.dart):
//  - Chạy trên web -> github_web_callback_web.dart
//  - Android/iOS/test -> github_web_callback_stub.dart
export 'github_web_callback_stub.dart'
    if (dart.library.js_interop) 'github_web_callback_web.dart';
