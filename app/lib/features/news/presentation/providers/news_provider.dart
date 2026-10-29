import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/datasources/news_remote_datasource.dart';
import '../../data/models/news_article_model.dart';

class NewsProvider extends ChangeNotifier {
  final NewsRemoteDataSource _dataSource;

  NewsProvider(this._dataSource) {
    _startAutoRefresh();
  }

  List<NewsArticleModel> _articles = [];
  List<NewsArticleModel> get articles => _articles;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  String _selectedLang = 'all'; // 'all', 'en', 'vi'
  String get selectedLang => _selectedLang;

  String _selectedCategory = 'all'; // 'all', 'ai', 'tech', 'jobs'
  String get selectedCategory => _selectedCategory;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  Timer? _refreshTimer;

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    // Tự động làm mới ngầm mỗi 5 phút
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      loadNews(isSilent: true);
    });
  }

  Future<void> loadNews({bool isSilent = false}) async {
    if (!isSilent) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      final items = await _dataSource.getNews(
        lang: _selectedLang,
        category: _selectedCategory,
        query: _searchQuery,
      );
      _articles = items;
      _error = null;
    } catch (e) {
      if (!isSilent) {
        _error = 'Không thể tải tin tức: ${e.toString()}';
      }
    } finally {
      if (!isSilent) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  void setLanguage(String lang) {
    if (_selectedLang == lang) return;
    _selectedLang = lang;
    loadNews();
  }

  void setCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    loadNews();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    loadNews();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
