import '../../domain/entities/job_entity.dart';
import '../../domain/entities/job_filter.dart';
import '../../domain/repositories/job_repository.dart';
import '../datasources/job_datasource.dart';

/// Lấy dữ liệu job từ datasource (API thật) rồi đổi Model -> Entity.
class JobRepositoryImpl implements JobRepository {
  final JobDataSource _dataSource;

  JobRepositoryImpl(this._dataSource);

  @override
  Future<List<JobEntity>> getJobs({JobFilter? filter}) async {
    final models = await _dataSource.getJobs(filter: filter);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<JobEntity?> getJobById(String id) async {
    final model = await _dataSource.getJobById(id);
    return model?.toEntity();
  }

  @override
  Future<List<String>> getAvailableSkills() => _dataSource.getAvailableSkills();
}
