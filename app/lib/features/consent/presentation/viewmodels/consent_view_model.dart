import 'package:flutter/foundation.dart';
import '../../../../core/error/app_failure.dart';
import '../../data/consent_remote_datasource.dart';

/// ViewModel quản lý sự đồng ý phân tích AI/quy tắc (F-006, Ticket 14).
class ConsentViewModel extends ChangeNotifier {
  final ConsentRemoteDataSource _dataSource;

  ConsentViewModel(this._dataSource);

  bool? _granted;
  bool _busy = false;
  AppFailure? _failure;

  bool? get granted => _granted;
  bool get busy => _busy;
  AppFailure? get failure => _failure;

  Future<void> load() async {
    _busy = true;
    _failure = null;
    notifyListeners();

    try {
      _granted = await _dataSource.getConsentStatus();
    } catch (e) {
      _failure = ServerFailure(e.toString());
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<bool> choose(bool agreed) async {
    _busy = true;
    _failure = null;
    notifyListeners();

    try {
      await _dataSource.updateConsent(agreed);
      _granted = agreed;
      _busy = false;
      notifyListeners();
      return true;
    } catch (e) {
      _failure = ServerFailure(e.toString());
      _busy = false;
      notifyListeners();
      return false;
    }
  }
}

