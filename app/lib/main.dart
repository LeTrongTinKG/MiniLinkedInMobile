import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

// UI kit (lớp bọc shadcn_ui)
import 'ui_kit/app_shad_theme.dart';

// Core
import 'core/network/dio_client.dart';
import 'core/services/google_auth_service.dart';
import 'core/storage/preferences_storage.dart';
import 'core/storage/secure_storage.dart';
import 'core/theme/app_theme.dart';

// Auth Feature
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/auth_usecases.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';

// Jobs Feature
import 'features/jobs/data/datasources/job_datasource.dart';
import 'features/jobs/data/datasources/job_remote_datasource.dart';
import 'features/jobs/data/repositories/job_repository_impl.dart';
import 'features/jobs/domain/usecases/job_usecases.dart';
import 'features/jobs/presentation/providers/job_provider.dart';

// CV Feature
import 'features/cv/data/datasources/cv_remote_datasource.dart';
import 'features/cv/data/repositories/cv_repository_impl.dart';
import 'features/cv/domain/usecases/cv_usecases.dart';
import 'features/cv/presentation/providers/cv_provider.dart';

// Applications Feature (ứng tuyển, duyệt ứng viên, độ phù hợp)
import 'features/applications/data/application_remote_datasource.dart';
import 'features/applications/presentation/providers/student_applications_provider.dart';
import 'features/jobs/data/datasources/job_match_remote_datasource.dart';
import 'features/recruiter_home/recruiter_jobs_datasource.dart';

// Interactions Feature
import 'features/interactions/data/datasources/interaction_datasource.dart';
import 'features/interactions/data/datasources/interaction_mock_datasource.dart';
import 'features/interactions/data/datasources/interaction_remote_datasource.dart';
import 'features/interactions/data/repositories/interaction_repository_impl.dart';
import 'features/interactions/domain/repositories/interaction_repository.dart';
import 'features/interactions/presentation/providers/interaction_provider.dart';

// Home Features
import 'features/student_home/student_home_screen.dart';
import 'features/recruiter_home/recruiter_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Infrastructure
  final tokenStorage = SecureTokenStorage.defaultStorage();
  final preferencesStorage = AppPreferencesStorage.defaultStorage();
  final dioClient = DioClient.create(tokenStorage);
  final googleAuthService = GoogleAuthService();
  // KHÔNG `await`: trên web bước này phải tải script của Google từ mạng, chờ nó sẽ làm app
  // trắng màn hình lúc khởi động. Cứ chạy nền; chỗ nào cần Google (nút đăng nhập) sẽ tự chờ
  // đúng lần khởi tạo đó (initialize() dùng chung một lời hứa nên không bị gọi hai lần).
  unawaited(googleAuthService.initialize());

  // 2. Auth Feature
  final authDataSource = AuthRemoteDataSource(dioClient.dio);
  final authRepository = AuthRepositoryImpl(
    dataSource: authDataSource,
    tokenStorage: tokenStorage,
  );
  final loginUseCase = LoginUseCase(authRepository);
  final registerUseCase = RegisterUseCase(authRepository);
  final getMeUseCase = GetMeUseCase(authRepository);
  final googleLoginUseCase = GoogleLoginUseCase(authRepository);
  final logoutUseCase = LogoutUseCase(authRepository);

  // 3. Jobs: luôn lấy dữ liệu thật từ API GET /jobs.
  final JobDataSource jobDataSource = JobRemoteDataSource(dioClient.dio);
  final jobRepository = JobRepositoryImpl(jobDataSource);
  final getJobsUseCase = GetJobsUseCase(jobRepository);
  final getAvailableSkillsUseCase = GetAvailableSkillsUseCase(jobRepository);

  // 4. CV Feature
  final cvDataSource = CvRemoteDataSource(dioClient.dio);
  final cvRepository = CvRepositoryImpl(cvDataSource);
  final getCvsUseCase = GetCvsUseCase(cvRepository);
  final uploadCvUseCase = UploadCvUseCase(cvRepository);
  final setDefaultCvUseCase = SetDefaultCvUseCase(cvRepository);
  final deleteCvUseCase = DeleteCvUseCase(cvRepository);

  // 5. Interactions Feature (cảm xúc + bình luận). USE_MOCK=true thì dùng dữ liệu giả.
  const useMock = bool.fromEnvironment('USE_MOCK');
  final InteractionDataSource interactionDataSource = useMock
      ? InteractionMockDataSource()
      : InteractionRemoteDataSource(dioClient.dio);
  final InteractionRepository interactionRepository =
      InteractionRepositoryImpl(interactionDataSource);

  // 6. Applications Feature
  final applicationDataSource = ApplicationRemoteDataSource(dioClient.dio);

  runApp(
    MultiProvider(
      providers: [
        // Dio dùng chung (đã gắn sẵn token) cho module social tự dựng repository
        Provider<Dio>.value(value: dioClient.dio),
        Provider<ApplicationRemoteDataSource>.value(value: applicationDataSource),
        Provider<JobMatchRemoteDataSource>.value(
          value: JobMatchRemoteDataSource(dioClient.dio),
        ),
        Provider<RecruiterJobsDataSource>.value(
          value: RecruiterJobsDataSource(dioClient.dio),
        ),
        ChangeNotifierProvider(
          create: (_) => StudentApplicationsProvider(applicationDataSource),
        ),
        Provider<InteractionRepository>.value(value: interactionRepository),
        ChangeNotifierProvider(
          create: (_) => InteractionProvider(interactionRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            loginUseCase: loginUseCase,
            registerUseCase: registerUseCase,
            getMeUseCase: getMeUseCase,
            googleLoginUseCase: googleLoginUseCase,
            logoutUseCase: logoutUseCase,
            googleAuthService: googleAuthService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => JobProvider(
            getJobsUseCase: getJobsUseCase,
            getAvailableSkillsUseCase: getAvailableSkillsUseCase,
            preferences: preferencesStorage,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => CvProvider(
            getCvs: getCvsUseCase,
            uploadCv: uploadCvUseCase,
            setDefault: setDefaultCvUseCase,
            deleteCv: deleteCvUseCase,
          ),
        ),
      ],
      child: const MiniLinkedInApp(),
    ),
  );
}

class MiniLinkedInApp extends StatelessWidget {
  const MiniLinkedInApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ShadApp.custom: nạp theme của ui_kit (giống bọc <ThemeProvider> trong React).
    // MaterialApp bên trong vẫn dùng AppTheme.lightTheme nên màn hình cũ không đổi.
    return ShadApp.custom(
      theme: buildAppShadTheme(),
      appBuilder: (context) => MaterialApp(
        title: 'Mini LinkedIn',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        builder: (context, child) => ShadAppBuilder(child: child!),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/student-home': (context) => const StudentHomeScreen(),
          '/recruiter-home': (context) => const RecruiterHomeScreen(),
        },
      ),
    );
  }
}
