import 'package:flutter/foundation.dart';
import 'package:app/core/error/app_exception.dart';
import '../../data/application_remote_datasource.dart';
import '../../domain/entities/application_entity.dart';

/// Ứng viên của nhà tuyển dụng, server đã xếp sẵn theo điểm match giảm dần
class RecruiterApplicationsProvider extends ChangeNotifier {
  RecruiterApplicationsProvider(this._dataSource);

  final ApplicationRemoteDataSource _dataSource;

  List<ApplicationEntity> _applications = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _jobId;

  List<ApplicationEntity> get applications => _applications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// [jobId] null = ứng viên của tất cả job
  Future<void> load({String? jobId}) async {
    _jobId = jobId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _applications = await _dataSource.getRecruiterApplications(jobId: _jobId);
    } on AppException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Trả về null nếu thành công, ngược lại là thông báo lỗi
  Future<String?> setStatus(String id, ApplicationStatus status) async {
    try {
      await _dataSource.updateStatus(id, status);
      _applications = [
        for (final a in _applications) a.id == id ? a.copyWith(status: status) : a,
      ];
      notifyListeners();
      return null;
    } on AppException catch (e) {
      return e.message;
    }
  }
}
