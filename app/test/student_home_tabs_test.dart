import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:app/ui_kit/app_shad_theme.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:app/core/services/google_auth_service.dart';
import 'package:app/features/auth/domain/repositories/auth_repository.dart';
import 'package:app/features/auth/domain/usecases/auth_usecases.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:app/features/jobs/domain/entities/job_entity.dart';
import 'package:app/features/jobs/domain/entities/job_filter.dart';
import 'package:app/features/jobs/domain/repositories/job_repository.dart';
import 'package:app/features/jobs/domain/usecases/job_usecases.dart';
import 'package:app/features/jobs/presentation/providers/job_provider.dart';
import 'package:app/features/jobs/presentation/screens/job_list_screen.dart';
import 'package:app/features/news/data/datasources/news_remote_datasource.dart';
import 'package:app/features/news/data/models/news_article_model.dart';
import 'package:app/features/news/presentation/providers/news_provider.dart';
import 'package:app/features/news/presentation/screens/news_page.dart';
import 'package:app/features/social/social_page.dart';
import 'package:app/features/student_home/student_home_screen.dart';
import 'package:app/features/student_home/widgets/app_header.dart';
import 'package:app/features/student_home/widgets/student_bottom_bar.dart';

// --- Đồ giả (fake) để dựng màn hình mà không cần server thật ---

// Kho job giả: luôn trả về danh sách rỗng.
class _FakeJobRepo implements JobRepository {
  @override
  Future<List<JobEntity>> getJobs({JobFilter? filter}) async => [];
  @override
  Future<JobEntity?> getJobById(String id) async => null;
  @override
  Future<List<String>> getAvailableSkills() async => [];
}

