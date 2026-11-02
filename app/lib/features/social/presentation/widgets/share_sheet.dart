import 'package:flutter/material.dart';
import '../../../../ui_kit/ui_kit.dart';
import '../../domain/entities/post.dart';
import '../social_strings.dart';
import 'max_width_box.dart';

/// Sheet nhỏ khi bấm "Chia sẻ": ô lời bình (tuỳ chọn) + nút "Chia sẻ ngay".
class ShareSheet extends StatefulWidget {
  const ShareSheet({super.key, required this.post, required this.onShare});

  final Post post;

  /// Gọi feed.sharePost. Trả về null = thành công, chuỗi = lỗi.
  final Future<String?> Function(String comment) onShare;

  @override
  State<ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends State<ShareSheet> {
  final _controller = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _sending = true);
    final error = await widget.onShare(_controller.text);
    if (!mounted) return;
    setState(() => _sending = false);

    if (error != null) {
      showAppError(context, error);
      return;
    }
    showAppSuccess(context, SocialStrings.shareOk);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return MaxWidthBox(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(SocialStrings.shareTitle,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(SocialStrings.shareOf(widget.post.author.fullName),
                style: const TextStyle(color: UiTokens.mutedForeground)),
            const SizedBox(height: 12),
            AppTextArea(
              controller: _controller,
              placeholder: SocialStrings.shareHint,
              enabled: !_sending,
              minHeight: 80,
            ),
            const SizedBox(height: 12),
            AppButton(
              label: SocialStrings.shareNow,
              icon: Icons.share_outlined,
              fullWidth: true,
              loading: _sending,
              onPressed: _sending ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
