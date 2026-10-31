import 'package:flutter/foundation.dart';
import '../../../../core/common/result.dart';
import '../../../../core/error/app_failure.dart';
import '../../data/skill_suggestion.dart';
import '../../domain/repositories/skill_repository.dart';

/// ViewModel xử lý nghiệp vụ Up Repo thay vì CV theo chuẩn MVVM.
class RepoUploadViewModel extends ChangeNotifier {
  final SkillRepository _repository;

  RepoUploadViewModel(this._repository);

  String _repoUrl = '';
  bool _scanning = false;
  AppFailure? _failure;
  List<SkillSuggestion> _suggestions = [];

  String get repoUrl => _repoUrl;
  bool get scanning => _scanning;
  AppFailure? get failure => _failure;
  List<SkillSuggestion> get suggestions => _suggestions;

  void setRepoUrl(String value) {
    _repoUrl = value;
    _failure = null;
    notifyListeners();
  }

  bool _isValidGithubUrl(String url) {
    final pattern = RegExp(
      r'^(https?:\/\/)?(www\.)?github\.com\/[a-zA-Z0-9_.-]+\/[a-zA-Z0-9_.-]+(\/)?$',
    );
    final shortPattern = RegExp(r'^[a-zA-Z0-9_.-]+\/[a-zA-Z0-9_.-]+$');
    return pattern.hasMatch(url.trim()) || shortPattern.hasMatch(url.trim());
  }

  Future<bool> scanRepo({required bool hasConsent}) async {
    final trimmed = _repoUrl.trim();
    if (trimmed.isEmpty) {
      _failure = const ValidationFailure('EMPTY_URL', 'Vui lòng nhập đường dẫn GitHub repo');
      notifyListeners();
      return false;
    }

    if (!_isValidGithubUrl(trimmed)) {
      _failure = const ValidationFailure(
        'INVALID_FORMAT',
        'Định dạng repo không đúng (ví dụ: owner/repo hoặc https://github.com/owner/repo)',
      );
      notifyListeners();
      return false;
    }

    if (!hasConsent) {
      _failure = const ConsentRequiredFailure();
      notifyListeners();
      return false;
    }

    _scanning = true;
    _failure = null;
    notifyListeners();

    final result = await _repository.scanCustomRepo(trimmed);
    _scanning = false;

    switch (result) {
      case Ok(:final value):
        _suggestions = value;
        notifyListeners();
        return true;
      case Error(:final failure):
        _failure = failure;
        notifyListeners();
        return false;
    }
  }

  Future<void> decide(String id, {required bool accept}) async {
    final result = await _repository.decideSuggestion(id, accept: accept);
    if (result is Ok) {
      _suggestions = _suggestions.where((s) => s.id != id).toList();
      notifyListeners();
    }
  }
}

