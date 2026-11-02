// Test hành vi người dùng với API thật. Cần server đã có bảng reactions/comments ở API_URL:
//   flutter test test/interactions_e2e_test.dart --dart-define=API_URL=http://localhost:5055/api/v1
import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:app/features/interactions/data/datasources/interaction_datasource.dart';
import 'package:app/features/interactions/data/datasources/interaction_remote_datasource.dart';
import 'package:app/features/interactions/data/repositories/interaction_repository_impl.dart';
import 'package:app/features/interactions/domain/entities/comment_entity.dart';
import 'package:app/features/interactions/domain/entities/reaction_kind.dart';
import 'package:app/features/interactions/domain/entities/reaction_summary.dart';
import 'package:app/features/interactions/domain/repositories/interaction_repository.dart';
import 'package:app/features/interactions/presentation/providers/interaction_provider.dart';
import 'package:app/features/interactions/presentation/widgets/reaction_bar.dart';

// KHÔNG mặc định trỏ Render: test này tự đăng ký user thử.
const _base = String.fromEnvironment('API_URL', defaultValue: 'http://localhost:5055/api/v1');

void main() {
  late Dio dio;
  late String jobId;
  final email = 'e2e_${DateTime.now().millisecondsSinceEpoch}@test.local';

  setUpAll(() async {
    HttpOverrides.global = null; // cho phép gọi mạng thật trong test
    dio = Dio(BaseOptions(baseUrl: _base));
    final reg = await dio.post('/auth/register', data: {
      'email': email,
      'password': 'Test1234!',
      'fullName': 'E2E Tester',
      'role': 'student',
    });
    dio.options.headers['Authorization'] = 'Bearer ${reg.data['data']['accessToken']}';
    final jobs = await dio.get('/jobs');
    jobId = (jobs.data['data'] as List).first['id'] as String;
  });

  Future<void> settle(WidgetTester t) async {
    await t.pump(const Duration(milliseconds: 100)); // bắn Timer gom request (fake clock)
    await t.runAsync(() => Future.delayed(const Duration(milliseconds: 900))); // chờ mạng thật
    await t.pump(const Duration(milliseconds: 100));
    await t.pump(const Duration(milliseconds: 100));
  }

  Future<Map<String, dynamic>> serverSummary() async {
    final r = await dio.get('/reactions/summary',
        queryParameters: {'targetType': 'job', 'ids': jobId});
    return (r.data['data'] as List).first as Map<String, dynamic>;
  }

  Future<void> pumpBar(WidgetTester t, {InteractionDataSource? ds}) async {
    HttpOverrides.global = null; // binding đặt lại mỗi test
    t.view.physicalSize = const Size(420, 900);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final repo = InteractionRepositoryImpl(
        ds ?? _RootZoneDataSource(InteractionRemoteDataSource(dio)));
    await t.pumpWidget(MultiProvider(
      providers: [
        Provider<InteractionRepository>.value(value: repo),
        ChangeNotifierProvider(create: (_) => InteractionProvider(repo)),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topCenter,
            child: ReactionBar(targetId: jobId, shareText: 'x'),
          ),
        ),
      ),
    ));
    await settle(t);
  }

  testWidgets('1. mở bài: thanh tương tác tải xong, có 3 nút', (t) async {
    await pumpBar(t);
    expect(find.text('Thích'), findsOneWidget);
    expect(find.text('Bình luận'), findsOneWidget);
    expect(find.text('Chia sẻ'), findsOneWidget);
  });

  testWidgets('2. bấm Thích -> UI đổi NGAY (chưa chờ server), rồi server ghi nhận; bấm lại -> bỏ',
      (t) async {
    await pumpBar(t);
    final base = (await t.runAsync(serverSummary))!['total'] as int;
    await t.tap(find.text('Thích'));
    await t.pump(); // chưa chờ mạng
    expect(find.text('${base + 1}'), findsOneWidget);
    await settle(t);
    var s = await t.runAsync(serverSummary);
    expect(s!['total'], base + 1);
    expect(s['myReaction'], 'LIKE');

    await t.tap(find.text('Thích'));
    await settle(t);
    s = await t.runAsync(serverSummary);
    expect(s!['total'], base);
    expect(s['myReaction'], isNull);
  });

  testWidgets('3. bấm liên tiếp 3 lần: server giữ trạng thái cuối (đang thích)', (t) async {
    await pumpBar(t);
    final base = (await t.runAsync(serverSummary))!['total'] as int;
    for (var i = 0; i < 3; i++) {
      await t.tap(find.text('Thích'));
      await t.pump();
    }
    await settle(t);
    await settle(t);
    final s = await t.runAsync(serverSummary);
    expect(s!['myReaction'], 'LIKE');
    expect(s['total'], base + 1);

    await t.tap(find.text('Thích')); // dọn
    await settle(t);
    expect((await t.runAsync(serverSummary))!['total'], base);
  });

  testWidgets('4. nhấn giữ Thích -> Yêu thích, rồi Hài hước: tổng không tăng thêm', (t) async {
    await pumpBar(t);
    final base = (await t.runAsync(serverSummary))!['total'] as int;
    await t.longPress(find.text('Thích'));
    await t.pumpAndSettle();
    await t.tap(find.byTooltip('Yêu thích'));
    await settle(t);
    await t.pumpAndSettle();
    expect(find.text('Yêu thích'), findsOneWidget);
    var s = await t.runAsync(serverSummary);
    expect(s!['myReaction'], 'LOVE');
    expect(s['total'], base + 1);

    await t.longPress(find.text('Yêu thích'));
    await t.pumpAndSettle();
    await t.tap(find.byTooltip('Hài hước'));
    await settle(t);
    await t.pumpAndSettle();
    s = await t.runAsync(serverSummary);
    expect(s!['myReaction'], 'FUNNY');
    expect(s['total'], base + 1);

    await t.tap(find.text('Hài hước')); // dọn
    await settle(t);
    expect((await t.runAsync(serverSummary))!['total'], base);
  });

  testWidgets('5. bình luận: viết -> hiện đầu danh sách, số tăng; xoá -> giảm', (t) async {
    await pumpBar(t);
    final before = (await t.runAsync(serverSummary))!['commentCount'] as int;
    final msg = 'Xin chào ${DateTime.now().microsecondsSinceEpoch}';

    await t.tap(find.text('Bình luận'));
    await t.pump(const Duration(milliseconds: 400));
    await settle(t);
    expect(find.text('Viết bình luận…'), findsOneWidget);

    await t.enterText(find.byType(TextField), msg);
    await t.tap(find.byIcon(Icons.send_rounded));
    await settle(t);
    expect(find.text(msg), findsOneWidget);
    expect((await t.runAsync(serverSummary))!['commentCount'], before + 1);
    expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget); // chỉ comment của mình

    await t.tap(find.byIcon(Icons.delete_outline_rounded));
    await t.pump(const Duration(milliseconds: 400));
    await t.tap(find.text('Xoá'));
    await settle(t);
    expect(find.text(msg), findsNothing);
    expect((await t.runAsync(serverSummary))!['commentCount'], before);
  });
}

/// Chạy request ở zone gốc để Timer/socket của dio là thật, không dính fake clock của widget test.
class _RootZoneDataSource implements InteractionDataSource {
  _RootZoneDataSource(this._d);
  final InteractionDataSource _d;

  @override
  Future<List<ReactionSummary>> summaries(String t, List<String> ids) =>
      Zone.root.run(() => _d.summaries(t, ids));
  @override
  Future<ReactionSummary> react(String t, String id, ReactionKind k) =>
      Zone.root.run(() => _d.react(t, id, k));
  @override
  Future<ReactionSummary> unreact(String t, String id) =>
      Zone.root.run(() => _d.unreact(t, id));
  @override
  Future<CommentPage> comments(String t, String id, {int page = 1, int limit = 20}) =>
      Zone.root.run(() => _d.comments(t, id, page: page, limit: limit));
  @override
  Future<CommentItem> addComment(String t, String id, String c) =>
      Zone.root.run(() => _d.addComment(t, id, c));
  @override
  Future<void> deleteComment(String id) => Zone.root.run(() => _d.deleteComment(id));
}
