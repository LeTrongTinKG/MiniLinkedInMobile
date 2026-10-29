import '../entities/job_entity.dart';
import '../entities/job_filter.dart';

/// Interface hợp đồng dữ liệu cho công việc (DIP)
abstract interface class JobRepository {
  /// Lấy danh sách công việc theo bộ lọc
  Future<List<JobEntity>> getJobs({JobFilter? filter});

  /// Lấy chi tiết một công việc theo id
  Future<JobEntity?> getJobById(String id);

  /// Lấy danh sách toàn bộ các kỹ năng phổ biến để hiển thị bộ lọc
  Future<List<String>> getAvailableSkills();
}
