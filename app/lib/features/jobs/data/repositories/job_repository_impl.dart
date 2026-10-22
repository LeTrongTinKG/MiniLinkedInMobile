import '../../domain/entities/job_entity.dart';
import '../../domain/entities/job_filter.dart';
import '../../domain/repositories/job_repository.dart';
import '../datasources/job_datasource.dart';

/// Cài đặt JobRepository tuân thủ DIP & OCP với cơ chế Smart Fallback
class JobRepositoryImpl implements JobRepository {
  final JobDataSource _remoteDataSource;
  final JobDataSource? _mockDataSource;

  bool _isUsingMockData = false;

  /// Constructor linh hoạt: hỗ trợ nhận dataSource đơn lẻ hoặc cả cặp (remote + mock fallback)
  JobRepositoryImpl(
    JobDataSource remoteDataSource, [
    JobDataSource? mockDataSource,
  ])  : _remoteDataSource = remoteDataSource,
        _mockDataSource = mockDataSource;

  @override
  bool get isUsingMockData => _isUsingMockData;

  @override
  Future<List<JobEntity>> getJobs({JobFilter? filter}) async {
    final mock = _mockDataSource;
    try {
      final models = await _remoteDataSource.getJobs(filter: filter);

      // Nếu Remote API trả về có kết quả hoặc không có mock fallback, dùng dữ liệu thật
      if (models.isNotEmpty || mock == null) {
        _isUsingMockData = false;
        return models.map((m) => m.toEntity()).toList();
      }
    } catch (_) {
      // Nếu không có mock fallback dự phòng thì ném tiếp ngoại lệ
      if (mock == null) rethrow;
    }

    // Smart Fallback: Rơi về MockDataSource khi server rỗng hoặc lỗi kết nối / cold start
    _isUsingMockData = true;
    final fallbackModels = await mock.getJobs(filter: filter);
    return fallbackModels.map((m) => m.toEntity()).toList();
  }

  @override
  Future<JobEntity?> getJobById(String id) async {
    final mock = _mockDataSource;
    try {
      final model = await _remoteDataSource.getJobById(id);
      if (model != null) {
        return model.toEntity();
      }
    } catch (_) {
      if (mock == null) rethrow;
    }

    if (mock != null) {
      final fallback = await mock.getJobById(id);
      return fallback?.toEntity();
    }

    return null;
  }

  @override
  Future<List<String>> getAvailableSkills() async {
    final mock = _mockDataSource;
    try {
      final remoteSkills = await _remoteDataSource.getAvailableSkills();
      if (mock != null) {
        final mockSkills = await mock.getAvailableSkills();
        final combined = <String>{...remoteSkills, ...mockSkills};
        final sorted = combined.toList()..sort();
        return sorted;
      }
      return remoteSkills;
    } catch (_) {
      if (mock != null) {
        return mock.getAvailableSkills();
      }
      rethrow;
    }
  }
}
