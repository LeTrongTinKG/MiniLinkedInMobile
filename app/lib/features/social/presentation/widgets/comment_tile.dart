import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../ui_kit/ui_kit.dart';
import '../../domain/entities/comment.dart';
import '../../domain/entities/reaction_kind.dart';
import '../providers/comments_provider.dart';
import '../social_strings.dart';
import '../utils/time_ago.dart';
import 'comment_reaction_count.dart';
import 'reaction_button.dart';
import 'reaction_style.dart';

/// 1 bình luận (gốc hoặc phản hồi): avatar + bong bóng xám + dòng "Thích · Trả lời · thời gian".
/// Có thể sửa tại chỗ (chỉ của mình) và xóa (của mình, hoặc chủ bài).
class CommentTile extends StatefulWidget {
  const CommentTile({
    super.key,
    required this.comment,
    required this.canDelete,
    required this.onReply,
    this.isReply = false,
  });

  final Comment comment;
  final bool canDelete; // true nếu được xóa (bình luận của mình hoặc mình là chủ bài)
  final bool isReply; // cấp 2: avatar nhỏ hơn
  final void Function(Comment c) onReply;

  @override
  State<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> {
  final _editController = TextEditingController();
  bool _editing = false; // đang sửa tại chỗ?
  bool _saving = false;

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  void _startEdit() {
    _editController.text = widget.comment.content;
    setState(() => _editing = true);
  }

  Future<void> _saveEdit() async {
    setState(() => _saving = true);
    final error =
        await context.read<CommentsProvider>().updateComment(widget.comment.id, _editController.text);
    if (!mounted) return;
    setState(() => _saving = false);
    if (error != null) {
      showAppError(context, error);
    } else {
      setState(() => _editing = false);
    }
  }

  Future<void> _delete() async {
    final provider = context.read<CommentsProvider>();
    final ok = await showAppConfirmDialog(context,
        title: SocialStrings.deleteCommentTitle,
        message: SocialStrings.deleteCommentMessage,
        confirmLabel: SocialStrings.menuDelete,
        destructive: true);
    if (!ok) return;
    final error = await provider.deleteComment(widget.comment.id);
    if (error != null && mounted) showAppError(context, error);
  }

  Future<void> _react(ReactionKind? kind) async {
    final error = await context.read<CommentsProvider>().react(widget.comment.id, kind);
    if (error != null && mounted) showAppError(context, error);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.comment;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppAvatar(imageUrl: c.author.avatarUrl, name: c.author.fullName, size: widget.isReply ? 28 : 36),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _editing ? _editBox() : _bubbleWithMenu(c),
              if (!_editing) _metaRow(c),
            ],
          ),
        ),
      ],
    );
  }

  // Bong bóng xám + menu "..." bên phải
  Widget _bubbleWithMenu(Comment c) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: UiTokens.muted, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.author.fullName,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Text(c.content, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ),
        if (c.isMine || widget.canDelete)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz, size: 18),
            padding: EdgeInsets.zero,
            onSelected: (v) => v == 'edit' ? _startEdit() : _delete(),
            itemBuilder: (_) => [
              if (c.isMine)
                const PopupMenuItem(value: 'edit', child: Text(SocialStrings.menuEdit)),
              const PopupMenuItem(value: 'delete', child: Text(SocialStrings.menuDelete)),
            ],
          ),
      ],
    );
  }

  // Ô sửa tại chỗ
  Widget _editBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AppTextArea(controller: _editController, minHeight: 40, maxHeight: 120, enabled: !_saving),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          AppButton(
              label: SocialStrings.cancel,
              variant: AppButtonVariant.ghost,
              size: AppButtonSize.small,
              onPressed: _saving ? null : () => setState(() => _editing = false)),
          const SizedBox(width: 8),
          AppButton(
              label: SocialStrings.save,
              size: AppButtonSize.small,
              loading: _saving,
              onPressed: _saving ? null : _saveEdit),
        ]),
      ],
    );
  }

  // Dòng nhỏ: thời gian · Thích · Trả lời · (đã chỉnh sửa) · cảm xúc
  Widget _metaRow(Comment c) {
    const small = TextStyle(fontSize: 12, color: UiTokens.mutedForeground);
    final mine = c.reactionSummary.myReaction;
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 2),
      child: Wrap(
        spacing: 14,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(timeAgo(c.createdAt), style: small),
          ReactionButton(
            current: mine,
            onChanged: _react,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(mine?.label ?? SocialStrings.like,
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600, color: reactionColor(mine))),
            ),
          ),
          GestureDetector(
            onTap: () => widget.onReply(c),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Text(SocialStrings.reply,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: UiTokens.mutedForeground)),
            ),
          ),
          if (c.editedAt != null) const Text(SocialStrings.commentEdited, style: small),
          if (c.reactionSummary.total > 0) CommentReactionCount(summary: c.reactionSummary),
        ],
      ),
    );
  }
}
