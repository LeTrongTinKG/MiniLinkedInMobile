import 'package:file_picker/file_picker.dart';
import '../entities/cv_entity.dart';

abstract interface class CvRepository {
  Future<List<CvEntity>> getCvs();
  Future<CvEntity> uploadCv(PlatformFile file);
  Future<CvEntity> setDefaultCv(String id);
  Future<void> deleteCv(String id);
}
