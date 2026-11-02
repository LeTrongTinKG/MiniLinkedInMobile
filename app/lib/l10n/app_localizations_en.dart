// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Mini LinkedIn';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get loading => 'Loading...';

  @override
  String get retry => 'Retry';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get success => 'Success';

  @override
  String get signIn => 'Sign In';

  @override
  String get signOut => 'Sign Out';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get loginTitle => 'Sign In to Mini LinkedIn';

  @override
  String get registerTitle => 'Register Account';

  @override
  String get profileTitle => 'Profile';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get fullName => 'Full Name';

  @override
  String get headline => 'Headline';

  @override
  String get location => 'Location';

  @override
  String get school => 'University / School';

  @override
  String get major => 'Major';

  @override
  String get about => 'About me';

  @override
  String get privateProfile => 'Private Profile (Default)';

  @override
  String get privateProfileDesc =>
      'Keep profile private by default. Recruiters require your approval to view details.';

  @override
  String get saveProfileSuccess => 'Profile updated successfully!';

  @override
  String get nameCannotBeEmpty => 'Full name cannot be empty';

  @override
  String get skillsTitle => 'Skills & Evidence';

  @override
  String get skillsSubTitle =>
      '3-tier confidence: Self-claimed, Evidenced, or Endorsed';

  @override
  String get addSkill => 'Add Skill';

  @override
  String get skillNameHint => 'Enter skill name (e.g. Flutter, Go)';

  @override
  String get confidenceSelfClaimed => 'Self-claimed';

  @override
  String get confidenceEvidenced => 'Evidenced';

  @override
  String get confidenceEndorsed => 'Endorsed';

  @override
  String get repoUploadTitle => 'Upload GitHub Repo Evidence';

  @override
  String get repoUploadDesc =>
      'Link your GitHub repository as proof of technical ability instead of a standard CV.';

  @override
  String get githubRepoUrl => 'GitHub Repository URL';

  @override
  String get scanRepoButton => 'Extract Skills & Link Evidence';

  @override
  String get consentTitle => 'Automated Analysis Consent';

  @override
  String get consentDesc =>
      'We value your privacy. Review transparently what data is read vs never read.';

  @override
  String get agreeButton => 'I Agree';

  @override
  String get withdrawButton => 'Withdraw Consent';

  @override
  String get language => 'Language';

  @override
  String get vietnamese => 'Vietnamese';

  @override
  String get english => 'English';

  @override
  String get switchLanguage => 'Switch Language';
}
