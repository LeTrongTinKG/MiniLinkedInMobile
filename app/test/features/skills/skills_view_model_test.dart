import 'package:flutter_test/flutter_test.dart';
import 'package:app/core/common/result.dart';
import 'package:app/features/skills/data/skill_suggestion.dart';
import 'package:app/features/skills/domain/models/skill_confidence.dart';
import 'package:app/features/skills/domain/models/skill_item.dart';
import 'package:app/features/skills/domain/repositories/skill_repository.dart';
import 'package:app/features/skills/presentation/viewmodels/skills_view_model.dart';

class FakeSkillRepository implements SkillRepository {
  List<SkillItem> items = [];
  List<SkillSuggestion> suggestions = [];

  @override
  Future<Result<List<SkillItem>>> getMySkills() async => Result.ok(items);

  @override
  Future<Result<SkillItem>> addSelfClaimed(String name) async {
    final item = SkillItem(
      id: 'id-$name',
      name: name,
      confidence: SkillConfidence.selfClaimed,
    );
    items.add(item);
    return Result.ok(item);
  }

  @override
  Future<Result<void>> deleteSkill(String name) async {
    items.removeWhere((i) => i.name == name);
    return Result.ok(null);
  }

  @override
  Future<Result<List<SkillSuggestion>>> getSuggestions() async => Result.ok(suggestions);

  @override
  Future<Result<List<SkillSuggestion>>> scanGithub() async => Result.ok(suggestions);

  @override
  Future<Result<List<SkillSuggestion>>> scanCustomRepo(String repoUrl) async => Result.ok(suggestions);

  @override
  Future<Result<void>> decideSuggestion(String id, {required bool accept}) async {
    suggestions.removeWhere((s) => s.id == id);
    return Result.ok(null);
  }
}

void main() {
  group('SkillsViewModel Tests (MVVM)', () {
    test('load populates skills and suggestions', () async {
      final fakeRepo = FakeSkillRepository()
        ..items = [
          const SkillItem(id: '1', name: 'Flutter', confidence: SkillConfidence.evidenced),
        ]
        ..suggestions = [
          const SkillSuggestion(id: 's1', skillName: 'Dart', evidence: []),
        ];

      final vm = SkillsViewModel(fakeRepo);
      await vm.load();

      expect(vm.skills.length, equals(1));
      expect(vm.skills.first.name, equals('Flutter'));
      expect(vm.skills.first.confidence, equals(SkillConfidence.evidenced));
      expect(vm.suggestions.length, equals(1));
    });

    test('addSkill adds self-claimed skill', () async {
      final fakeRepo = FakeSkillRepository();
      final vm = SkillsViewModel(fakeRepo);

      final success = await vm.addSkill('Docker');
      expect(success, isTrue);
      expect(vm.skills.length, equals(1));
      expect(vm.skills.first.name, equals('Docker'));
      expect(vm.skills.first.confidence, equals(SkillConfidence.selfClaimed));
    });

    test('addSkill rejects empty name', () async {
      final fakeRepo = FakeSkillRepository();
      final vm = SkillsViewModel(fakeRepo);

      final success = await vm.addSkill('   ');
      expect(success, isFalse);
      expect(vm.failure, isNotNull);
    });

    test('delete removes skill from list', () async {
      final fakeRepo = FakeSkillRepository()
        ..items = [
          const SkillItem(id: '1', name: 'Docker', confidence: SkillConfidence.selfClaimed),
        ];

      final vm = SkillsViewModel(fakeRepo);
      await vm.load();
      expect(vm.skills.length, equals(1));

      await vm.delete(vm.skills.first);
      expect(vm.skills, isEmpty);
    });
  });
}

