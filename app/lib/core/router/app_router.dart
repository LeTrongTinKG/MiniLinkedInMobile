import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/consent/presentation/screens/analysis_consent_screen.dart';
import '../../features/recruiter_home/recruiter_home_screen.dart';
import '../../features/skills/presentation/screens/repo_upload_screen.dart';
import '../../features/skills/presentation/screens/skills_screen.dart';
import '../../features/student_home/student_home_screen.dart';
import 'routes.dart';

/// Cấu hình định tuyến GoRouter chuẩn mực cho toàn ứng dụng.
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: Routes.splash,
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: Routes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: Routes.studentHome,
        builder: (context, state) => const StudentHomeScreen(),
      ),
      GoRoute(
        path: Routes.recruiterHome,
        builder: (context, state) => const RecruiterHomeScreen(),
      ),
      GoRoute(
        path: Routes.skills,
        builder: (context, state) => const SkillsScreen(),
      ),
      GoRoute(
        path: Routes.analysisConsent,
        builder: (context, state) => const AnalysisConsentScreen(),
      ),
      GoRoute(
        path: Routes.repoEvidence,
        builder: (context, state) => const RepoUploadScreen(),
      ),
    ],
  );
}

