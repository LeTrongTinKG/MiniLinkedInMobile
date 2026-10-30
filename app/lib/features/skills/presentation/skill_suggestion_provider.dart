import 'package:flutter/foundation.dart';
import '../../../core/error/app_exception.dart';
import '../data/skill_remote_datasource.dart';
import '../data/skill_suggestion.dart';

class SkillSuggestionProvider extends ChangeNotifier {
  final SkillRemoteDataSource _source;

  SkillSuggestionProvider(this._source);

  List<SkillSuggestion> _suggestions = [];
  bool _isBusy = false;
  bool _scanned = false;
  String? _errorMessage;

  List<SkillSuggestion> get suggestions => _suggestions;
  bool get isBusy => _isBusy;
  bool get scanned => _scanned;
  String? get errorMessage => _errorMessage;

  Future<void> load() => _run(() async {
        _suggestions = await _source.getSuggestions();
      });

  Future<void> scan() => _run(() async {
        _suggestions = await _source.scanGithub();
        _scanned = true;
      });

  Future<void> decide(String id, {required bool accept}) => _run(() async {
        await _source.decide(id, accept: accept);
        _suggestions = _suggestions.where((s) => s.id != id).toList();
      });

  Future<void> _run(Future<void> Function() work) async {
    _isBusy = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await work();
    } catch (e) {
      _errorMessage = e is AppException ? e.message : 'Đã có lỗi xảy ra';
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }
}
