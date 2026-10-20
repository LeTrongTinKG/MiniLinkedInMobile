import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/jobs/data/models/job_model.dart';
import 'package:app/features/jobs/domain/entities/job_entity.dart';
import 'package:app/features/jobs/domain/entities/job_filter.dart';
import 'package:app/features/jobs/data/datasources/job_mock_datasource.dart';

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
      expect(entity.formattedSalary, '\$500 - \$800/tháng');
      expect(entity.requiredSkills, contains('Flutter'));
    });

    test('JobFilter detection & reset works accurately', () {
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
      expect(filter.activeFilterCount, 4); // workMode (1) + level (1) + 2 skills = 4

      final resetFilter = filter.reset();
      expect(resetFilter.hasFilter, false);
      expect(resetFilter.activeFilterCount, 0);
    });

    test('JobMockDataSource filters jobs correctly by keyword and skills', () async {
      final dataSource = JobMockDataSource();

      // Lấy toàn bộ jobs
      final allJobs = await dataSource.getJobs();
      expect(allJobs.isNotEmpty, true);

      // Lọc theo từ khóa 'Flutter'
      final flutterJobs = await dataSource.getJobs(
        filter: const JobFilter(keyword: 'Flutter'),
      );
      expect(flutterJobs.isNotEmpty, true);
      for (final job in flutterJobs) {
        final match = job.title.toLowerCase().contains('flutter') ||
            job.requiredSkills.any((s) => s.toLowerCase().contains('flutter'));
        expect(match, true);
      }

      // Lọc theo WorkMode 'remote'
      final remoteJobs = await dataSource.getJobs(
        filter: const JobFilter(workMode: WorkMode.remote),
      );
      for (final job in remoteJobs) {
        expect(job.workMode, 'remote');
      }
    });
  });
}
