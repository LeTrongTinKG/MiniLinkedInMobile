import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
import 'features/jobs/data/datasources/job_mock_datasource.dart';
import 'features/jobs/data/datasources/job_remote_datasource.dart';
import 'features/jobs/data/repositories/job_repository_impl.dart';
import 'features/jobs/domain/usecases/job_usecases.dart';
import 'features/jobs/presentation/providers/job_provider.dart';

// CV Feature
import 'features/cv/data/datasources/cv_remote_datasource.dart';
import 'features/cv/data/repositories/cv_repository_impl.dart';
import 'features/cv/domain/usecases/cv_usecases.dart';
import 'features/cv/presentation/providers/cv_provider.dart';

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

  // 3. Jobs: GET /jobs trên Render. USE_MOCK=true thì dùng dữ liệu giả (test).
  const useMock = bool.fromEnvironment('USE_MOCK');
  final JobDataSource jobDataSource =
      useMock ? JobMockDataSource() : JobRemoteDataSource(dioClient.dio);
  final jobRepository = JobRepositoryImpl(
    jobDataSource,
    useMock ? null : JobMockDataSource(),
  );
  final getJobsUseCase = GetJobsUseCase(jobRepository);
  final getAvailableSkillsUseCase = GetAvailableSkillsUseCase(jobRepository);

  // 4. CV Feature
  final cvDataSource = CvRemoteDataSource(dioClient.dio);
  final cvRepository = CvRepositoryImpl(cvDataSource);
  final getCvsUseCase = GetCvsUseCase(cvRepository);
  final uploadCvUseCase = UploadCvUseCase(cvRepository);
  final setDefaultCvUseCase = SetDefaultCvUseCase(cvRepository);
  final deleteCvUseCase = DeleteCvUseCase(cvRepository);

  // 5. Interactions Feature (cảm xúc + bình luận)
  final InteractionDataSource interactionDataSource = useMock
      ? InteractionMockDataSource()
      : InteractionRemoteDataSource(dioClient.dio);
  final InteractionRepository interactionRepository =
      InteractionRepositoryImpl(interactionDataSource);

  runApp(
    MultiProvider(
      providers: [
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
    return MaterialApp(
      title: 'Mini LinkedIn',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
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
