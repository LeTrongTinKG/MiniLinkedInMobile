import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/network/dio_client.dart';
import '../models/cv_model.dart';
import 'cv_datasource.dart';

class CvRemoteDataSource implements CvDataSource {
  final Dio _dio;

  CvRemoteDataSource(this._dio);

  @override
  Future<List<CvModel>> getCvs() async {
    try {
      final response = await _dio.get('/cvs');
      final list = response.data['data'] as List<dynamic>;
      return list
          .map((e) => CvModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw DioClient.handleDioError(e);
    }
  }

  @override
  Future<CvModel> uploadCv(PlatformFile file) async {
    try {
      final multipart = await _buildMultipart(file);
      final formData = FormData.fromMap({'cv': multipart});
      final response = await _dio.post('/cvs', data: formData);
      return CvModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw DioClient.handleDioError(e);
    }
  }

  @override
  Future<CvModel> setDefaultCv(String id) async {
    try {
      final response = await _dio.patch('/cvs/$id/default');
      return CvModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw DioClient.handleDioError(e);
    }
  }

  @override
  Future<void> deleteCv(String id) async {
    try {
      await _dio.delete('/cvs/$id');
    } on DioException catch (e) {
      throw DioClient.handleDioError(e);
    }
  }

  Future<MultipartFile> _buildMultipart(PlatformFile file) async {
    final contentType = DioMediaType('application', 'pdf');
    // file_picker v12+: use readAsBytes() instead of .bytes field
    final bytes = await file.readAsBytes();
    return MultipartFile.fromBytes(
      bytes,
      filename: file.name,
      contentType: contentType,
    );
  }
}
