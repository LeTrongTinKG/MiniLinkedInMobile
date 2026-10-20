import '../entities/job_entity.dart';
import '../entities/job_filter.dart';
import '../repositories/job_repository.dart';

/// UseCase: Lấy danh sách công việc theo bộ lọc (Single Responsibility Principle)
class GetJobsUseCase {
  final JobRepository _repository;

  const GetJobsUseCase(this._repository);

  Future<List<JobEntity>> call({JobFilter? filter}) {
    return _repository.getJobs(filter: filter);
  }
}

/// UseCase: Lấy chi tiết công việc
class GetJobByIdUseCase {
  final JobRepository _repository;

  const GetJobByIdUseCase(this._repository);

  Future<JobEntity?> call(String id) {
    return _repository.getJobById(id);
  }
}

/// UseCase: Lấy danh sách kỹ năng có sẵn phục vụ chọn lọc
class GetAvailableSkillsUseCase {
  final JobRepository _repository;

  const GetAvailableSkillsUseCase(this._repository);

  Future<List<String>> call() {
    return _repository.getAvailableSkills();
  }
}

