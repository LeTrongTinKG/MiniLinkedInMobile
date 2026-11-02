import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/jobs/data/models/job_model.dart';
import 'package:app/features/jobs/domain/entities/job_entity.dart';
import 'package:app/features/jobs/domain/entities/job_filter.dart';

void main() {
  group('JobEntity & JobModel Tests', () {
    test('JobModel.fromJson converts to JobEntity correctly', () {
      final json = {
        'id': 'job-100',
        'recruiterId': 'rec-1',
        'title': 'Flutter Developer Intern',
        'companyName': 'Google VN',
        'location': 'Hà Nội',
        'workMode': 'hybrid',
        'level': 'intern',
        'salaryMin': 500,
        'salaryMax': 800,
        'description': 'Mô tả công việc',
        'requiredSkills': ['Flutter', 'Dart'],
        'niceToHave': ['Firebase'],
        'status': 'open',
        'createdAt': '2026-10-20T10:00:00.000Z',
      };

      final model = JobModel.fromJson(json);
      final entity = model.toEntity();

      expect(entity.id, 'job-100');
      expect(entity.title, 'Flutter Developer Intern');
      expect(entity.companyName, 'Google VN');
      expect(entity.workMode, WorkMode.hybrid);
      expect(entity.level, JobLevel.intern);
      expect(entity.formattedSalary, '\$500–800');
      expect(entity.requiredSkills, contains('Flutter'));
    });

    test('JobModel.fromJson đọc payload GET /jobs của Render', () {
      final json = {
        'id': '60272f08-8b7b-4239-a43f-3c934a1d72c7',
        'recruiterId': 'df4204b1-a465-453a-9988-89df077997af',
        'title': 'Junior Full Stack Developer',
        'companyName': 'FPT Software',
        'companyLogoUrl': null,
        'location': 'Hà Nội',
        'workMode': 'remote',
        'level': 'junior',
        'salaryMin': 12000000,
        'salaryMax': 18000000,
        'description': 'Phụ trách end-to-end',
        'requiredSkills': ['react', 'nodejs'],
        'niceToHave': ['graphql'],
        'status': 'open',
        'createdAt': '2026-10-22T13:16:27.141Z',
        'updatedAt': '2026-10-22T13:16:27.141Z',
        'recruiter': {'id': 'df4204b1', 'fullName': 'Nguyễn Hồng Anh'},
        'applicationsCount': 0,
      };

      final entity = JobModel.fromJson(json).toEntity();
      expect(entity.companyName, 'FPT Software');
      expect(entity.workMode, WorkMode.remote);
      expect(entity.level, JobLevel.junior);
      expect(entity.salaryMin, 12000000);
      expect(entity.requiredSkills, ['react', 'nodejs']);
    });

    test('JobFilter detection, reset & serialization works accurately', () {
      var filter = const JobFilter();
      expect(filter.hasFilter, false);
      expect(filter.activeFilterCount, 0);

      filter = filter.copyWith(
        keyword: 'Flutter',
        workMode: () => WorkMode.remote,
        level: () => JobLevel.fresher,
        selectedSkills: {'Dart', 'Git'},
      );

      expect(filter.hasFilter, true);
      expect(filter.activeFilterCount, 4);

      // Kiểm tra chuyển đổi JSON sang - về bảo toàn dữ liệu
      final json = filter.toJson();
      final restoredFilter = JobFilter.fromJson(json);

      expect(restoredFilter.keyword, 'Flutter');
      expect(restoredFilter.workMode, WorkMode.remote);
      expect(restoredFilter.level, JobLevel.fresher);
      expect(restoredFilter.selectedSkills, contains('Dart'));
      expect(restoredFilter.selectedSkills, contains('Git'));

      final resetFilter = filter.reset();
      expect(resetFilter.hasFilter, false);
      expect(resetFilter.activeFilterCount, 0);
    });
  });
}
