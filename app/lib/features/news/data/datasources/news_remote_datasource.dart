import 'package:dio/dio.dart';
import '../models/news_article_model.dart';

class NewsRemoteDataSource {
  final Dio _dio;

  NewsRemoteDataSource(this._dio);

  Future<List<NewsArticleModel>> getNews({
    String? lang,
    String? category,
    String? query,
    int page = 1,
    int limit = 30,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (lang != null && lang != 'all') params['lang'] = lang;
    if (category != null && category != 'all') params['category'] = category;
    if (query != null && query.trim().isNotEmpty) params['q'] = query.trim();

    final response = await _dio.get('/news', queryParameters: params);
    final data = response.data;
    if (data is Map && data['data'] is List) {
      final list = data['data'] as List;
      return list
          .map((item) => NewsArticleModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}

