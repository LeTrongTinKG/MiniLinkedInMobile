import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:app/core/theme/app_colors.dart';
import '../../domain/entities/reaction_kind.dart';
import '../../domain/entities/reaction_summary.dart';
import '../providers/interaction_provider.dart';
import 'comment_sheet.dart';

/// Thanh tương tác kiểu Facebook gắn dưới mỗi tin tuyển dụng:
/// hàng thống kê (cảm xúc · bình luận) + 3 nút Thích / Bình luận / Chia sẻ.
class ReactionBar extends StatefulWidget {
  const ReactionBar({
    super.key,
    required this.targetId,
    this.shareText,
  });

  final String targetId; // id tin tuyển dụng
  final String? shareText; // nội dung sao chép khi bấm Chia sẻ

  @override
  State<ReactionBar> createState() => _ReactionBarState();
}

class _ReactionBarState extends State<ReactionBar> {
  final _likeKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<InteractionProvider>().ensureLoaded(widget.targetId);
    });
  }

  @override
  void didUpdateWidget(covariant ReactionBar old) {
    super.didUpdateWidget(old);
    if (old.targetId != widget.targetId) {
      context.read<InteractionProvider>().ensureLoaded(widget.targetId);
    }
  }

  Future<void> _apply(ReactionKind? next) async {
    final messenger = ScaffoldMessenger.of(context);
    final error = await context.read<InteractionProvider>().react(widget.targetId, next);
    if (error != null) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text('Chưa thể lưu cảm xúc: $error'),
          behavior: SnackBarBehavior.floating,
        ));
    }
  }

  void _onTapLike(ReactionSummary s) => _apply(s.myReaction == null ? ReactionKind.like : null);

  Future<void> _onLongPressLike() async {
    final box = _likeKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    HapticFeedback.selectionClick();
    final origin = box.localToGlobal(Offset.zero);
    final picked = await showMenu<ReactionKind>(
      context: context,
      position: RelativeRect.fromLTRB(origin.dx, origin.dy - 64, origin.dx + 1, origin.dy),
      color: AppColors.surface,
      elevation: 8,
      shadowColor: Colors.black38,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      items: [
        PopupMenuItem<ReactionKind>(
          enabled: false,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final k in ReactionKind.values)
                Tooltip(
                  message: k.label,
                  child: InkResponse(
                    radius: 22,
                    onTap: () => Navigator.of(context).pop(k),
                    child: Container(
                      width: 38,
                      height: 38,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: k.color.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(k.icon, size: 22, color: k.color),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
    if (picked != null) _apply(picked);
  }

  void _openComments() {
    final provider = context.read<InteractionProvider>();
    if (provider.summaryOf(widget.targetId) == null) return;
    CommentSheet.show(
      context,
      targetId: widget.targetId,
      onCountChanged: (delta) => provider.adjustCommentCount(widget.targetId, delta),
    );
  }

  Future<void> _share() async {
    await Clipboard.setData(
        ClipboardData(text: widget.shareText ?? 'Việc làm #${widget.targetId}'));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(
        content: Text('Đã sao chép nội dung để chia sẻ'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InteractionProvider>();
    final s = provider.summaryOf(widget.targetId);

    if (provider.isFailed(widget.targetId)) {
      return Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: () => provider.retryLoad(widget.targetId),
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text('Không tải được lượt tương tác, thử lại'),
        ),
      );
    }

    final mine = s?.myReaction;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (s != null && (s.total > 0 || s.commentCount > 0)) _StatsRow(summary: s, onComments: _openComments),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Divider(height: 1, color: AppColors.border),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 6),
          child: Row(
            children: [
              _ActionButton(
                key: _likeKey,
                tooltip: 'Nhấn giữ để chọn cảm xúc khác',
                onTap: s == null ? null : () => _onTapLike(s),
                onLongPress: s == null ? null : _onLongPressLike,
                icon: mine?.icon ?? Icons.thumb_up_off_alt_rounded,
                label: mine?.label ?? 'Thích',
                color: mine?.color,
                bold: mine != null,
                popKey: mine,
              ),
              _ActionButton(
                onTap: s == null ? null : _openComments,
                icon: Icons.mode_comment_outlined,
                label: 'Bình luận',
              ),
              _ActionButton(
                onTap: _share,
                icon: Icons.ios_share_rounded,
                label: 'Chia sẻ',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.summary, required this.onComments});
  final ReactionSummary summary;
  final VoidCallback onComments;

  @override
  Widget build(BuildContext context) {
    const muted = AppColors.textMuted;
    const style = TextStyle(fontSize: 13, color: muted);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
      child: Row(
        children: [
          if (summary.total > 0) ...[
            _ReactionBadges(kinds: summary.top),
            const SizedBox(width: 6),
            Text('${summary.total}', style: style),
          ],
          const Spacer(),
          if (summary.commentCount > 0)
            InkWell(
              onTap: onComments,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text('${summary.commentCount} bình luận', style: style),
              ),
            ),
        ],
      ),
    );
  }
}

/// Các icon cảm xúc nhiều nhất: hình tròn màu, chồng nhẹ lên nhau như Facebook.
class _ReactionBadges extends StatelessWidget {
  const _ReactionBadges({required this.kinds});
  final List<ReactionKind> kinds;

  @override
  Widget build(BuildContext context) {
    const size = 20.0;
    const overlap = 6.0;
    final width = kinds.isEmpty ? 0.0 : size + (kinds.length - 1) * (size - overlap);
    return SizedBox(
      width: width,
      height: size,
      child: Stack(
        children: [
          for (var i = kinds.length - 1; i >= 0; i--)
            Positioned(
              left: i * (size - overlap),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: kinds[i].color,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surface, width: 1.5),
                ),
                child: Icon(kinds[i].icon, size: 11, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.onLongPress,
    this.color,
    this.bold = false,
    this.tooltip,
    this.popKey,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? color;
  final bool bold;
  final String? tooltip;
  final Object? popKey; // đổi giá trị này thì icon nảy nhẹ

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textSecondary;
    Widget button = InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        height: 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.elasticOut,
              transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
              child: Icon(icon, key: ValueKey(popKey ?? icon), size: 20, color: c),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
                  color: c,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    if (tooltip != null) button = Tooltip(message: tooltip!, child: button);
    return Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 2), child: button));
  }
}
