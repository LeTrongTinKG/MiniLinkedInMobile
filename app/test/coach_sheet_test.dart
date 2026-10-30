import 'package:app/features/coach/data/coach_models.dart';
import 'package:app/features/coach/data/coach_remote_datasource.dart';
import 'package:app/features/coach/presentation/coach_provider.dart';
import 'package:app/features/coach/presentation/coach_sheet.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

const _roles = [
  CoachRole(id: 'flutter-mobile', title: 'Lập trình viên Mobile (Flutter)'),
  CoachRole(id: 'backend-node', title: 'Lập trình viên Backend (Node.js)'),
];

class FakeCoachSource extends CoachRemoteDataSource {
  FakeCoachSource() : super(Dio());

  bool consent = false;
  String? role;
  int remaining = 10;

  @override
  Future<CoachSettings> getSettings() async => CoachSettings(
        consent: consent,
        targetRole: role,
        roles: _roles,
        remaining: remaining,
        limit: 10,
      );

  @override
  Future<CoachSettings> saveSettings(
      {bool? consent, String? targetRole}) async {
    this.consent = consent ?? this.consent;
    role = targetRole ?? role;
    return getSettings();
  }

  @override
  Future<CoachAnswer> ask(
      {String? question, String? intent, String? jobId}) async {
    remaining = remaining > 0 ? remaining - 1 : 0;
    return CoachAnswer(
      answer: 'Bạn đang ở bước 3.',
      sources: const ['Lộ trình Mobile (Flutter)'],
      mode: 'rules',
      refused: false,
      remaining: remaining,
    );
  }
}

Widget _wrap(CoachProvider provider) => MaterialApp(
      home: ChangeNotifierProvider.value(
        value: provider,
        child: const Scaffold(body: CoachSheet()),
      ),
    );

void main() {
  testWidgets('lần đầu: hiện màn đồng ý và danh sách vị trí', (tester) async {
    final source = FakeCoachSource();
    await tester.pumpWidget(_wrap(CoachProvider(source)..load()));
    await tester.pumpAndSettle();
    expect(find.text('Đồng ý và bắt đầu'), findsOneWidget);
    expect(find.text('Lập trình viên Mobile (Flutter)'), findsOneWidget);
  });

  testWidgets('hết lượt: ô gõ bị khóa, hiện hết lượt hôm nay', (tester) async {
    final source = FakeCoachSource()
      ..consent = true
      ..role = 'flutter-mobile'
      ..remaining = 0;
    await tester.pumpWidget(_wrap(CoachProvider(source)..load()));
    await tester.pumpAndSettle();
    expect(find.textContaining('còn 0/10 câu hôm nay'), findsOneWidget);
    expect(find.text('Hết lượt hôm nay, hỏi lại ngày mai'), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
  });

  test('đọc JSON cài đặt từ server', () {
    final s = CoachSettings.fromJson({
      'consent': true,
      'targetRole': 'flutter-mobile',
      'roles': [
        {'id': 'flutter-mobile', 'title': 'Mobile (Flutter)'}
      ],
      'remaining': 7,
      'limit': 10,
    });
    expect(s.ready, isTrue);
    expect(s.remaining, 7);
  });
}
