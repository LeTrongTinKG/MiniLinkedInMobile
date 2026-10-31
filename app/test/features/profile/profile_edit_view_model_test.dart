import 'package:flutter_test/flutter_test.dart';
import 'package:app/core/common/result.dart';
import 'package:app/core/error/app_failure.dart';
import 'package:app/features/profile/domain/models/profile_data.dart';
import 'package:app/features/profile/domain/repositories/profile_repository.dart';
import 'package:app/features/profile/presentation/viewmodels/profile_edit_view_model.dart';

class FakeProfileRepository implements ProfileRepository {
  ProfileData? storedProfile;
  bool shouldFail = false;

  @override
  Future<Result<ProfileData>> getProfile() async {
    if (shouldFail) return const Error(NetworkFailure());
    return Ok(storedProfile ?? const ProfileData(fullName: 'Default User', isPrivate: true));
  }

  @override
  Future<Result<ProfileData>> updateProfile(ProfileData data) async {
    if (shouldFail) return const Error(ServerFailure('Lỗi lưu'));
    storedProfile = data;
    return Ok(data);
  }
}

void main() {
  test('ProfileEditViewModel defaults to private profile (Private by default)', () {
    final repo = FakeProfileRepository();
    final vm = ProfileEditViewModel(repo);

    expect(vm.profile.isPrivate, true);
  });

  test('ProfileEditViewModel toggles privacy setting', () {
    final repo = FakeProfileRepository();
    final vm = ProfileEditViewModel(repo);

    vm.updateField(isPrivate: false);
    expect(vm.profile.isPrivate, false);

    vm.updateField(isPrivate: true);
    expect(vm.profile.isPrivate, true);
  });

  test('ProfileEditViewModel validates empty full name', () async {
    final repo = FakeProfileRepository();
    final vm = ProfileEditViewModel(repo);
    vm.init(const ProfileData(fullName: '   '));

    final success = await vm.save();
    expect(success, false);
    expect(vm.failure, isA<ValidationFailure>());
  });

  test('ProfileEditViewModel saves profile successfully', () async {
    final repo = FakeProfileRepository();
    final vm = ProfileEditViewModel(repo);
    vm.init(const ProfileData(
      fullName: 'Trần Văn B',
      headline: 'Flutter Engineer',
      isPrivate: true,
    ));

    final success = await vm.save();
    expect(success, true);
    expect(vm.saved, true);
    expect(repo.storedProfile?.fullName, 'Trần Văn B');
    expect(repo.storedProfile?.isPrivate, true);
  });
}
