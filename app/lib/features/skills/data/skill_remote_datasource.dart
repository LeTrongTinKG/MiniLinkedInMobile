import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../domain/models/skill_item.dart';
import 'skill_suggestion.dart';

/// DataSource kết nối API kỹ năng và quét repo GitHub (ADR-0005, ADR-0007, Ticket 04).
class SkillRemoteDataSource {
  final Dio _dio;

  SkillRemoteDataSource(this._dio);

  List<SkillSuggestion> _parseSuggestions(dynamic list) =>
      (list as List<dynamic>)
          .map((e) => SkillSuggestion.fromJson(e as Map<String, dynamic>))
          .toList();

  Future<List<SkillItem>> getMySkills() async {
    try {
      final response = await _dio.get('/skills');
      final list = response.data['data'] as List<dynamic>? ?? [];
      return list
          .map((e) => SkillItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw DioClient.handleDioError(e);
    }
  }

  Future<SkillItem> addSelfClaimed(String skillName) async {
    try {
      final response = await _dio.post(
        '/skills',
        data: {'skillName': skillName.trim()},
      );
      return SkillItem.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw DioClient.handleDioError(e);
    }
  }

  Future<void> deleteSkill(String skillName) async {
    try {
      await _dio.delete('/skills/${Uri.encodeComponent(skillName.trim())}');
    } on DioException catch (e) {
      throw DioClient.handleDioError(e);
    }
  }

  Future<List<SkillSuggestion>> getSuggestions() async {
    try {
      final response = await _dio.get('/skills/suggestions');
      return _parseSuggestions(response.data['data']);
    } on DioException catch (e) {
      throw DioClient.handleDioError(e);
    }
  }

  Future<List<SkillSuggestion>> scanGithub() async {
    try {
      final response = await _dio.post('/skills/suggestions/github');
      return _parseSuggestions(response.data['data']['suggestions']);
    } on DioException catch (e) {
      throw DioClient.handleDioError(e);
    }
  }

  /// Quét một URL GitHub Repo bất kỳ do ứng viên dán làm bằng chứng ("Up Repo thay vì CV").
  Future<List<SkillSuggestion>> scanCustomRepo(String repoUrl) async {
    try {
      final response = await _dio.post(
        '/skills/repo',
        data: {'repoUrl': repoUrl.trim()},
      );
      return _parseSuggestions(response.data['data']['suggestions']);
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

  Future<void> endorseSkill(String targetUserId, String skillName) async {
    try {
      await _dio.post(
        '/skills/${Uri.encodeComponent(skillName.trim())}/endorse',
        data: {'targetUserId': targetUserId},
      );
    } on DioException catch (e) {
      throw DioClient.handleDioError(e);
    }
  }
}
