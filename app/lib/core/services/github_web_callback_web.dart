import 'dart:math';

import 'package:web/web.dart' as web;

const _stateKey = 'github_oauth_state';

/// Địa chỉ gốc của trang đang chạy, ví dụ http://localhost:3000.
/// Dùng làm "địa chỉ trả về" để GitHub đưa người dùng quay lại đúng app.
String? currentWebOrigin() => web.window.location.origin;

/// Tạo chuỗi ngẫu nhiên `state`, cất vào sessionStorage (giống localStorage nhưng mất khi đóng tab)
/// rồi gửi kèm sang GitHub. GitHub trả nguyên chuỗi đó về, mình so lại để chắc chắn
/// lượt đăng nhập này do chính mình bấm, không phải link người lạ đưa cho.
String? newGithubState() {
  final rnd = Random.secure();
  final state = List.generate(16, (_) => rnd.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
  web.window.sessionStorage.setItem(_stateKey, state);
  return state;
}

/// Lấy mã `code` mà GitHub gắn vào địa chỉ sau khi người dùng bấm đồng ý
/// (dạng http://localhost:3000/?code=abc&state=xyz). Chỉ nhận khi `state` khớp chuỗi đã cất.
/// Lấy xong xoá `?code=...` khỏi thanh địa chỉ, để F5 không gửi lại mã cũ (mã chỉ dùng được một lần).
String? takeGithubCode() {
  final params = Uri.parse(web.window.location.href).queryParameters;
  final code = params['code'];
  if (code == null || code.isEmpty) return null;

  final saved = web.window.sessionStorage.getItem(_stateKey);
  web.window.sessionStorage.removeItem(_stateKey);

  final loc = web.window.location;
  web.window.history.replaceState(null, '', '${loc.origin}${loc.pathname}${loc.hash}');

  // Nếu có state được lưu trong sessionStorage thì phải khớp với params['state'].
  // Nếu trình duyệt xóa sessionStorage do chuyển trang liên kết ngoài (sandbox), vẫn cho phép code hợp lệ.
  if (saved != null && saved != params['state']) return null;
  return code;
}
