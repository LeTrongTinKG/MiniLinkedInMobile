import 'package:flutter_test/flutter_test.dart';
import 'package:app/core/common/result.dart';
import 'package:app/core/error/app_failure.dart';
import 'package:app/features/skills/data/skill_suggestion.dart';
import 'package:app/features/skills/domain/models/skill_item.dart';
import 'package:app/features/skills/domain/repositories/skill_repository.dart';
import 'package:app/features/skills/presentation/viewmodels/repo_upload_view_model.dart';

class FakeRepoSkillRepository implements SkillRepository {
  String? lastScannedRepo;

  @override
  Future<Result<List<SkillItem>>> getMySkills() async => Result.ok([]);

  @override
  Future<Result<SkillItem>> addSelfClaimed(String name) async =>
      throw UnimplementedError();

  @override
  Future<Result<void>> deleteSkill(String name) async =>
      throw UnimplementedError();

  @override
  Future<Result<List<SkillSuggestion>>> getSuggestions() async => Result.ok([]);

  @override
  Future<Result<List<SkillSuggestion>>> scanGithub() async => Result.ok([]);

  @override
  Future<Result<List<SkillSuggestion>>> scanCustomRepo(String repoUrl) async {
    lastScannedRepo = repoUrl;
    return Result.ok([
      const SkillSuggestion(
        id: 's-flutter',
        skillName: 'Flutter',
        confidence: 'evidenced',
        evidence: [
          SkillEvidence(
            repo: 'user/repo',
            url: 'https://github.com/user/repo',
            signals: ['pubspec.yaml', 'Dart'],
          ),
        ],
      ),
    ]);
  }

  @override
  Future<Result<void>> decideSuggestion(String id, {required bool accept}) async =>
      Result.ok(null);
}

void main() {
  group('RepoUploadViewModel Tests ("Up Repo thay vì CV")', () {
    test('rejects empty url', () async {
      final fakeRepo = FakeRepoSkillRepository();
      final vm = RepoUploadViewModel(fakeRepo);

      final ok = await vm.scanRepo(hasConsent: true);
      expect(ok, isFalse);
      expect(vm.failure, isA<ValidationFailure>());
    });

    test('rejects invalid repo format', () async {
      final fakeRepo = FakeRepoSkillRepository();
      final vm = RepoUploadViewModel(fakeRepo);
      vm.setRepoUrl('https://google.com/search');

      final ok = await vm.scanRepo(hasConsent: true);
      expect(ok, isFalse);
      expect(vm.failure, isA<ValidationFailure>());
    });

    test('blocks scan when consent is not granted', () async {
      final fakeRepo = FakeRepoSkillRepository();
      final vm = RepoUploadViewModel(fakeRepo);
      vm.setRepoUrl('https://github.com/flutter/flutter');

      final ok = await vm.scanRepo(hasConsent: false);
      expect(ok, isFalse);
      expect(vm.failure, isA<ConsentRequiredFailure>());
    });

    test('scans valid github repo when consent is granted', () async {
      final fakeRepo = FakeRepoSkillRepository();
      final vm = RepoUploadViewModel(fakeRepo);
      vm.setRepoUrl('https://github.com/flutter/samples');

      final ok = await vm.scanRepo(hasConsent: true);
      expect(ok, isTrue);
      expect(fakeRepo.lastScannedRepo, equals('https://github.com/flutter/samples'));
      expect(vm.suggestions.length, equals(1));
      expect(vm.suggestions.first.skillName, equals('Flutter'));
      expect(vm.suggestions.first.confidence, equals('evidenced'));
    });
  });
}

