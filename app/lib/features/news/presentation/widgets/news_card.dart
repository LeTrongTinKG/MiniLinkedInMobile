import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/news_article_model.dart';
import 'package:app/core/theme/app_colors.dart';

/// Card bài viết tin tức phong cách v0 bo góc 22dp.
class NewsCard extends StatelessWidget {
  final NewsArticleModel article;

  const NewsCard({super.key, required this.article});

  Future<void> _launchArticleUrl(BuildContext context, String urlString) async {
    final uri = Uri.tryParse(urlString);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể mở liên kết bài viết')),
      );
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes}p trước';
    if (diff.inHours < 24) return '${diff.inHours}h trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return '${dateTime.day}/${dateTime.month}';
  }

  (Color, Color, String) _getCategoryStyle(String category, bool isDark) {
    switch (category) {
      case 'ai':
        return isDark
            ? (const Color(0xFFA5B4FC), const Color(0xFF312E81), 'AI Tech')
            : (const Color(0xFF4F46E5), const Color(0xFFEEF2FF), 'AI Tech');
      case 'jobs':
        return isDark
            ? (const Color(0xFF6EE7B7), const Color(0xFF064E3B), 'Việc làm')
            : (const Color(0xFF059669), const Color(0xFFECFDF5), 'Việc làm');
      default:
        return isDark
            ? (const Color(0xFF93C5FD), const Color(0xFF1E3A8A), 'Tech Trends')
            : (const Color(0xFF2563EB), const Color(0xFFEFF6FF), 'Tech Trends');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (catColor, catBg, catLabel) = _getCategoryStyle(article.category, isDark);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => _launchArticleUrl(context, article.sourceUrl),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: catBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        catLabel,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: catColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.newspaper_rounded,
                      size: 13,
                      color: isDark ? Colors.white38 : AppColors.iconMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatTimeAgo(article.publishedAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white38 : AppColors.textMuted,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.north_east_rounded,
                      size: 14,
                      color: isDark ? Colors.white54 : AppColors.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  article.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                if (article.summary != null && article.summary!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    article.summary!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: isDark ? Colors.white60 : AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.public,
                      size: 13,
                      color: isDark ? Colors.white38 : AppColors.iconMuted,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        article.sourceName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white54 : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
