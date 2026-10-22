import 'package:file_picker/file_picker.dart';
import '../../domain/entities/cv_entity.dart';
import '../../domain/repositories/cv_repository.dart';
import '../datasources/cv_datasource.dart';

class CvRepositoryImpl implements CvRepository {
  final CvDataSource _dataSource;

  CvRepositoryImpl(this._dataSource);

  @override
  Future<List<CvEntity>> getCvs() async {
    final models = await _dataSource.getCvs();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<CvEntity> uploadCv(PlatformFile file) async {
    final model = await _dataSource.uploadCv(file);
    return model.toEntity();
  }

  @override
  Future<CvEntity> setDefaultCv(String id) async {
    final model = await _dataSource.setDefaultCv(id);
    return model.toEntity();
  }

  @override
  Future<void> deleteCv(String id) => _dataSource.deleteCv(id);
}
