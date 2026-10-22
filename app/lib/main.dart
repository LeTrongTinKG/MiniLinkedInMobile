import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Core
import 'core/network/dio_client.dart';
import 'core/services/google_auth_service.dart';
import 'core/storage/preferences_storage.dart';
import 'core/storage/secure_storage.dart';
import 'core/theme/app_theme.dart';

// Auth Feature - Data Layer
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';

// Auth Feature - Domain Layer
import 'features/auth/domain/usecases/auth_usecases.dart';

// Auth Feature - Presentation Layer
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';

// Jobs Feature - Data & Domain Layers
import 'features/jobs/data/datasources/job_mock_datasource.dart';
import 'features/jobs/data/datasources/job_remote_datasource.dart';
import 'features/jobs/data/repositories/job_repository_impl.dart';
import 'features/jobs/domain/usecases/job_usecases.dart';
import 'features/jobs/presentation/providers/job_provider.dart';

// Home Features
import 'features/student_home/student_home_screen.dart';
import 'features/recruiter_home/recruiter_home_screen.dart';

void main() async {
  // Đảm bảo Flutter binding đã khởi tạo trước khi dùng plugin
  WidgetsFlutterBinding.ensureInitialized();

  // --- Khởi tạo Dependency Injection thủ công (Manual DI) ---

  // 1. Infrastructure
  final tokenStorage = SecureTokenStorage.defaultStorage();
  final preferencesStorage = AppPreferencesStorage.defaultStorage();
  final dioClient = DioClient.create(tokenStorage);
  final googleAuthService = GoogleAuthService();
  await googleAuthService.initialize();

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

  // 3. Jobs Feature: Nối JobRemoteDataSource với máy chủ Render, kèm JobMockDataSource làm fallback
  final jobRemoteDataSource = JobRemoteDataSource(dioClient.dio);
  final jobMockDataSource = JobMockDataSource();
  final jobRepository = JobRepositoryImpl(jobRemoteDataSource, jobMockDataSource);
  final getJobsUseCase = GetJobsUseCase(jobRepository);
  final getAvailableSkillsUseCase = GetAvailableSkillsUseCase(jobRepository);

  runApp(
    // 4. Cung cấp Providers cho toàn bộ widget tree
    MultiProvider(
      providers: [
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
      ],
      child: const MiniLinkedInApp(),
    ),
  );
}

class MiniLinkedInApp extends StatelessWidget {
  const MiniLinkedInApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini LinkedIn',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      // Màn hình khởi động: SplashScreen tự điều hướng
      initialRoute: '/',

      // Định nghĩa toàn bộ routes của ứng dụng
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/student-home': (context) => const StudentHomeScreen(),
        '/recruiter-home': (context) => const RecruiterHomeScreen(),
      },
    );
  }
}
