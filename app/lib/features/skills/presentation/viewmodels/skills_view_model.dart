import 'package:flutter/foundation.dart';
import '../../../../core/common/result.dart';
import '../../../../core/error/app_failure.dart';
import '../../data/skill_suggestion.dart';
import '../../domain/models/skill_item.dart';
import '../../domain/repositories/skill_repository.dart';

/// ViewModel quản lý màn hình Kỹ năng theo mô hình MVVM chuẩn Atom.
class SkillsViewModel extends ChangeNotifier {
  final SkillRepository _repository;

  SkillsViewModel(this._repository);

  List<SkillItem> _skills = [];
  List<SkillSuggestion> _suggestions = [];
  bool _loading = false;
  bool _saving = false;
  AppFailure? _failure;

  List<SkillItem> get skills => _skills;
  List<SkillSuggestion> get suggestions => _suggestions;
  bool get loading => _loading;
  bool get saving => _saving;
  AppFailure? get failure => _failure;

  Future<void> load() async {
    _loading = true;
    _failure = null;
    notifyListeners();

    final result = await _repository.getMySkills();
    final suggResult = await _repository.getSuggestions();

    _loading = false;
    switch (result) {
      case Ok(:final value):
        _skills = value;
      case Error(:final failure):
        _failure = failure;
    }
    if (suggResult is Ok<List<SkillSuggestion>>) {
      _suggestions = suggResult.value;
    }
    notifyListeners();
  }

  Future<bool> addSkill(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      _failure = const ValidationFailure('EMPTY_NAME', 'Tên kỹ năng không được để trống');
      notifyListeners();
      return false;
    }

    _saving = true;
    _failure = null;
    notifyListeners();

    final result = await _repository.addSelfClaimed(trimmed);
    _saving = false;

    switch (result) {
      case Ok(:final value):
        _skills = [..._skills, value];
        notifyListeners();
        return true;
      case Error(:final failure):
        _failure = failure;
        notifyListeners();
        return false;
    }
  }

  Future<void> delete(SkillItem item) async {
    _saving = true;
    notifyListeners();

    final result = await _repository.deleteSkill(item.name);
    _saving = false;

    if (result is Ok) {
      _skills = _skills.where((s) => s.id != item.id && s.name != item.name).toList();
    } else if (result is Error) {
      _failure = result.failure;
    }
    notifyListeners();
  }

  Future<void> decideSuggestion(String id, {required bool accept}) async {
    _saving = true;
    notifyListeners();

    final result = await _repository.decideSuggestion(id, accept: accept);
    _saving = false;

    if (result is Ok) {
      _suggestions = _suggestions.where((s) => s.id != id).toList();
      await load();
    } else if (result is Error) {
      _failure = result.failure;
      notifyListeners();
    }
  }
}

