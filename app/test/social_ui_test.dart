import 'dart:ui' show PointerDeviceKind;
import 'package:app/features/social/presentation/widgets/like_label.dart';
import 'package:app/features/social/presentation/widgets/reaction_icon.dart';
import 'package:app/core/services/google_auth_service.dart';
import 'package:app/features/auth/domain/repositories/auth_repository.dart';
import 'package:app/features/auth/domain/usecases/auth_usecases.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:app/features/social/domain/entities/comment.dart';
import 'package:app/features/social/domain/entities/cursor_page.dart';
import 'package:app/features/social/domain/entities/post.dart';
import 'package:app/features/social/domain/entities/post_author.dart';
import 'package:app/features/social/domain/entities/post_media.dart';
import 'package:app/features/social/domain/entities/reaction_kind.dart';
import 'package:app/features/social/domain/entities/reaction_summary.dart';
import 'package:app/features/social/domain/repositories/social_repository.dart';
import 'package:app/features/social/presentation/providers/social_providers.dart';
import 'package:app/features/social/presentation/screens/create_post_screen.dart';
import 'package:app/features/social/presentation/screens/social_feed_screen.dart';
import 'package:app/features/social/presentation/widgets/max_width_box.dart';
import 'package:app/features/social/presentation/widgets/post_card.dart';
import 'package:app/features/social/presentation/widgets/post_images_grid.dart';
import 'package:app/ui_kit/app_shad_theme.dart';
import 'package:app/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

// ---------- Đồ giả ----------
const _me = PostAuthor(id: 'u1', fullName: 'Tôi');
const _other = PostAuthor(id: 'u2', fullName: 'Bình');

class _FakeAuthRepo implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeGoogle implements IGoogleAuthService {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// Kho dữ liệu giả: trả bài/bình luận có sẵn, ghi lại lời gọi vào `log`.
class _FakeRepo implements SocialRepository {
  _FakeRepo(this.posts);
  final List<Post> posts;
  final List<String> log = [];

  @override
  Future<CursorPage<Post>> getFeed({String? cursor, int limit = 10}) async =>
      CursorPage(items: posts);

  @override
  Future<ReactionSummary> setReaction(String postId, ReactionKind kind) async {
    log.add('react:$postId:${kind.api}');
    return ReactionSummary(total: 1, counts: {kind: 1}, top: [kind], myReaction: kind);
  }

  @override
  Future<ReactionSummary> removeReaction(String postId) async {
    log.add('unreact:$postId');
    return ReactionSummary.empty;
  }

  @override
  Future<CursorPage<Comment>> getComments(String postId, {String? cursor, int limit = 10}) async =>
      CursorPage(items: [
        Comment(id: 'c1', author: _other, content: 'Bình luận gốc', createdAt: DateTime(2026), replyCount: 2),
      ]);

