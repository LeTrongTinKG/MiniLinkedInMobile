import 'package:flutter/foundation.dart';
import '../../domain/entities/job_entity.dart';
import '../../domain/entities/job_filter.dart';
import '../../domain/usecases/job_usecases.dart';

/// Provider quản lý toàn bộ trạng thái màn hình danh sách công việc, tìm kiếm và lọc
class JobProvider extends ChangeNotifier {
  final GetJobsUseCase _getJobsUseCase;
  final GetAvailableSkillsUseCase _getAvailableSkillsUseCase;

  List<JobEntity> _jobs = [];
  bool _isLoading = false;
  String? _errorMessage;
  JobFilter _filter = const JobFilter();
  List<String> _availableSkills = [];

  JobProvider({
    required GetJobsUseCase getJobsUseCase,
    required GetAvailableSkillsUseCase getAvailableSkillsUseCase,
  })  : _getJobsUseCase = getJobsUseCase,
        _getAvailableSkillsUseCase = getAvailableSkillsUseCase;

  // --- Getters ---
  List<JobEntity> get jobs => _jobs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  JobFilter get filter => _filter;
  List<String> get availableSkills => _availableSkills;
  bool get hasFilter => _filter.hasFilter;
  int get activeFilterCount => _filter.activeFilterCount;

  /// Khởi tạo và nạp dữ liệu ban đầu
  Future<void> init() async {
    await Future.wait([
      loadJobs(),
      loadAvailableSkills(),
    ]);
  }

  /// Nạp danh sách công việc theo bộ lọc hiện tại
  Future<void> loadJobs() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _jobs = await _getJobsUseCase(filter: _filter);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Không thể tải danh sách công việc. Vui lòng thử lại.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Nạp danh sách các kỹ năng để phục vụ bộ lọc
  Future<void> loadAvailableSkills() async {
    try {
      _availableSkills = await _getAvailableSkillsUseCase();
      notifyListeners();
    } catch (_) {}
  }

  /// Cập nhật từ khóa tìm kiếm
  void search(String keyword) {
    if (_filter.keyword == keyword) return;
    _filter = _filter.copyWith(keyword: keyword);
    loadJobs();
  }

  /// Cập nhật hình thức làm việc nhanh
  void setWorkMode(WorkMode? mode) {
    if (_filter.workMode == mode) {
      _filter = _filter.copyWith(workMode: () => null);
    } else {
      _filter = _filter.copyWith(workMode: () => mode);
    }
    loadJobs();
  }

  /// Cập nhật cấp bậc
  void setLevel(JobLevel? level) {
    if (_filter.level == level) {
      _filter = _filter.copyWith(level: () => null);
    } else {
      _filter = _filter.copyWith(level: () => level);
    }
    loadJobs();
  }

  /// Bật/tắt kỹ năng trong bộ lọc
  void toggleSkill(String skill) {
    final updatedSkills = Set<String>.from(_filter.selectedSkills);
    if (updatedSkills.contains(skill)) {
      updatedSkills.remove(skill);
    } else {
      updatedSkills.add(skill);
    }
    _filter = _filter.copyWith(selectedSkills: updatedSkills);
    loadJobs();
  }

  /// Áp dụng bộ lọc mới từ Modal Bottom Sheet
  void applyFilter(JobFilter newFilter) {
    _filter = newFilter;
    loadJobs();
  }

  /// Xóa toàn bộ bộ lọc về mặc định
  void resetFilter() {
    _filter = _filter.reset();
    loadJobs();
  }
}

