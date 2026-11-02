import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../widgets/news_card.dart';
import '../widgets/news_filter_chips.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_spacing.dart';
import 'package:app/ui_kit/app_empty_state.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key, this.embedded = false});

  /// true = đang nằm TRONG khung chính (tab dưới cùng): ẩn AppBar riêng.
  /// false = mở thành trang riêng từ menu bên trái: giữ AppBar riêng.
  final bool embedded;

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<NewsProvider>();
      if (provider.articles.isEmpty) {
        provider.loadNews();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: widget.embedded
          ? null
          : AppBar(
              title: const Text(
                'Tin công nghệ & AI',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              centerTitle: false,
              backgroundColor: AppColors.surface,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Làm mới',
                  onPressed: () => context.read<NewsProvider>().loadNews(),
                ),
              ],
              bottom: const PreferredSize(
                preferredSize: Size.fromHeight(1),
                child: Divider(height: 1, color: AppColors.border),
              ),
            ),
      body: Column(
        children: [
          const NewsFilterChips(),
          Expanded(
            child: Consumer<NewsProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.articles.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null && provider.articles.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.cloud_off_rounded,
                    title: 'Lỗi tải tin tức',
                    message: provider.error!,
                    actionLabel: 'Thử lại',
                    onAction: () => provider.loadNews(),
                  );
                }

                if (provider.articles.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.article_outlined,
                    title: 'Chưa có tin tức',
                    message:
                        'Không có tin tức nào trong danh mục đã chọn.',
                    actionLabel: 'Xem tất cả tin tức',
                    onAction: () {
                      provider.setCategory('all');
                      provider.setLanguage('all');
                      provider.loadNews();
                    },
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () => provider.loadNews(),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      0,
                      8,
                      0,
                      AppSpacing.bottomContentPadding,
                    ),
                    itemCount: provider.articles.length,
                    itemBuilder: (context, index) {
                      return NewsCard(article: provider.articles[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
