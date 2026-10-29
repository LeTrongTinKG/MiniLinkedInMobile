class NewsArticleModel {
  final String id;
  final String title;
  final String? summary;
  final String sourceUrl;
  final String sourceName;
  final String category;
  final String language;
  final DateTime publishedAt;
  final String? imageUrl;

  const NewsArticleModel({
    required this.id,
    required this.title,
    this.summary,
    required this.sourceUrl,
    required this.sourceName,
    required this.category,
    required this.language,
    required this.publishedAt,
    this.imageUrl,
  });

  factory NewsArticleModel.fromJson(Map<String, dynamic> json) {
    return NewsArticleModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Không có tiêu đề',
      summary: json['summary']?.toString(),
      sourceUrl: json['sourceUrl']?.toString() ?? '',
      sourceName: json['sourceName']?.toString() ?? 'Nguồn tin',
      category: json['category']?.toString() ?? 'tech',
      language: json['language']?.toString() ?? 'en',
      publishedAt: DateTime.tryParse(json['publishedAt']?.toString() ?? '') ?? DateTime.now(),
      imageUrl: json['imageUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'sourceUrl': sourceUrl,
      'sourceName': sourceName,
      'category': category,
      'language': language,
      'publishedAt': publishedAt.toIso8601String(),
      'imageUrl': imageUrl,
    };
  }
}
