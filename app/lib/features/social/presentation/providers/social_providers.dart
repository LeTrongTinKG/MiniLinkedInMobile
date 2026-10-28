import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../../data/datasources/social_remote_datasource.dart';
import '../../data/repositories/social_repository_impl.dart';
import '../../domain/repositories/social_repository.dart';
import 'social_feed_provider.dart';

/// Bọc trang social: tự dựng repository + SocialFeedProvider tại chỗ
/// (giống bọc Context.Provider quanh 1 màn hình trong React), không đăng ký trong main.dart.
///
/// - Truyền `repository` (dùng khi test), hoặc
/// - không truyền thì lấy `Dio` của dioClient từ context: main.dart cần có
///   `Provider<Dio>.value(value: dioClient.dio)`.
class SocialProviders extends StatelessWidget {
  const SocialProviders({super.key, required this.child, this.repository});

  final Widget child;
  final SocialRepository? repository;

  @override
  Widget build(BuildContext context) {
    final repo = repository ?? SocialRepositoryImpl(SocialRemoteDataSource(context.read<Dio>()));
    return MultiProvider(
      providers: [
        Provider<SocialRepository>.value(value: repo), // để UI tạo CommentsProvider
        ChangeNotifierProvider(create: (_) => SocialFeedProvider(repo)),
      ],
      child: child,
    );
  }
}
