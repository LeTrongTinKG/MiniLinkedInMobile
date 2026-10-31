import '../../../../core/common/result.dart';
import '../models/profile_data.dart';

abstract interface class ProfileRepository {
  Future<Result<ProfileData>> getProfile();
  Future<Result<ProfileData>> updateProfile(ProfileData data);
}

