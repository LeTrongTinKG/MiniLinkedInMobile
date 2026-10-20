import '../../domain/entities/job_entity.dart';
import '../../domain/entities/job_filter.dart';
import '../../domain/repositories/job_repository.dart';
import '../datasources/job_datasource.dart';

/// Cài đặt JobRepository tuân thủ DIP & OCP
class JobRepositoryImpl implements JobRepository {
  final JobDataSource _dataSource;

  const JobRepositoryImpl(this._dataSource);

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
  Future<List<String>> getAvailableSkills() {
    return _dataSource.getAvailableSkills();
  }
}

