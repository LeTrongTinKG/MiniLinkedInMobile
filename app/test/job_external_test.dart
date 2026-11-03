import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:app/core/error/app_exception.dart';
import 'package:app/features/applications/data/application_remote_datasource.dart';
import 'package:app/features/applications/domain/entities/application_entity.dart';
import 'package:app/features/applications/presentation/providers/student_applications_provider.dart';
import 'package:app/features/jobs/data/models/job_model.dart';
import 'package:app/features/jobs/domain/entities/job_entity.dart';
import 'package:app/features/jobs/presentation/widgets/job_apply_button.dart';

// Datasource giả: không gọi mạng. Có thể giả lập server từ chối job ngoài.
class _FakeApplicationDataSource extends ApplicationRemoteDataSource {
  _FakeApplicationDataSource({this.externalUrl}) : super(Dio());

  final String? externalUrl;
  int applyCalls = 0;

  @override
  Future<List<ApplicationEntity>> getMyApplications() async => [];

  @override
  Future<ApplicationEntity> apply(String jobId) async {
    applyCalls++;
    throw ApiException(
      statusCode: 409,
      errorCode: 'EXTERNAL_JOB_APPLY',
      message: 'Job ngoài',
      applyUrl: externalUrl,
    );
  }
}

JobEntity _job({String? applyUrl, String source = 'internal'}) => JobModel.fromJson({
      'id': 'j1',
      'title': 'Dev',
      'companyName': 'ACME',
      'location': 'Hà Nội',
      'source': source,
      'applyUrl': applyUrl,
    }).toEntity();

Future<List<String>> _pumpButton(
  WidgetTester t,
  JobEntity job,
  _FakeApplicationDataSource ds,
) async {
  final opened = <String>[];
  await t.pumpWidget(ChangeNotifierProvider(
    create: (_) => StudentApplicationsProvider(ds),
    child: MaterialApp(
      home: Scaffold(
        body: JobApplyButton(job: job, opener: (url) async {
          opened.add(url);
          return true;
        }),
      ),
    ),
  ));
  return opened;
}

void main() {
  group('JobModel với dữ liệu job ngoài', () {
    test('recruiter null + level mới + applyUrl vẫn parse được', () {
      final entity = JobModel.fromJson({
        'id': 'x1',
        'title': 'Senior Dev',
        'companyName': 'Remote Co',
        'location': 'Anywhere',
        'level': 'senior',
        'recruiter': null,
        'source': 'remotive',
        'applyUrl': 'https://remotive.com/job/1',
        'salaryMin': 2000,
        'salaryMax': 3000,
        'salaryCurrency': 'USD',
        'createdAt': '2026-10-20T10:00:00.000Z',
      }).toEntity();
      expect(entity.level, JobLevel.senior);
      expect(entity.recruiterId, '');
      expect(entity.source, 'remotive');
      expect(entity.isExternal, true);
      expect(entity.formattedSalary, '\$2,000–3,000');
    });

    test('level lạ không crash, 6 level có nhãn tiếng Việt', () {
      expect(JobLevel.fromString('principal'), JobLevel.intern);
      expect(JobLevel.values.map((e) => e.label).toList(),
          ['Thực tập', 'Fresher', 'Junior', 'Mid', 'Senior', 'Lead']);
      expect(JobLevel.fromString('LEAD'), JobLevel.lead);
    });
  });

  group('Nhãn hiển thị', () {
    test('sourceLabel: ưu tiên host của link, sau đó theo source', () {
      expect(sourceLabel('jsearch', 'https://www.linkedin.com/jobs/1'), 'LinkedIn');
      expect(sourceLabel('serpapi', 'https://topcv.vn/x'), 'TopCV');
      expect(sourceLabel('jsearch', 'https://abc.com/x'), 'Google Jobs');
      expect(sourceLabel('remotive', null), 'Remotive');
      expect(sourceLabel('internal', null), 'Atom');
    });

    test('salaryLabel theo đơn vị tiền', () {
      expect(salaryLabel(15000000, 25000000, 'VND'), '15–25 triệu');
      expect(salaryLabel(12500000, null, 'VND'), 'Từ 12.5 triệu');
      expect(salaryLabel(2000, 3000, 'USD'), '\$2,000–3,000');
      expect(salaryLabel(500, 800, null), '\$500–800');
      expect(salaryLabel(null, null, 'USD'), 'Thỏa thuận');
    });
  });

  group('JobApplyButton', () {
    testWidgets('job có applyUrl: ghi tên nguồn và mở link, không gọi API nội bộ', (t) async {
      final ds = _FakeApplicationDataSource();
      final opened = await _pumpButton(
          t, _job(applyUrl: 'https://www.linkedin.com/jobs/1', source: 'jsearch'), ds);
      expect(find.text('Ứng tuyển trên LinkedIn'), findsOneWidget);
      await t.tap(find.byType(ElevatedButton));
      await t.pump();
      expect(opened, ['https://www.linkedin.com/jobs/1']);
      expect(ds.applyCalls, 0);
    });

    testWidgets('job nội bộ: gọi apply; server trả EXTERNAL_JOB_APPLY thì mở link trong lỗi',
        (t) async {
      final ds = _FakeApplicationDataSource(externalUrl: 'https://remotive.com/job/9');
      final opened = await _pumpButton(t, _job(), ds);
      expect(find.text('Ứng tuyển ngay'), findsOneWidget);
      await t.tap(find.byType(ElevatedButton));
      await t.pumpAndSettle();
      expect(ds.applyCalls, 1);
      expect(opened, ['https://remotive.com/job/9']);
    });
  });
}
