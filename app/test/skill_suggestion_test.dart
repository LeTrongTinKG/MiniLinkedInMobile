import 'package:app/core/error/app_exception.dart';
import 'package:app/features/cv/data/models/cv_model.dart';
import 'package:app/features/skills/data/skill_remote_datasource.dart';
import 'package:app/features/skills/data/skill_suggestion.dart';
import 'package:app/features/skills/presentation/github_skill_section.dart';
import 'package:app/features/skills/presentation/skill_suggestion_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

const _dart = SkillSuggestion(
  id: 's1',
  skillName: 'Dart',
  evidence: [
    SkillEvidence(repo: 'me/app', url: 'u', signals: ['language:Dart']),
  ],
);

/// Nguồn dữ liệu giả, không gọi mạng.
class FakeSource extends SkillRemoteDataSource {
  FakeSource() : super(Dio());
  final List<String> log = [];
  Object? failWith;

  @override
  Future<List<SkillSuggestion>> getSuggestions() async => [_dart];

  @override
  Future<List<SkillSuggestion>> scanGithub() async {
    if (failWith != null) throw failWith!;
    return [_dart];
  }

  @override
  Future<void> decide(String id, {required bool accept}) async {
    log.add('$id:$accept');
  }
}

void main() {
  test('đọc đề xuất kèm bằng chứng từ JSON của server', () {
    final s = SkillSuggestion.fromJson({
      'id': 's1',
      'skillName': 'Provider',
      'evidence': [
        {
          'repo': 'me/app',
          'url': 'u',
          'signals': ['dependency:pub:provider']
        },
      ],
    });
    expect(s.evidence.single.repo, 'me/app');
    expect(s.confidenceLabel, isNull);
    expect(
      const SkillSuggestion(
        id: 's2',
        skillName: 'Dart',
        evidence: [],
        confidence: 'evidenced',
      ).confidenceLabel,
      'Có hoạt động mã nguồn đáng kể',
    );
    expect(signalLabel(s.evidence.single.signals.single),
        'dùng thư viện provider');
  });

  test('CV đọc câu trích làm bằng chứng; CV cũ không có thì rỗng', () {
    final cv = CvModel.fromJson({
      'id': 'c1',
      'fileName': 'cv.pdf',
      'fileUrl': 'u',
      'extractedSkills': {
        'skills': ['flutter'],
        'evidence': [
          {'skill': 'flutter', 'quote': 'Flutter, Dart'},
        ],
      },
    });
    expect(cv.toEntity().evidence, {'flutter': 'Flutter, Dart'});
    final old = CvModel.fromJson({
      'id': 'c2',
      'fileName': 'cv.pdf',
      'fileUrl': 'u',
      'extractedSkills': ['flutter'],
    });
    expect(old.toEntity().evidence, isEmpty);
  });

  test('lỗi từ server hiện đúng câu tiếng Việt', () async {
    final source = FakeSource()
      ..failWith = const ApiException(
        statusCode: 400,
        errorCode: 'GITHUB_NOT_LINKED',
        message: 'Hãy đăng nhập bằng GitHub',
      );
    final p = SkillSuggestionProvider(source);
    await p.scan();
    expect(p.errorMessage, 'Hãy đăng nhập bằng GitHub');
  });

  testWidgets('hiện bằng chứng, bấm "Thêm vào hồ sơ" thì đề xuất biến mất',
      (tester) async {
    final source = FakeSource();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider(
            create: (_) => SkillSuggestionProvider(source)..load(),
            child: const GithubSkillSection(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('me/app: viết chủ yếu bằng Dart'), findsOneWidget);

    await tester.tap(find.text('Thêm vào hồ sơ'));
    await tester.pumpAndSettle();
    expect(source.log, ['s1:true']);
    expect(find.text('Dart'), findsNothing);
  });
}
