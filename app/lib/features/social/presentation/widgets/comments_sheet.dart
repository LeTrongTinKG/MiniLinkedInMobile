import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../ui_kit/ui_kit.dart';
import '../../domain/entities/comment.dart';
import '../providers/comments_provider.dart';
import '../social_strings.dart';
import 'comment_input.dart';
import 'comment_thread.dart';
import 'max_width_box.dart';

/// Nội dung bottom sheet bình luận. Cần CommentsProvider ở phía trên (do post_actions tạo).
class CommentsSheet extends StatefulWidget {
  const CommentsSheet({super.key, required this.canModerate});

  final bool canModerate; // true nếu người xem là chủ bài (được xóa mọi bình luận)

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final _controller = TextEditingController(); // ô nhập
  final _scroll = ScrollController();
  Comment? _replyTo; // đang trả lời ai (null = bình luận gốc)
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  // Bấm "Trả lời": gắn thẻ @tên vào ô nhập
  void _startReply(Comment c) {
    final tag = '@${c.author.fullName} ';
    setState(() => _replyTo = c);
    _controller.value = TextEditingValue(text: tag, selection: TextSelection.collapsed(offset: tag.length));
  }

  void _cancelReply() {
    final tag = '@${_replyTo?.author.fullName} ';
    if (_controller.text == tag) _controller.clear();
    setState(() => _replyTo = null);
  }

  Future<void> _send() async {
    final provider = context.read<CommentsProvider>();
    final target = _replyTo;
    setState(() => _sending = true);
    final error = await provider.addComment(_controller.text, parentId: target?.id);
    if (!mounted) return;
    setState(() => _sending = false);

    if (error != null) {
      showAppError(context, error);
      return;
    }
    _controller.clear();
    setState(() => _replyTo = null);
    if (target != null) {
      // Trả lời xong thì mở luôn danh sách phản hồi của bình luận gốc để người dùng thấy
      provider.loadReplies(target.parentId ?? target.id);
    } else {
      // Bình luận gốc mới nằm cuối danh sách -> cuộn xuống
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.85,
      child: MaxWidthBox(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(SocialStrings.commentsTitle,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            ),
            const AppDivider(),
            Expanded(child: _list(context)),
            CommentInput(
              controller: _controller,
              sending: _sending,
              onSend: _send,
              replyingTo: _replyTo?.author.fullName,
              onCancelReply: _cancelReply,
            ),
          ],
        ),
      ),
    );
  }

  Widget _list(BuildContext context) {
    final p = context.watch<CommentsProvider>();

    if (p.status == CommentsStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (p.status == CommentsStatus.error) {
      return AppEmptyState(
        title: SocialStrings.commentsError,
        message: p.error,
        icon: Icons.error_outline,
        actionLabel: SocialStrings.retry,
        onAction: p.loadInitial,
      );
    }
    if (p.isEmpty) {
      return const AppEmptyState(
        title: SocialStrings.commentsEmpty,
        message: SocialStrings.commentsEmptyMessage,
        icon: Icons.mode_comment_outlined,
      );
    }

    // ListView.builder ~ comments.map(...); phần tử cuối là nút "Xem thêm"
    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.all(12),
      itemCount: p.comments.length + 1,
      itemBuilder: (_, i) {
        if (i == p.comments.length) return _footer(context, p);
        return CommentThread(
            comment: p.comments[i], canModerate: widget.canModerate, onReply: _startReply);
      },
    );
  }

  Widget _footer(BuildContext context, CommentsProvider p) {
    if (p.loadingMore) {
      return const Padding(
          padding: EdgeInsets.all(8), child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
    }
    if (!p.hasMore) return const SizedBox.shrink();
    return Center(
      child: AppButton(
        label: SocialStrings.loadMoreComments,
        variant: AppButtonVariant.ghost,
        onPressed: () async {
          await p.loadMore();
          if (p.error != null && context.mounted) showAppError(context, p.error!);
        },
      ),
    );
  }
}
