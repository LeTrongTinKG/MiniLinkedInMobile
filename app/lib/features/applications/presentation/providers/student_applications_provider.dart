import 'package:flutter/foundation.dart';
import 'package:app/core/error/app_exception.dart';
import '../../data/application_remote_datasource.dart';
import '../../domain/entities/application_entity.dart';

/// Đơn ứng tuyển của sinh viên: nộp đơn, theo dõi trạng thái, rút đơn
class StudentApplicationsProvider extends ChangeNotifier {
  StudentApplicationsProvider(this._dataSource);

  final ApplicationRemoteDataSource _dataSource;

  List<ApplicationEntity> _applications = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Link gốc khi lần apply gần nhất bị server từ chối vì job nguồn ngoài
  String? lastExternalApplyUrl;

  List<ApplicationEntity> get applications => _applications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Đơn còn hiệu lực của job này (đơn đã rút không tính để có thể nộp lại)
  ApplicationEntity? activeApplicationFor(String jobId) {
    for (final app in _applications) {
      if (app.jobId == jobId && !app.status.isClosed) return app;
    }
    return null;
  }

  bool hasApplied(String jobId) => activeApplicationFor(jobId) != null;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _applications = await _dataSource.getMyApplications();
    } on AppException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Trả về null nếu thành công, ngược lại là thông báo lỗi để hiện cho người dùng
  Future<String?> apply(String jobId) async {
    lastExternalApplyUrl = null;
    try {
      await _dataSource.apply(jobId);
      await load();
      return null;
    } on AppException catch (e) {
      if (e is ApiException && e.errorCode == 'ALREADY_APPLIED') await load();
      if (e is ApiException && e.errorCode == 'EXTERNAL_JOB_APPLY') {
        lastExternalApplyUrl = e.applyUrl;
      }
      return e.message;
    }
  }

  Future<String?> withdraw(String id) async {
    try {
      await _dataSource.withdraw(id);
      _applications = [
        for (final a in _applications)
          a.id == id ? a.copyWith(status: ApplicationStatus.withdrawn) : a,
      ];
      notifyListeners();
      return null;
    } on AppException catch (e) {
      return e.message;
    }
  }
}
