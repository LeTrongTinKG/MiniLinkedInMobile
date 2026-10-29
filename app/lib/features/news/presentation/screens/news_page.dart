import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../widgets/news_card.dart';
import '../widgets/news_filter_chips.dart';
import 'package:app/core/theme/app_colors.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key, this.embedded = false});

  /// true = đang nằm TRONG khung chính (tab dưới cùng): khung đã có header chung nên ẩn AppBar riêng.
  /// false = mở thành trang riêng từ menu bên trái: giữ AppBar có nút quay lại và nút làm mới.
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
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
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.iconMuted),
                          const SizedBox(height: 12),
                          Text(
                            provider.error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => provider.loadNews(),
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (provider.articles.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.article_outlined, size: 48, color: AppColors.iconMuted),
                        SizedBox(height: 12),
                        Text(
                          'Không có tin tức nào trong danh mục này',
                          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.loadNews(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
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
