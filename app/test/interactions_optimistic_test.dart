import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:app/features/interactions/data/datasources/interaction_datasource.dart';
import 'package:app/features/interactions/data/repositories/interaction_repository_impl.dart';
import 'package:app/features/interactions/domain/entities/comment_entity.dart';
import 'package:app/features/interactions/domain/entities/reaction_kind.dart';
import 'package:app/features/interactions/domain/entities/reaction_summary.dart';
import 'package:app/features/interactions/domain/repositories/interaction_repository.dart';
import 'package:app/features/interactions/presentation/providers/interaction_provider.dart';
import 'package:app/features/interactions/presentation/widgets/reaction_bar.dart';

/// Summary tải được nhưng mọi thao tác ghi đều lỗi mạng (không cần server).
class _OfflineDataSource implements InteractionDataSource {
  Never _fail() => throw DioException(
        requestOptions: RequestOptions(path: '/x'),
        type: DioExceptionType.connectionError,
      );

  @override
  Future<List<ReactionSummary>> summaries(String t, List<String> ids) async =>
      [for (final id in ids) ReactionSummary.empty(t, id)];
  @override
  Future<ReactionSummary> react(String t, String id, ReactionKind k) async {
    await Future.delayed(const Duration(milliseconds: 300)); // mạng chậm rồi mới lỗi
    _fail();
  }
  @override
  Future<ReactionSummary> unreact(String t, String id) async => _fail();
  @override
  Future<CommentPage> comments(String t, String id, {int page = 1, int limit = 20}) async => _fail();
  @override
  Future<CommentItem> addComment(String t, String id, String c) async => _fail();
  @override
  Future<void> deleteComment(String id) async => _fail();
}

void main() {
  testWidgets('API thất bại: tym hiện trước, lỗi thì trả về chưa tym + thông báo', (t) async {
    final InteractionRepository repo = InteractionRepositoryImpl(_OfflineDataSource());
    await t.pumpWidget(MultiProvider(
      providers: [
        Provider<InteractionRepository>.value(value: repo),
        ChangeNotifierProvider(create: (_) => InteractionProvider(repo)),
      ],
      child: const MaterialApp(
        home: Scaffold(body: Align(alignment: Alignment.topCenter, child: ReactionBar(targetId: 'j1'))),
      ),
    ));
    await t.pump(const Duration(milliseconds: 100)); // timer gom request
    await t.pump(const Duration(milliseconds: 100));

    await t.tap(find.text('Thích'));
    await t.pump(const Duration(milliseconds: 50)); // tym ngay, server chưa trả lời
    expect(find.text('1'), findsOneWidget);

    await t.pump(const Duration(milliseconds: 500)); // request lỗi -> hoàn lại
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('1'), findsNothing); // đã về chưa tym
    expect(find.textContaining('Chưa thể lưu cảm xúc'), findsOneWidget);
  });
}
