import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import 'skill_suggestion.dart';

class SkillRemoteDataSource {
  final Dio _dio;

  SkillRemoteDataSource(this._dio);

  List<SkillSuggestion> _parse(dynamic list) => (list as List<dynamic>)
      .map((e) => SkillSuggestion.fromJson(e as Map<String, dynamic>))
      .toList();

  Future<List<SkillSuggestion>> getSuggestions() async {
    try {
      final response = await _dio.get('/skills/suggestions');
      return _parse(response.data['data']);
    } on DioException catch (e) {
      throw DioClient.handleDioError(e);
    }
  }

  /// Quét repo GitHub của chính mình; trả danh sách đề xuất đang chờ duyệt.
  Future<List<SkillSuggestion>> scanGithub() async {
    try {
      final response = await _dio.post('/skills/suggestions/github');
      return _parse(response.data['data']['suggestions']);
    } on DioException catch (e) {
      throw DioClient.handleDioError(e);
    }
  }

  Future<void> decide(String id, {required bool accept}) async {
    try {
      await _dio
          .post('/skills/suggestions/$id/${accept ? 'accept' : 'reject'}');
    } on DioException catch (e) {
      throw DioClient.handleDioError(e);
    }
  }
}
