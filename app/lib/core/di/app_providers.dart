import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../../features/applications/data/application_remote_datasource.dart';
import '../../features/applications/presentation/providers/student_applications_provider.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/consent/data/consent_remote_datasource.dart';
import '../../features/consent/presentation/viewmodels/consent_view_model.dart';
import '../../features/cv/presentation/providers/cv_provider.dart';
import '../../features/interactions/domain/repositories/interaction_repository.dart';
import '../../features/interactions/presentation/providers/interaction_provider.dart';
import '../../features/jobs/data/datasources/job_match_remote_datasource.dart';
import '../../features/jobs/presentation/providers/job_provider.dart';
import '../../features/news/data/datasources/news_remote_datasource.dart';
import '../../features/news/presentation/providers/news_provider.dart';
import '../../features/profile/data/profile_remote_datasource.dart';
import '../../features/profile/data/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/presentation/viewmodels/profile_edit_view_model.dart';
import '../../features/recruiter_home/recruiter_jobs_datasource.dart';
import '../../features/skills/data/skill_remote_datasource.dart';
import '../../features/skills/data/skill_repository_impl.dart';
import '../../features/skills/domain/repositories/skill_repository.dart';
import '../../features/skills/presentation/skill_suggestion_provider.dart';
import '../../features/skills/presentation/viewmodels/repo_upload_view_model.dart';
import '../../features/skills/presentation/viewmodels/skills_view_model.dart';
import '../localization/locale_view_model.dart';
import '../storage/preferences_storage.dart';

List<SingleChildWidget> buildAppProviders({
  required Dio dio,
  required ApplicationRemoteDataSource applicationDataSource,
  required InteractionRepository interactionRepository,
  required AuthProvider authProvider,
  required JobProvider jobProvider,
  required CvProvider cvProvider,
  required NewsRemoteDataSource newsDataSource,
  required IAppPreferences preferencesStorage,
}) {
  final skillRemoteDataSource = SkillRemoteDataSource(dio);
  final skillRepository = SkillRepositoryImpl(skillRemoteDataSource);
  final consentRemoteDataSource = ConsentRemoteDataSource(dio);
  final profileRemoteDataSource = ProfileRemoteDataSource(dio);
  final profileRepository = ProfileRepositoryImpl(profileRemoteDataSource);

  return [
    Provider<Dio>.value(value: dio),
    Provider<ApplicationRemoteDataSource>.value(value: applicationDataSource),
    Provider<JobMatchRemoteDataSource>.value(value: JobMatchRemoteDataSource(dio)),
    Provider<RecruiterJobsDataSource>.value(value: RecruiterJobsDataSource(dio)),
    Provider<SkillRemoteDataSource>.value(value: skillRemoteDataSource),
    Provider<SkillRepository>.value(value: skillRepository),
    Provider<ConsentRemoteDataSource>.value(value: consentRemoteDataSource),
    Provider<ProfileRemoteDataSource>.value(value: profileRemoteDataSource),
    Provider<ProfileRepository>.value(value: profileRepository),
    ChangeNotifierProvider.value(value: authProvider),
    ChangeNotifierProvider.value(value: jobProvider),
    ChangeNotifierProvider.value(value: cvProvider),
    ChangeNotifierProvider(create: (_) => NewsProvider(newsDataSource)),
    ChangeNotifierProvider(create: (_) => StudentApplicationsProvider(applicationDataSource)),
    Provider<InteractionRepository>.value(value: interactionRepository),
    ChangeNotifierProvider(create: (_) => InteractionProvider(interactionRepository)),
    ChangeNotifierProvider(create: (c) => SkillsViewModel(c.read<SkillRepository>())..load()),
    ChangeNotifierProvider(create: (c) => ConsentViewModel(c.read<ConsentRemoteDataSource>())..load()),
    ChangeNotifierProvider(create: (c) => RepoUploadViewModel(c.read<SkillRepository>())),
    ChangeNotifierProvider(create: (c) => SkillSuggestionProvider(c.read<SkillRemoteDataSource>())),
    ChangeNotifierProvider(create: (c) => ProfileEditViewModel(c.read<ProfileRepository>())),
    ChangeNotifierProvider(create: (_) => LocaleViewModel(preferencesStorage)..loadLocale()),
  ];
}
