import 'package:flutter/widgets.dart';
import 'package:google_sign_in_web/web_only.dart' as web;

/// Bản cho web: nút "Tiếp tục với Google" do chính Google vẽ.
/// Chỉ chỉnh được kiểu dáng (viền, kích thước, bo tròn, ngôn ngữ), không đổi được chữ hay logo.
Widget buildGoogleWebButton() {
  return web.renderButton(
    configuration: web.GSIButtonConfiguration(
      type: web.GSIButtonType.standard,
      theme: web.GSIButtonTheme.outline,
      size: web.GSIButtonSize.large,
      text: web.GSIButtonText.continueWith,
      shape: web.GSIButtonShape.pill,
      logoAlignment: web.GSIButtonLogoAlignment.left,
      minimumWidth: 280,
      locale: 'vi',
    ),
  );
}
