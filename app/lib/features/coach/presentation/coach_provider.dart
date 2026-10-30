import 'package:flutter/foundation.dart';
import '../../../core/error/app_exception.dart';
import '../data/coach_models.dart';
import '../data/coach_remote_datasource.dart';

class CoachProvider extends ChangeNotifier {
  final CoachRemoteDataSource _source;
  CoachProvider(this._source);

  CoachSettings? settings;
  CoachAnswer? lastAnswer;
  String? errorMessage;
  bool loading = false;
  bool asking = false;

  Future<void> load() async {
    loading = true;
    errorMessage = null;
    notifyListeners();
    try {
      settings = await _source.getSettings();
    } on AppException catch (e) {
      errorMessage = e.message;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> enable({required String targetRole}) async {
    loading = true;
    errorMessage = null;
    notifyListeners();
    try {
      settings =
          await _source.saveSettings(consent: true, targetRole: targetRole);
      return true;
    } on AppException catch (e) {
      errorMessage = e.message;
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> ask({String? question, String? intent}) async {
    if (asking) return;
    asking = true;
    errorMessage = null;
    notifyListeners();
    try {
      lastAnswer = await _source.ask(question: question, intent: intent);
      if (settings != null) {
        settings = CoachSettings(
          consent: settings!.consent,
          targetRole: settings!.targetRole,
          roles: settings!.roles,
          remaining: lastAnswer!.remaining,
          limit: settings!.limit,
          resetsAt: settings!.resetsAt,
        );
      }
    } on AppException catch (e) {
      errorMessage = e.message;
    } finally {
      asking = false;
      notifyListeners();
    }
  }
}
