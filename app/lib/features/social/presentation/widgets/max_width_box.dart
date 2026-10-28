import 'package:flutter/material.dart';

/// Chiều rộng tối đa của cột nội dung (màn rộng như web thì căn giữa, điện thoại thì full).
/// Ví với React: <div style={{ maxWidth: 680, margin: '0 auto' }}>.
const double socialMaxWidth = 680;

class MaxWidthBox extends StatelessWidget {
  const MaxWidthBox({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: socialMaxWidth),
        child: child,
      ),
    );
  }
}
