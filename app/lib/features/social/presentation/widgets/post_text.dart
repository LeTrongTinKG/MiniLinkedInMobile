import 'package:flutter/material.dart';
import '../../../../ui_kit/ui_kit.dart';
import '../social_strings.dart';

/// Nội dung chữ của bài.
/// - Đoạn nằm giữa hai dấu ``` hiện thành khối code (nền xám, chữ monospace).
/// - Chữ thường dài quá 6 dòng thì rút gọn + nút "Xem thêm".
class PostText extends StatefulWidget {
  const PostText({super.key, required this.content});
  final String content;

  @override
  State<PostText> createState() => _PostTextState();
}

class _PostTextState extends State<PostText> {
  static const _style = TextStyle(fontSize: 15, height: 1.35, color: UiTokens.foreground);
  static const _codeStyle = TextStyle(
      fontSize: 13, height: 1.4, fontFamily: 'monospace', fontFamilyFallback: ['Courier New']);

  bool _expanded = false; // useState(false)

  @override
  Widget build(BuildContext context) {
    if (widget.content.trim().isEmpty) return const SizedBox.shrink();

    // Tách theo ```: phần số lẻ (1, 3, ...) là code
    final parts = widget.content.split('```');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < parts.length; i++)
          if (parts[i].trim().isNotEmpty)
            i.isOdd
                ? _codeBlock(parts[i].trim())
                : _plain(parts[i].trim(), canCollapse: parts.length == 1),
      ],
    );
  }

  Widget _codeBlock(String code) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: UiTokens.muted,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SelectableText(code, style: _codeStyle),
    );
  }

  Widget _plain(String text, {required bool canCollapse}) {
    if (!canCollapse) return Text(text, style: _style);

    // Đo thử: chữ có vượt 6 dòng ở chiều rộng hiện tại không?
    return LayoutBuilder(builder: (context, box) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: _style),
        maxLines: 6,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: box.maxWidth);
      final tooLong = painter.didExceedMaxLines;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text,
              style: _style,
              maxLines: _expanded || !tooLong ? null : 6,
              overflow: TextOverflow.ellipsis),
          if (tooLong && !_expanded)
            GestureDetector(
              onTap: () => setState(() => _expanded = true),
              child: const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(SocialStrings.seeMore,
                    style: TextStyle(fontWeight: FontWeight.w600, color: UiTokens.mutedForeground)),
              ),
            ),
        ],
      );
    });
  }
}
