import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../data/coach_models.dart';
import '../data/coach_remote_datasource.dart';
import 'coach_provider.dart';

void openCoachSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => ChangeNotifierProvider(
      create: (c) =>
          CoachProvider(CoachRemoteDataSource(c.read<Dio>()))..load(),
      child: const CoachSheet(),
    ),
  );
}

class CoachSheet extends StatefulWidget {
  const CoachSheet({super.key});

  @override
  State<CoachSheet> createState() => _CoachSheetState();
}

class _CoachSheetState extends State<CoachSheet> {
  final _input = TextEditingController();
  String? _pickedRole;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<CoachProvider>();
    final height = MediaQuery.sizeOf(context).height * 0.85;
    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: p.loading && p.settings == null
            ? const Center(child: CircularProgressIndicator())
            : !(p.settings?.ready ?? false)
                ? _ConsentView(
                    settings: p.settings,
                    picked: _pickedRole,
                    onPick: (id) => setState(() => _pickedRole = id),
                    onEnable: () {
                      final role = _pickedRole ?? p.settings?.roles.first.id;
                      if (role != null) p.enable(targetRole: role);
                    },
                    error: p.errorMessage,
                    busy: p.loading,
                  )
                : _ChatView(
                    provider: p,
                    controller: _input,
                    onAsk: () {
                      final text = _input.text.trim();
                      if (text.isEmpty) return;
                      _input.clear();
                      p.ask(question: text);
                    },
                  ),
      ),
    );
  }
}

class _ConsentView extends StatelessWidget {
  final CoachSettings? settings;
  final String? picked;
  final ValueChanged<String> onPick;
  final VoidCallback onEnable;
  final String? error;
  final bool busy;

  const _ConsentView({
    required this.settings,
    required this.picked,
    required this.onPick,
    required this.onEnable,
    required this.error,
    required this.busy,
  });

  @override
  Widget build(BuildContext context) {
    final roles = settings?.roles ?? const <CoachRole>[];
    return ListView(
      children: [
        const Text('Trợ lý kỹ năng',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        const Text(
          'Trợ lý chỉ đọc skill, CV và job của bạn trên máy nhóm. Bạn tắt lại được bất cứ lúc nào. Không lưu nội dung câu hỏi.',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 16),
        const Text('Chọn vị trí muốn theo',
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        for (final role in roles)
          ListTile(
            title: Text(role.title),
            selected: (picked ?? settings?.targetRole) == role.id,
            trailing: (picked ?? settings?.targetRole) == role.id
                ? const Icon(Icons.check)
                : null,
            onTap: busy ? null : () => onPick(role.id),
          ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child:
                Text(error!, style: const TextStyle(color: AppTheme.errorRed)),
          ),
        FilledButton(
          onPressed: busy || roles.isEmpty ? null : onEnable,
          child: Text(busy ? 'Đang lưu...' : 'Đồng ý và bắt đầu'),
        ),
      ],
    );
  }
}

class _ChatView extends StatelessWidget {
  final CoachProvider provider;
  final TextEditingController controller;
  final VoidCallback onAsk;

  const _ChatView(
      {required this.provider, required this.controller, required this.onAsk});

  @override
  Widget build(BuildContext context) {
    final s = provider.settings!;
    final out = provider.lastAnswer;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Trợ lý kỹ năng · còn ${s.remaining}/${s.limit} câu hôm nay',
            style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final prompt in kCoachPrompts)
              ActionChip(
                label: Text(prompt.label),
                onPressed: provider.asking || s.remaining == 0
                    ? null
                    : () => provider.ask(intent: prompt.intent),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (provider.errorMessage != null)
                  Text(provider.errorMessage!,
                      style: const TextStyle(color: AppTheme.errorRed)),
                if (out != null) ...[
                  Text(out.answer),
                  if (out.sources.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text('Căn cứ: ${out.sources.join(' · ')}',
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.textSecondary)),
                    ),
                ],
              ],
            ),
          ),
        ),
        TextField(
          controller: controller,
          maxLength: 300,
          enabled: !provider.asking && s.remaining > 0,
          decoration: InputDecoration(
            hintText: s.remaining == 0
                ? 'Hết lượt hôm nay, hỏi lại ngày mai'
                : 'Hỏi ngắn về skill hoặc lộ trình',
            suffixIcon: IconButton(
              icon: const Icon(Icons.send),
              onPressed: provider.asking || s.remaining == 0 ? null : onAsk,
            ),
          ),
          onSubmitted: (_) => onAsk(),
        ),
      ],
    );
  }
}
