import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../../core/storage/preferences_storage.dart';
import '../../domain/entities/job_entity.dart';
import '../../domain/entities/job_filter.dart';
import '../../domain/usecases/job_usecases.dart';

/// Provider quản lý toàn bộ trạng thái màn hình danh sách công việc, tìm kiếm và lọc.
/// Hỗ trợ lưu trữ trạng thái bộ lọc bền vững (Persistence) qua IAppPreferences,
/// giúp giữ nguyên bộ lọc khi F5 / reload trang web.
class JobProvider extends ChangeNotifier {
  final GetJobsUseCase _getJobsUseCase;
  final GetAvailableSkillsUseCase _getAvailableSkillsUseCase;
  final IAppPreferences? _preferences;

  List<JobEntity> _jobs = [];
  bool _isLoading = false;
  String? _errorMessage;
  JobFilter _filter = const JobFilter();
  List<String> _availableSkills = [];

  JobProvider({
    required GetJobsUseCase getJobsUseCase,
    required GetAvailableSkillsUseCase getAvailableSkillsUseCase,
    IAppPreferences? preferences,
  })  : _getJobsUseCase = getJobsUseCase,
        _getAvailableSkillsUseCase = getAvailableSkillsUseCase,
        _preferences = preferences;

  // --- Getters ---
  List<JobEntity> get jobs => _jobs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  JobFilter get filter => _filter;
  List<String> get availableSkills => _availableSkills;
  bool get hasFilter => _filter.hasFilter;
  int get activeFilterCount => _filter.activeFilterCount;

  /// Khởi tạo và nạp dữ liệu ban đầu kèm khôi phục bộ lọc đã lưu (nếu có)
  Future<void> init() async {
    await _restoreFilter();
    await Future.wait([
      loadJobs(),
      loadAvailableSkills(),
    ]);
  }

  /// Khôi phục bộ lọc từ bộ nhớ lưu trữ
  Future<void> _restoreFilter() async {
    if (_preferences == null) return;
    try {
      final savedJsonStr = await _preferences.getJobFilterJson();
      if (savedJsonStr != null && savedJsonStr.isNotEmpty) {
        final Map<String, dynamic> jsonMap = jsonDecode(savedJsonStr);
        _filter = JobFilter.fromJson(jsonMap);
      }
    } catch (_) {
      // Nếu lỗi parse, giữ nguyên bộ lọc mặc định
    }
  }

  /// Lưu trạng thái bộ lọc hiện tại vào bộ nhớ lưu trữ
  Future<void> _persistFilter() async {
    if (_preferences == null) return;
    try {
      if (_filter.hasFilter) {
        final jsonStr = jsonEncode(_filter.toJson());
        await _preferences.saveJobFilterJson(jsonStr);
      } else {
        await _preferences.clearJobFilter();
      }
    } catch (_) {}
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
    _persistFilter();
    loadJobs();
  }

  /// Cập nhật hình thức làm việc nhanh
  void setWorkMode(WorkMode? mode) {
    if (_filter.workMode == mode) {
      _filter = _filter.copyWith(workMode: () => null);
    } else {
      _filter = _filter.copyWith(workMode: () => mode);
    }
    _persistFilter();
    loadJobs();
  }

  /// Cập nhật cấp bậc
  void setLevel(JobLevel? level) {
    if (_filter.level == level) {
      _filter = _filter.copyWith(level: () => null);
    } else {
      _filter = _filter.copyWith(level: () => level);
    }
    _persistFilter();
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
    _persistFilter();
    loadJobs();
  }

  /// Áp dụng bộ lọc mới từ Modal Bottom Sheet
  void applyFilter(JobFilter newFilter) {
    _filter = newFilter;
    _persistFilter();
    loadJobs();
  }

  /// Xóa toàn bộ bộ lọc về mặc định
  void resetFilter() {
    _filter = _filter.reset();
    _persistFilter();
    loadJobs();
  }
}
