import '../../../../core/common/result.dart';
import '../../../../core/error/app_failure.dart';
import '../domain/models/skill_item.dart';
import '../domain/repositories/skill_repository.dart';
import 'skill_remote_datasource.dart';
import 'skill_suggestion.dart';

class SkillRepositoryImpl implements SkillRepository {
  final SkillRemoteDataSource _dataSource;

  SkillRepositoryImpl(this._dataSource);

  AppFailure _mapError(dynamic e) {
    final msg = e.toString().replaceFirst('Exception: ', '');
    if (msg.contains('SocketException') || msg.contains('kết nối')) {
      return const NetworkFailure();
    }
    if (msg.contains('hết hạn') || msg.contains('401')) {
      return const UnauthorizedFailure();
    }
    if (msg.contains('hạn mức') || msg.contains('429')) {
      return const QuotaFailure();
    }
    return ServerFailure(msg);
  }

  @override
  Future<Result<List<SkillItem>>> getMySkills() async {
    try {
      final items = await _dataSource.getMySkills();
      return Result.ok(items);
    } catch (e) {
      return Result.error(_mapError(e));
    }
  }

  @override
  Future<Result<SkillItem>> addSelfClaimed(String name) async {
    try {
      final item = await _dataSource.addSelfClaimed(name);
      return Result.ok(item);
    } catch (e) {
      return Result.error(_mapError(e));
    }
  }

  @override
  Future<Result<void>> deleteSkill(String name) async {
    try {
      await _dataSource.deleteSkill(name);
      return Result.ok(null);
    } catch (e) {
      return Result.error(_mapError(e));
    }
  }

  @override
  Future<Result<List<SkillSuggestion>>> getSuggestions() async {
    try {
      final list = await _dataSource.getSuggestions();
      return Result.ok(list);
    } catch (e) {
      return Result.error(_mapError(e));
    }
  }

  @override
  Future<Result<List<SkillSuggestion>>> scanGithub() async {
    try {
      final list = await _dataSource.scanGithub();
      return Result.ok(list);
    } catch (e) {
      return Result.error(_mapError(e));
    }
  }

  @override
  Future<Result<List<SkillSuggestion>>> scanCustomRepo(String repoUrl) async {
    try {
      final list = await _dataSource.scanCustomRepo(repoUrl);
      return Result.ok(list);
    } catch (e) {
      return Result.error(_mapError(e));
    }
  }

  @override
  Future<Result<void>> decideSuggestion(
    String id, {
    required bool accept,
  }) async {
    try {
      await _dataSource.decide(id, accept: accept);
      return Result.ok(null);
    } catch (e) {
      return Result.error(_mapError(e));
    }
  }
}

