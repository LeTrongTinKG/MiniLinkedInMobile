import 'package:dio/dio.dart';
import '../../../../core/common/result.dart';
import '../../../../core/error/app_failure.dart';
import '../domain/models/profile_data.dart';
import '../domain/repositories/profile_repository.dart';
import 'profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _dataSource;

  ProfileRepositoryImpl(this._dataSource);

  @override
  Future<Result<ProfileData>> getProfile() async {
    try {
      final profile = await _dataSource.getProfile();
      return Ok(profile);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        return const Error(NetworkFailure());
      }
      return Error(ServerFailure(e.message ?? 'Lỗi máy chủ'));
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<ProfileData>> updateProfile(ProfileData data) async {
    if (data.fullName.trim().isEmpty) {
      return const Error(
        ValidationFailure('EMPTY_NAME', 'Họ và tên không được để trống'),
      );
    }
    try {
      final updated = await _dataSource.updateProfile(data);
      return Ok(updated);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        return const Error(NetworkFailure());
      }
      final msg = e.response?.data?['error']?['message'] as String?;
      return Error(ServerFailure(msg ?? 'Cập nhật thất bại'));
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }
}
