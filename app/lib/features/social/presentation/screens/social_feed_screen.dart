import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../ui_kit/ui_kit.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/social_feed_provider.dart';
import '../social_strings.dart';
import '../widgets/composer_box.dart';
import '../widgets/feed_skeleton.dart';
import '../widgets/max_width_box.dart';
import '../widgets/post_actions.dart';
import '../widgets/post_card.dart';

/// Màn bảng tin: ô "Bạn đang nghĩ gì?" + danh sách bài cuộn vô hạn + kéo để làm mới.
class SocialFeedScreen extends StatefulWidget {
  const SocialFeedScreen({super.key});

  @override
  State<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends State<SocialFeedScreen> {
  static const _pageBg = AppColors.background;
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    // Giống useEffect(() => {...}, []): chạy 1 lần sau khi màn dựng xong
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<SocialFeedProvider>().loadInitial());
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  // Cuộn gần cuối (còn 400px) thì tải thêm bài
  void _onScroll() {
    if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 400) _loadMore();
  }

  Future<void> _loadMore() async {
    final feed = context.read<SocialFeedProvider>();
    await feed.loadMore();
    if (feed.error != null && mounted) showAppError(context, feed.error!);
  }

  // Kéo xuống làm mới
  Future<void> _refresh() async {
    final feed = context.read<SocialFeedProvider>();
    await feed.refresh();
    if (feed.error != null && mounted) showAppError(context, feed.error!);
  }

  @override
  Widget build(BuildContext context) {
    final feed = context.watch<SocialFeedProvider>();
    final user = context.watch<AuthProvider>().currentUser;
    final name = user?.displayName ?? '';

    return ColoredBox(
      color: _pageBg,
      child: MaxWidthBox(
        child: _body(feed, name, user?.avatarUrl),
      ),
    );
  }

  Widget _body(SocialFeedProvider feed, String name, String? avatar) {
    // Lần đầu đang tải
    if (feed.status == FeedStatus.loading) {
      return SingleChildScrollView(child: Column(children: [_composer(name, avatar), const FeedSkeleton()]));
    }
    // Lỗi, chưa có bài nào
    if (feed.status == FeedStatus.error) {
      return AppEmptyState(
        title: SocialStrings.feedErrorTitle,
        message: feed.error,
        icon: Icons.cloud_off_outlined,
        actionLabel: SocialStrings.retry,
        onAction: feed.refresh,
      );
    }

    // Có dữ liệu: ListView.builder ~ posts.map(...). Phần tử 0 là ô soạn, cuối là vòng xoay tải thêm.
    final count = feed.posts.length;
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: count + 2,
        itemBuilder: (context, i) {
          if (i == 0) return _composer(name, avatar);
          if (i == count + 1) return _footer(feed);
          return Padding(
            padding: const EdgeInsets.only(top: 8), // vạch ngăn giữa các bài
            child: PostCard(key: ValueKey(feed.posts[i - 1].id), post: feed.posts[i - 1]),
          );
        },
      ),
    );
  }

  Widget _composer(String name, String? avatar) {
    return ComposerBox(
      userName: name,
      userAvatar: avatar,
      onTap: () => openCreatePost(context, userName: name, userAvatar: avatar),
    );
  }

  // Cuối danh sách: vòng xoay khi đang tải thêm, hoặc thông báo rỗng
  Widget _footer(SocialFeedProvider feed) {
    if (feed.loadingMore) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))),
      );
    }
    if (feed.isEmpty) {
      return const SizedBox(
        height: 320,
        child: AppEmptyState(
          title: SocialStrings.feedEmptyTitle,
          message: SocialStrings.feedEmptyMessage,
          icon: Icons.forum_outlined,
        ),
      );
    }
    return const SizedBox(height: AppSpacing.bottomContentPadding);
  }
}
