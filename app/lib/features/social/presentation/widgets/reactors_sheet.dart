import 'package:flutter/material.dart';
import '../../../../ui_kit/ui_kit.dart';
import '../../domain/entities/reactor.dart';
import '../../domain/entities/reaction_kind.dart';
import '../social_strings.dart';
import '../providers/social_error.dart';
import 'max_width_box.dart';
import 'reaction_icon.dart';

/// Sheet "ai đã thả cảm xúc": hàng lọc (Tất cả + từng loại có người) và danh sách người.
class ReactorsSheet extends StatefulWidget {
  const ReactorsSheet({super.key, required this.loader});

  /// Hàm lấy danh sách (feed.loadReactors). Truyền vào để widget không phụ thuộc provider.
  final Future<List<Reactor>> Function() loader;

  @override
  State<ReactorsSheet> createState() => _ReactorsSheetState();
}

class _ReactorsSheetState extends State<ReactorsSheet> {
  List<Reactor>? _all; // null = đang tải
  String? _error;
  ReactionKind? _filter; // null = tab "Tất cả"

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _all = null;
      _error = null;
    });
    try {
      final list = await widget.loader();
      if (mounted) setState(() => _all = list);
    } catch (e) {
      if (mounted) setState(() => _error = socialErrorMessage(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.6,
      child: MaxWidthBox(child: _body()),
    );
  }

  Widget _body() {
    if (_error != null) {
      return AppEmptyState(
          title: _error!, icon: Icons.error_outline, actionLabel: SocialStrings.retry, onAction: _load);
    }
    final all = _all;
    if (all == null) return const Center(child: CircularProgressIndicator());
    if (all.isEmpty) return const AppEmptyState(title: SocialStrings.reactorsEmpty);

    final shown = _filter == null ? all : all.where((r) => r.kind == _filter).toList();
    return Column(
      children: [
        // Hàng "tab": Tất cả + mỗi loại có ít nhất 1 người
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(children: [
            _chip(const Text(SocialStrings.reactorsAll), all.length, _filter == null,
                () => setState(() => _filter = null)),
            for (final k in ReactionKind.values)
              if (all.any((r) => r.kind == k))
                _chip(ReactionIcon(kind: k, size: 18), all.where((r) => r.kind == k).length,
                    _filter == k, () => setState(() => _filter = k)),
          ]),
        ),
        const AppDivider(),
        Expanded(
          child: ListView.builder(
            itemCount: shown.length,
            itemBuilder: (_, i) => ListTile(
              leading: AppAvatar(
                  imageUrl: shown[i].user.avatarUrl, name: shown[i].user.fullName, size: 40),
              title: Text(shown[i].user.fullName),
              trailing: ReactionIcon(kind: shown[i].kind, size: 26),
            ),
          ),
        ),
      ],
    );
  }

  // `label` là Widget (chữ "Tất cả" hoặc icon cảm xúc), sau đó là số lượng
  Widget _chip(Widget label, int count, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Row(mainAxisSize: MainAxisSize.min, children: [
          label,
          const SizedBox(width: 6),
          Text('$count'),
        ]),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}
