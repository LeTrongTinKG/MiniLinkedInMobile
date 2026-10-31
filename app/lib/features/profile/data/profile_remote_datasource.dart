import 'package:dio/dio.dart';
import '../domain/models/profile_data.dart';

class ProfileRemoteDataSource {
  final Dio _dio;

  ProfileRemoteDataSource(this._dio);

  Future<ProfileData> getProfile() async {
    final response = await _dio.get('/api/v1/profile');
    final data = response.data['data'] as Map<String, dynamic>;
    return ProfileData.fromJson(data);
  }

  Future<ProfileData> updateProfile(ProfileData profile) async {
    final response = await _dio.put('/api/v1/profile', data: profile.toJson());
    final data = response.data['data'] as Map<String, dynamic>;
    return ProfileData.fromJson(data);
  }
}
