import '../../../../core/common/result.dart';
import '../../data/skill_suggestion.dart';
import '../models/skill_item.dart';

/// Repository giao tiếp dữ liệu kỹ năng sử dụng Result pattern.
abstract class SkillRepository {
  Future<Result<List<SkillItem>>> getMySkills();
  Future<Result<SkillItem>> addSelfClaimed(String name);
  Future<Result<void>> deleteSkill(String name);
  Future<Result<List<SkillSuggestion>>> getSuggestions();
  Future<Result<List<SkillSuggestion>>> scanGithub();
  Future<Result<List<SkillSuggestion>>> scanCustomRepo(String repoUrl);
  Future<Result<void>> decideSuggestion(String id, {required bool accept});
}

