import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/coach_remote_datasource.dart';
import 'coach_provider.dart';
import 'widgets/coach_chat_view.dart';
import 'widgets/coach_consent_view.dart';

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
                ? CoachConsentView(
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
                : CoachChatView(
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