  @override
  Future<CursorPage<Comment>> getReplies(String commentId, {String? cursor, int limit = 10}) async =>
      CursorPage(items: [
        Comment(
            id: 'r1', parentId: commentId, author: _me, content: 'Phản hồi một', createdAt: DateTime(2026), isMine: true),
        Comment(id: 'r2', parentId: commentId, author: _other, content: 'Phản hồi hai', createdAt: DateTime(2026)),
      ]);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

Post _post(String id, {bool mine = false, String content = 'Nội dung', List<PostMedia> media = const [], Post? shared}) =>
    Post(
      id: id,
      author: mine ? _me : _other,
      content: '$content $id',
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      isMine: mine,
      media: media,
      sharedPost: shared,
    );

List<PostMedia> _media(int n) => [for (var i = 0; i < n; i++) PostMedia(url: 'http://x/$i.jpg', width: 400, height: 300)];

// Dựng đúng cấu trúc gốc app: ShadApp.custom > MaterialApp > Scaffold, kèm Auth + Social provider.
Widget _app(_FakeRepo repo, Widget child) {
  return ShadApp.custom(
    theme: buildAppShadTheme(),
    appBuilder: (context) => MaterialApp(
      builder: (context, c) => ShadAppBuilder(child: c!),
      home: ChangeNotifierProvider(
        create: (_) => AuthProvider(
          loginUseCase: LoginUseCase(_FakeAuthRepo()),
          registerUseCase: RegisterUseCase(_FakeAuthRepo()),
          getMeUseCase: GetMeUseCase(_FakeAuthRepo()),
          googleLoginUseCase: GoogleLoginUseCase(_FakeAuthRepo()),
          logoutUseCase: LogoutUseCase(_FakeAuthRepo()),
          googleAuthService: _FakeGoogle(),
        ),
        child: SocialProviders(repository: repo, child: Scaffold(body: child)),
      ),
    ),
  );
}

void _size(WidgetTester t, double w, [double h = 900]) {
  t.view.physicalSize = Size(w, h);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
}

Future<void> _openFeed(WidgetTester t, _FakeRepo repo, {double width = 400}) async {
  _size(t, width);
  await t.pumpWidget(_app(repo, const SocialFeedScreen()));
  await t.pumpAndSettle();
}

// Tìm icon cảm xúc theo loại (thay cho tìm chữ emoji như trước)
Finder _icon(ReactionKind kind) =>
    find.byWidgetPredicate((w) => w is ReactionIcon && w.kind == kind);

void main() {
  testWidgets('feed hiển thị bài', (t) async {
    await _openFeed(t, _FakeRepo([_post('a', mine: true), _post('b')]));
    expect(find.text('Nội dung a'), findsOneWidget);
    expect(find.text('Nội dung b'), findsOneWidget);
    expect(find.text('Bạn đang nghĩ gì?'), findsOneWidget); // ô soạn bài
    expect(find.text('5 phút trước'), findsNWidgets(2));
    expect(t.takeException(), isNull);
  });

  testWidgets('bấm Thích gọi react và đổi trạng thái', (t) async {
    final repo = _FakeRepo([_post('a')]);
    await _openFeed(t, repo);
    // Chưa thích: nút hiện ngón cái rỗng, chưa có icon tròn màu
    expect(find.descendant(of: find.byType(LikeLabel), matching: find.byIcon(Icons.thumb_up_outlined)),
        findsOneWidget);
    expect(find.descendant(of: find.byType(LikeLabel), matching: find.byType(ReactionIcon)), findsNothing);
    await t.tap(find.text('Thích'));
    // Chạy hiệu ứng nảy từng đoạn: không được lỗi giữa chừng
    await t.pump(const Duration(milliseconds: 120));
    await t.pump(const Duration(milliseconds: 200));
    expect(t.takeException(), isNull);
    await t.pumpAndSettle();
    expect(repo.log, ['react:a:LIKE']);
    // Đã thích: nút đổi sang icon tròn xanh; dòng thống kê cũng hiện cùng icon đó
    expect(find.descendant(of: find.byType(LikeLabel), matching: _icon(ReactionKind.like)), findsOneWidget);
    expect(_icon(ReactionKind.like), findsNWidgets(2));

    await t.tap(find.text('Thích')); // bấm lại = bỏ
    await t.pumpAndSettle();
    expect(repo.log.last, 'unreact:a');
    expect(find.descendant(of: find.byType(LikeLabel), matching: find.byIcon(Icons.thumb_up_outlined)),
        findsOneWidget); // về lại ngón cái rỗng
  });

  testWidgets('rê chuột vào emoji thì hiện tên cảm xúc', (t) async {
    await _openFeed(t, _FakeRepo([_post('a')]));
    await t.longPress(find.text('Thích'));
    await t.pumpAndSettle();
    expect(find.text('Haha'), findsNothing); // chưa rê vào thì chưa có nhãn tên

    final mouse = await t.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    await mouse.moveTo(t.getCenter(_icon(ReactionKind.haha)));
    await t.pump(const Duration(milliseconds: 200));
    expect(find.text('Haha'), findsOneWidget);
  });

  testWidgets('giữ nút Thích hiện đủ 6 emoji, chọn 1 emoji thì thả đúng cảm xúc', (t) async {
    final repo = _FakeRepo([_post('a')]);
    await _openFeed(t, repo);
    await t.longPress(find.text('Thích'));
    await t.pumpAndSettle();
    for (final k in ReactionKind.values) {
      expect(_icon(k), findsOneWidget);
    }
    await t.tap(_icon(ReactionKind.haha));
    await t.pumpAndSettle();
    expect(repo.log, ['react:a:HAHA']);
    expect(_icon(ReactionKind.wow), findsNothing); // thanh đã đóng
  });

  testWidgets('menu Sửa/Xóa chỉ có ở bài của mình', (t) async {
    await _openFeed(t, _FakeRepo([_post('a', mine: true), _post('b')]));
    expect(find.byIcon(Icons.more_horiz), findsOneWidget);
    await t.tap(find.byIcon(Icons.more_horiz));
    await t.pumpAndSettle();
    expect(find.text('Sửa'), findsOneWidget);
    expect(find.text('Xóa'), findsOneWidget);
  });

  testWidgets('nút Đăng khóa khi bài rỗng, mở khi có chữ', (t) async {
    _size(t, 400);
    await t.pumpWidget(_app(_FakeRepo([]), const CreatePostScreen(userName: 'Tôi')));
    await t.pumpAndSettle();
    AppButton post() => t.widget<AppButton>(find.widgetWithText(AppButton, 'Đăng'));
    expect(post().onPressed, isNull);
    await t.enterText(find.byType(EditableText).first, 'xin chào');
    await t.pump();
    expect(post().onPressed, isNotNull);
  });

  testWidgets('sheet bình luận hiển thị bình luận, "Xem N phản hồi" mở reply', (t) async {
    await _openFeed(t, _FakeRepo([_post('a')]));
    await t.tap(find.text('Bình luận'));
    await t.pumpAndSettle();
    expect(find.text('Bình luận gốc'), findsOneWidget);
    expect(find.text('Xem 2 phản hồi'), findsOneWidget);
    expect(find.text('Phản hồi một'), findsNothing);

    await t.tap(find.text('Xem 2 phản hồi'));
    await t.pumpAndSettle();
    expect(find.text('Phản hồi một'), findsOneWidget);
    expect(find.text('Phản hồi hai'), findsOneWidget);
    expect(t.takeException(), isNull);

    // Bấm "Trả lời" hiện dòng "Đang trả lời ..."
    await t.tap(find.text('Trả lời').first);
    await t.pump();
    expect(find.text('Đang trả lời Bình'), findsOneWidget);
  });

  testWidgets('bài chia sẻ hiện khung bài gốc; bài gốc đã xóa hiện ô xám', (t) async {
    final original = _post('o', content: 'Bài gốc');
    final deleted = Post(
        id: 'd', author: _other, content: 'đã xóa', createdAt: DateTime(2026), isDeleted: true);
    await _openFeed(t, _FakeRepo([_post('s1', shared: original), _post('s2', shared: deleted)]));
    expect(find.text('Bài gốc o'), findsOneWidget);
    expect(find.text('Nội dung này không còn tồn tại'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  for (final n in [1, 2, 3, 5]) {
    testWidgets('lưới ảnh $n ảnh không lỗi', (t) async {
      _size(t, 360);
      var tapped = -1;
      await t.pumpWidget(_app(
          _FakeRepo([]), SingleChildScrollView(child: PostImagesGrid(media: _media(n), onTap: (i) => tapped = i))));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      expect(find.byType(Image), findsNWidgets(n > 4 ? 4 : n));
      if (n == 5) expect(find.text('+1'), findsOneWidget);
      await t.tap(find.byType(Image).first);
      expect(tapped, 0);
    });
  }

  testWidgets('điện thoại 360px: thẻ bài full ngang, không tràn', (t) async {
    final repo = _FakeRepo([_post('a', mine: true, media: _media(5)), _post('b')]);
    await _openFeed(t, repo, width: 360);
    expect(t.getSize(find.byType(PostCard).first).width, 360);
    expect(t.takeException(), isNull);
  });

  testWidgets('màn rộng 1200px: cột giữa <= 680px, không tràn', (t) async {
    final repo = _FakeRepo([_post('a', mine: true, media: _media(3)), _post('b')]);
    await _openFeed(t, repo, width: 1200);
    final card = t.getRect(find.byType(PostCard).first);
    expect(card.width, lessThanOrEqualTo(socialMaxWidth));
    expect(card.center.dx, closeTo(600, 1)); // căn giữa
    expect(t.takeException(), isNull);
  });
}
