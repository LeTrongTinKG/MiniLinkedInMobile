import 'package:flutter/material.dart';
import '../../../../ui_kit/ui_kit.dart';
import '../social_strings.dart';

/// Ô "Bạn đang nghĩ gì?" ở đầu feed: avatar + ô giả bo tròn + nút ảnh. Bấm đâu cũng mở màn soạn bài.
class ComposerBox extends StatelessWidget {
  const ComposerBox({super.key, required this.userName, this.userAvatar, required this.onTap});

  final String userName;
  final String? userAvatar;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          AppAvatar(imageUrl: userAvatar, name: userName, size: 40),
          const SizedBox(width: 10),
          // Ô giả: không phải ô nhập thật, chỉ là nút bo tròn trông giống ô nhập
          Expanded(
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                decoration: BoxDecoration(
                  color: UiTokens.muted,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Text(SocialStrings.composerHint,
                    style: TextStyle(color: UiTokens.mutedForeground)),
              ),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: SocialStrings.composerPhoto,
            icon: const Icon(Icons.photo_library_outlined, color: Color(0xFF45BD62)),
            onPressed: onTap,
          ),
        ],
      ),
    );
  }
}
