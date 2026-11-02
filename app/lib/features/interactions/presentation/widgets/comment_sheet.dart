import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/core/theme/app_colors.dart';
import '../../data/repositories/interaction_repository_impl.dart' show interactionErrorMessage;
import '../../domain/entities/comment_entity.dart';
import '../../domain/repositories/interaction_repository.dart';
import '../providers/interaction_provider.dart';

class CommentSheet extends StatefulWidget {
  const CommentSheet({
    super.key,
    required this.targetId,
    required this.onCountChanged,
  });

  final String targetId;
  final void Function(int delta) onCountChanged;

  static Future<void> show(
    BuildContext context, {
    required String targetId,
    required void Function(int delta) onCountChanged,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.85,
        child: CommentSheet(targetId: targetId, onCountChanged: onCountChanged),
      ),
    );
  }

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  late final InteractionRepository _repo = context.read<InteractionRepository>();
  final _items = <CommentItem>[];
  final _input = TextEditingController();
  final _scroll = ScrollController();
  int _page = 0;
  bool _hasMore = true;
  bool _loading = false;
  bool _sending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMore();
    _scroll.addListener(() {
      if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 200) _loadMore();
    });
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final p = await _repo.comments(InteractionProvider.targetJob, widget.targetId, page: _page + 1);
      if (!mounted) return;
      setState(() {
        _items.addAll(p.items);
        _page = p.page;
        _hasMore = p.hasMore;
      });
    } catch (e) {
      if (mounted) setState(() => _error = interactionErrorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      final c = await _repo.addComment(InteractionProvider.targetJob, widget.targetId, text);
      _input.clear();
      if (!mounted) return;
      setState(() => _items.insert(0, c));
      widget.onCountChanged(1);
      if (_scroll.hasClients) _scroll.jumpTo(0);
    } catch (e) {
      _toast('Chưa gửi được bình luận: ${interactionErrorMessage(e)}');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _delete(CommentItem c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xoá bình luận?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Huỷ')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Xoá')),
        ],
      ),
    );
    if (ok != true) return;
    final index = _items.indexOf(c);
    setState(() => _items.remove(c));
    widget.onCountChanged(-1);
    try {
      await _repo.deleteComment(c.id);
    } catch (e) {
      if (!mounted) return;
      setState(() => _items.insert(index, c));
      widget.onCountChanged(1);
      _toast('Chưa xoá được bình luận: ${interactionErrorMessage(e)}');
    }
  }

  void _toast(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(m), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text('Bình luận',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ),
        const Divider(height: 1, color: AppColors.border),
        Expanded(
          child: _items.isEmpty && !_loading
              ? Center(
                  child: _error != null
                      ? TextButton(onPressed: _loadMore, child: Text('$_error. Thử lại'))
                      : const Text('Chưa có bình luận nào. Hãy là người đầu tiên!',
                          style: TextStyle(color: AppColors.textMuted)),
                )
              : ListView.separated(
                  controller: _scroll,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: _items.length + (_hasMore ? 1 : 0),
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    if (i >= _items.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      );
                    }
                    return _CommentTile(comment: _items[i], onDelete: () => _delete(_items[i]));
                  },
                ),
        ),
        const Divider(height: 1, color: AppColors.border),
        Padding(
          padding: EdgeInsets.fromLTRB(12, 8, 8, 8 + MediaQuery.viewInsetsOf(context).bottom),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _input,
                  minLines: 1,
                  maxLines: 4,
                  maxLength: 1000,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: 'Viết bình luận…',
                    counterText: '',
                    isDense: true,
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Gửi',
                onPressed: _sending ? null : _send,
                color: AppColors.primary,
                icon: _sending
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.send_rounded),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment, required this.onDelete});
  final CommentItem comment;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final a = comment.author;
    final initials = a.fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .map((w) => w[0])
        .take(2)
        .join()
        .toUpperCase();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryContainer,
            // Ảnh đè lên chữ cái đầu; lỗi tải thì hiện chữ cái đầu, không in lỗi đỏ ra console
            foregroundImage: a.avatarUrl != null
                ? NetworkImage(a.avatarUrl!, webHtmlElementStrategy: WebHtmlElementStrategy.prefer)
                : null,
            onForegroundImageError: a.avatarUrl != null ? (_, __) {} : null,
            child: Text(initials,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onPrimaryContainer)),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a.fullName,
                          style: const TextStyle(
                              fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      const SizedBox(height: 2),
                      Text(comment.content,
                          style: const TextStyle(fontSize: 14.5, color: AppColors.textPrimary)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_timeAgo(comment.createdAt),
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      if (comment.isMine) ...[
                        const SizedBox(width: 12),
                        InkWell(
                          onTap: onDelete,
                          borderRadius: BorderRadius.circular(6),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            child: Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.textMuted),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _timeAgo(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'vừa xong';
    if (d.inHours < 1) return '${d.inMinutes} phút';
    if (d.inDays < 1) return '${d.inHours} giờ';
    if (d.inDays < 7) return '${d.inDays} ngày';
    return '${t.day}/${t.month}/${t.year}';
  }
}