// Kho auth giả: test không đăng nhập nên không method nào được gọi.
class _FakeAuthRepo implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeGoogle implements IGoogleAuthService {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeNewsDataSource extends NewsRemoteDataSource {
  _FakeNewsDataSource() : super(Dio());
  @override
  Future<List<NewsArticleModel>> getNews({
    String? lang,
    String? category,
    String? query,
    int page = 1,
    int limit = 30,
  }) async => [];
}

// Dựng StudentHomeScreen thật, bọc trong các Provider (giống Context của React).
Widget _buildHome() {
  final jobRepo = _FakeJobRepo();
  final authRepo = _FakeAuthRepo();
  return MultiProvider(
    providers: [
      Provider<Dio>.value(value: Dio()), // tab Mạng xã hội cần Dio
      ChangeNotifierProvider(
        create: (_) => AuthProvider(
          loginUseCase: LoginUseCase(authRepo),
          registerUseCase: RegisterUseCase(authRepo),
          getMeUseCase: GetMeUseCase(authRepo),
          googleLoginUseCase: GoogleLoginUseCase(authRepo),
          logoutUseCase: LogoutUseCase(authRepo),
          googleAuthService: _FakeGoogle(),
        ),
      ),
      ChangeNotifierProvider(
        create: (_) => JobProvider(
          getJobsUseCase: GetJobsUseCase(jobRepo),
          getAvailableSkillsUseCase: GetAvailableSkillsUseCase(jobRepo),
        ),
      ),
      ChangeNotifierProvider(
        create: (_) => NewsProvider(_FakeNewsDataSource()),
      ),
    ],
    // Gốc app giống main.dart (ShadApp bọc MaterialApp) vì tab Mạng xã hội dùng ui_kit
    child: ShadApp.custom(
      theme: buildAppShadTheme(),
      appBuilder: (context) => MaterialApp(
        builder: (context, child) => ShadAppBuilder(child: child!),
        home: const StudentHomeScreen(),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Bộ nhớ an toàn (lưu tab đã chọn) cần plugin thật -> giả lập: không có gì được lưu.
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (call) async => null,
    );
  });

  Future<void> openHome(WidgetTester tester) async {
    await tester.pumpWidget(_buildHome());
    await tester.pump(const Duration(milliseconds: 100));
  }

  // Bấm nút có nhãn [label] ở thanh dưới.
  Future<void> tapBar(WidgetTester tester, String label) async {
    await tester.tap(find.descendant(
        of: find.byType(StudentBottomBar), matching: find.text(label)));
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('(a) thanh dưới có đúng 3 nút với đúng nhãn', (tester) async {
    await openHome(tester);
    final bar = find.byType(StudentBottomBar);
    expect(find.descendant(of: bar, matching: find.byType(NavigationDestination)),
        findsNWidgets(3));
    for (final label in ['Việc làm', 'Mạng xã hội', 'Tin tức']) {
      expect(find.descendant(of: bar, matching: find.text(label)), findsOneWidget);
    }
  });

  testWidgets('(b) bấm từng nút thì hiện đúng trang', (tester) async {
    await openHome(tester);
    // Mở app: tab đầu tiên là Việc làm.
    expect(find.byType(JobListScreen), findsOneWidget);
    expect(find.byType(SocialPage), findsNothing);

    await tapBar(tester, 'Mạng xã hội');
    expect(find.byType(SocialPage), findsOneWidget);
    expect(find.byType(JobListScreen), findsNothing);

    await tapBar(tester, 'Tin tức');
    expect(find.byType(NewsPage), findsOneWidget);
    expect(find.byType(SocialPage), findsNothing);

    await tapBar(tester, 'Việc làm');
    expect(find.byType(JobListScreen), findsOneWidget);
  });

  testWidgets('(c) thanh dưới vẫn hiện ở cả 3 tab (cố định)', (tester) async {
    await openHome(tester);
    for (final label in ['Việc làm', 'Mạng xã hội', 'Tin tức']) {
      await tapBar(tester, label);
      expect(find.byType(StudentBottomBar), findsOneWidget);
    }
  });

  testWidgets('(d) trang Tin tức hiện giao diện tin tức (NewsPage)',
      (tester) async {
    await openHome(tester);
    await tapBar(tester, 'Tin tức');
    expect(find.byType(NewsPage), findsOneWidget);
  });

  testWidgets('(e) header chung hiện ở cả 3 tab, tiêu đề đổi theo tab',
      (tester) async {
    await openHome(tester);
    for (final label in ['Việc làm', 'Mạng xã hội', 'Tin tức']) {
      await tapBar(tester, label);
      expect(find.byType(AppHeader), findsOneWidget);
      // Tiêu đề trong header khớp với tab đang chọn.
      expect(find.descendant(of: find.byType(AppHeader), matching: find.text(label)),
          findsOneWidget);
    }
  });

  testWidgets('(f) tab đã lưu ngoài 0..2 (vd 5) bị bỏ qua, mở tab Việc làm',
      (tester) async {
    // Giả lập bộ nhớ trả về "5" khi đọc tab đã lưu.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (call) async => call.method == 'read' ? '5' : null,
    );
    await openHome(tester);
    expect(find.byType(JobListScreen), findsOneWidget);
  });

  testWidgets('(g) bấm nút menu ở header thì mở Drawer (Đã ứng tuyển, Hồ sơ & CV, Đăng xuất)',
      (tester) async {
    await openHome(tester);
    expect(find.text('Hồ sơ & CV'), findsNothing); // Drawer chưa mở

    await tester.tap(find.byIcon(Icons.menu_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Đã ứng tuyển'), findsOneWidget);
    expect(find.text('Hồ sơ & CV'), findsOneWidget);
    expect(find.text('Đăng xuất'), findsOneWidget);
  });

  testWidgets('(h) tab Tin tức dùng header chung, KHÔNG có AppBar riêng (không bị hai thanh tiêu đề)',
      (tester) async {
    await openHome(tester);
    await tapBar(tester, 'Tin tức');
    expect(find.byType(AppHeader), findsOneWidget); // header chung của khung chính
    expect(find.byType(AppBar), findsNothing); // trang tin tức không tự vẽ thêm AppBar
  });
}
