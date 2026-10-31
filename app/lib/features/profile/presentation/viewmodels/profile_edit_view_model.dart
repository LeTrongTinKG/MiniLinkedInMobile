import 'package:flutter/foundation.dart';
import '../../../../core/common/result.dart';
import '../../../../core/error/app_failure.dart';
import '../../domain/models/profile_data.dart';
import '../../domain/repositories/profile_repository.dart';

/// ViewModel chỉnh sửa hồ sơ cá nhân với chế độ Riêng tư mặc định (Ticket 02, F-002).
class ProfileEditViewModel extends ChangeNotifier {
  final ProfileRepository _repository;

  ProfileEditViewModel(this._repository);

  ProfileData _profile = const ProfileData(fullName: '', isPrivate: true);
  final bool _loading = false;
  bool _saving = false;
  bool _saved = false;
  AppFailure? _failure;

  ProfileData get profile => _profile;
  bool get loading => _loading;
  bool get saving => _saving;
  bool get saved => _saved;
  AppFailure? get failure => _failure;

  void init(ProfileData data) {
    _profile = data;
    _failure = null;
    _saved = false;
    notifyListeners();
  }

  void updateField({
    String? fullName,
    String? headline,
    String? location,
    String? school,
    String? major,
    String? about,
    bool? isPrivate,
  }) {
    _profile = _profile.copyWith(
      fullName: fullName,
      headline: headline,
      location: location,
      school: school,
      major: major,
      about: about,
      isPrivate: isPrivate,
    );
    notifyListeners();
  }

  Future<bool> save() async {
    if (_profile.fullName.trim().isEmpty) {
      _failure = const ValidationFailure('EMPTY_NAME', 'Họ và tên không được để trống');
      notifyListeners();
      return false;
    }

    _saving = true;
    _failure = null;
    _saved = false;
    notifyListeners();

    final result = await _repository.updateProfile(_profile);
    _saving = false;

    switch (result) {
      case Ok(:final value):
        _profile = value;
        _saved = true;
        notifyListeners();
        return true;
      case Error(:final failure):
        _failure = failure;
        _saved = false;
        notifyListeners();
        return false;
    }
  }
}
