import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/news/data/models/news_article_model.dart';

void main() {
  group('NewsArticleModel', () {
    test('fromJson parses correctly with full fields', () {
      final json = {
        'id': 'hn-123',
        'title': 'AI breakthrough in 2026',
        'summary': 'New model trained with less compute.',
        'sourceUrl': 'https://news.ycombinator.com/item?id=123',
        'sourceName': 'Hacker News',
        'category': 'ai',
        'language': 'en',
        'publishedAt': '2026-10-29T10:00:00.000Z',
        'imageUrl': 'https://example.com/image.jpg',
      };

      final article = NewsArticleModel.fromJson(json);

      expect(article.id, 'hn-123');
      expect(article.title, 'AI breakthrough in 2026');
      expect(article.summary, 'New model trained with less compute.');
      expect(article.sourceUrl, 'https://news.ycombinator.com/item?id=123');
      expect(article.sourceName, 'Hacker News');
      expect(article.category, 'ai');
      expect(article.language, 'en');
      expect(article.publishedAt, DateTime.parse('2026-10-29T10:00:00.000Z'));
      expect(article.imageUrl, 'https://example.com/image.jpg');
    });

    test('fromJson handles null and missing fields gracefully', () {
      final json = <String, dynamic>{
        'id': 'vn-456',
        'sourceUrl': 'https://vnexpress.net/test',
      };

      final article = NewsArticleModel.fromJson(json);

      expect(article.id, 'vn-456');
      expect(article.title, 'Không có tiêu đề');
      expect(article.summary, isNull);
      expect(article.sourceUrl, 'https://vnexpress.net/test');
      expect(article.sourceName, 'Nguồn tin');
      expect(article.category, 'tech');
      expect(article.language, 'en');
      expect(article.imageUrl, isNull);
    });

    test('toJson produces valid map', () {
      final article = NewsArticleModel(
        id: 'jobs-789',
        title: 'Tuyển dụng kỹ sư AI',
        summary: 'Mức lương hấp dẫn',
        sourceUrl: 'https://tinhte.vn/jobs',
        sourceName: 'Tinhte',
        category: 'jobs',
        language: 'vi',
        publishedAt: DateTime.parse('2026-10-29T09:00:00.000Z'),
      );

      final json = article.toJson();

      expect(json['id'], 'jobs-789');
      expect(json['title'], 'Tuyển dụng kỹ sư AI');
      expect(json['category'], 'jobs');
      expect(json['language'], 'vi');
      expect(json['publishedAt'], '2026-10-29T09:00:00.000Z');
    });
  });
}
