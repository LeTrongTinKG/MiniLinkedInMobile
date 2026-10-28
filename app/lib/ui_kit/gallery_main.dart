import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'app_shad_theme.dart';
import 'ui_kit_gallery.dart';

// Điểm vào riêng để xem gallery, KHÔNG đụng vào app chính.
// Chạy: flutter run -t lib/ui_kit/gallery_main.dart
void main() {
  runApp(
    ShadApp.custom(
      theme: buildAppShadTheme(),
      appBuilder: (context) => MaterialApp(
        title: 'UI Kit Gallery',
        debugShowCheckedModeBanner: false,
        builder: (context, child) => ShadAppBuilder(child: child!),
        home: const UiKitGallery(),
      ),
    ),
  );
}
