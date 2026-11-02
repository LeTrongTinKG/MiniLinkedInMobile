import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/reaction_kind.dart';
import '../../domain/entities/reactor.dart';
import '../providers/social_feed_provider.dart';
import '../social_strings.dart';

/// Rê chuột vào một vùng thì hiện khung nhỏ liệt kê TÊN những người đã thả cảm xúc, giống Facebook.
/// - `kind == null`: liệt kê tất cả mọi người đã react (dùng cho con số tổng).
/// - `kind != null`: chỉ người thả đúng cảm xúc đó, kèm dòng tiêu đề (dùng cho từng icon).
/// Tên tải từ server ở lần rê đầu rồi giữ lại, các lần rê sau hiện ngay.
/// Chỉ có tác dụng với chuột (web/máy tính); trên điện thoại vẫn bấm để mở danh sách đầy đủ.
class ReactorsHover extends StatefulWidget {
  const ReactorsHover({
    super.key,
    required this.postId,
    required this.count,
    required this.child,
    this.kind,
  });

  final String postId;
  final int count; // số người thuộc vùng này, để ghi "và N người khác"
  final ReactionKind? kind;
  final Widget child;

  @override
  State<ReactorsHover> createState() => _ReactorsHoverState();
}

class _ReactorsHoverState extends State<ReactorsHover> {
  static const _hoverDelay = Duration(milliseconds: 300); // rê lướt qua thì không hiện

  // Danh sách tên (giống useState). null = đang tải.
  final _names = ValueNotifier<List<Reactor>?>(null);
  bool _loaded = false;
  bool _failed = false;
  OverlayEntry? _entry; // lớp nổi chứa khung tên
  Timer? _timer;

  // Số người hoặc loại cảm xúc đổi (có người vừa thả/gỡ) thì bỏ danh sách cũ, lần rê sau tải lại
  @override
  void didUpdateWidget(ReactorsHover old) {
    super.didUpdateWidget(old);
    if (old.count != widget.count || old.kind != widget.kind) {
      _loaded = false;
      _failed = false;
      _names.value = null;
    }
  }

  void _onEnter() {
    _timer?.cancel();
    _timer = Timer(_hoverDelay, _show);
  }

  void _onExit() {
    _timer?.cancel();
    _hide();
  }

  void _show() {
    if (_entry != null || !mounted) return;
    // 1. Tính vị trí vùng đang rê chuột trên màn hình
    final box = context.findRenderObject() as RenderBox;
    final origin = box.localToGlobal(Offset.zero);
    final screen = MediaQuery.sizeOf(context);
    final left = origin.dx.clamp(8.0, max(8.0, screen.width - _ReactorsCard.width - 8)).toDouble();
    final below = origin.dy < screen.height / 2; // nửa trên màn hình thì hiện phía dưới, ngược lại phía trên

    // 2. Lớp nổi: bỏ qua chuột để không che nút bên dưới
    _entry = OverlayEntry(
      builder: (_) => Positioned(
        left: left,
        top: below ? origin.dy + box.size.height + 6 : null,
        bottom: below ? null : screen.height - origin.dy + 6,
        child: IgnorePointer(
          child: ValueListenableBuilder<List<Reactor>?>(
            valueListenable: _names,
            builder: (_, names, __) => _ReactorsCard(
              kind: widget.kind,
              names: names,
              count: widget.count,
              failed: _failed,
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_entry!);
    _loadNames();
  }

  void _hide() {
    _entry?.remove();
    _entry = null;
  }

  Future<void> _loadNames() async {
    if (_loaded) return;
    final provider = context.read<SocialFeedProvider>();
    try {
      final list = await provider.loadReactors(widget.postId, kind: widget.kind);
      if (!mounted) return;
      _loaded = true;
      _failed = false;
      _names.value = list;
    } catch (_) {
      if (!mounted) return;
      _failed = true;
      _names.value = const [];
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // dọn như return cleanup trong useEffect
    _hide();
    _names.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onEnter(),
      onExit: (_) => _onExit(),
      child: widget.child,
    );
  }
}

/// Khung đen bo tròn: tiêu đề (nếu có) + tối đa 10 tên + "và N người khác…".
class _ReactorsCard extends StatelessWidget {
  const _ReactorsCard({
    required this.kind,
    required this.names,
    required this.count,
    required this.failed,
  });

  static const width = 220.0;
  static const _maxNames = 10;
  static const _text = TextStyle(color: Colors.white, fontSize: 12, height: 1.35);

  final ReactionKind? kind;
  final List<Reactor>? names; // null = đang tải
  final int count;
  final bool failed;

  @override
  Widget build(BuildContext context) {
    final list = names;
    final shown = list?.take(_maxNames).toList() ?? const <Reactor>[];
    final rest = count - shown.length;

    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: width),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xE61C1E21),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (kind != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(kind!.label, style: _text.copyWith(fontWeight: FontWeight.w700)),
              ),
            if (list == null)
              const Text(SocialStrings.reactorsLoading, style: _text)
            else if (failed)
              const Text(SocialStrings.reactorsLoadFailed, style: _text)
            else if (shown.isEmpty)
              const Text(SocialStrings.reactorsEmpty, style: _text)
            else
              for (final r in shown)
                Text(r.user.fullName, maxLines: 1, overflow: TextOverflow.ellipsis, style: _text),
            if (list != null && !failed && rest > 0)
              Text(SocialStrings.reactorsMore(rest), style: _text),
          ],
        ),
      ),
    );
  }
}
