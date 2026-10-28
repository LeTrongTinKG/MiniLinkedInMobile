import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:app/features/interactions/data/datasources/interaction_mock_datasource.dart';
import 'package:app/features/interactions/data/repositories/interaction_repository_impl.dart';
import 'package:app/features/interactions/domain/repositories/interaction_repository.dart';
import 'package:app/features/interactions/presentation/providers/interaction_provider.dart';
import 'package:app/features/jobs/data/models/job_model.dart';
import 'package:app/features/jobs/domain/entities/job_entity.dart';
import 'package:app/features/jobs/presentation/widgets/job_card.dart';
import 'package:app/features/student_home/student_nav.dart';

// Tạo 3 job giả ngay trong test (không cần datasource mock).
List<JobEntity> _fakeJobs() => [
      for (var i = 0; i < 3; i++)
        JobModel.fromJson({
          'id': 'job-$i',
          'recruiterId': 'rec-1',
          'title': 'Flutter Developer $i',
          'companyName': 'Công ty $i',
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
        }).toEntity(),
    ];

Widget _host(Widget child) {
  final InteractionRepository repo = InteractionRepositoryImpl(InteractionMockDataSource());
  return MultiProvider(
    providers: [
      Provider<InteractionRepository>.value(value: repo),
      ChangeNotifierProvider(create: (_) => InteractionProvider(repo)),
    ],
    child: MaterialApp(home: Scaffold(body: Padding(padding: const EdgeInsets.all(16), child: child))),
  );
}

void main() {
  testWidgets('3 card kiểu bài đăng cạnh nhau (web 1200px) không overflow, cùng chiều cao', (t) async {
    t.view.physicalSize = const Size(1200, 800);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final jobs = _fakeJobs();
    await t.pumpWidget(_host(IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < 3; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            Expanded(child: JobCard(job: jobs[i])),
          ],
        ],
      ),
    )));
    await t.pump(const Duration(milliseconds: 600));
    expect(t.takeException(), isNull);
    expect(find.text('Thích'), findsNWidgets(3));
    expect(find.text('Bình luận'), findsNWidgets(3));
    expect(find.text('Chia sẻ'), findsNWidgets(3));
    final h = find.byType(JobCard).evaluate().map((e) => e.size!.height).toSet();
    expect(h.length, 1, reason: 'các card cùng hàng phải cao bằng nhau: $h');
  });

  testWidgets('mobile 360px: card 1 cột không overflow', (t) async {
    t.view.physicalSize = const Size(360, 800);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final jobs = _fakeJobs();
    await t.pumpWidget(_host(IntrinsicHeight(child: JobCard(job: jobs[0]))));
    await t.pump(const Duration(milliseconds: 600));
    expect(t.takeException(), isNull);
  });

  testWidgets('hamburger mở drawer', (t) async {
    await t.pumpWidget(MaterialApp(
      home: Scaffold(
        key: studentScaffoldKey,
        drawer: const Drawer(child: Text('DRAWER_OPEN')),
        body: const StudentMenuButton(),
      ),
    ));
    await t.tap(find.byTooltip('Menu'));
    await t.pumpAndSettle();
    expect(find.text('DRAWER_OPEN'), findsOneWidget);
  });
}
