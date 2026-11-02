import 'package:flutter/material.dart';

import 'ui_tokens.dart';

// Đường kẻ ngang. Ví với React: <hr />
class AppDivider extends StatelessWidget {
  const AppDivider({super.key, this.height = 16});

  final double height; // tổng chiều cao gồm khoảng trống trên/dưới

  @override
  Widget build(BuildContext context) {
    return Divider(height: height, thickness: 1, color: UiTokens.border);
  }
}
