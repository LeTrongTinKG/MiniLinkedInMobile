import 'package:file_picker/file_picker.dart';
import '../models/cv_model.dart';

abstract interface class CvDataSource {
  Future<List<CvModel>> getCvs();
  Future<CvModel> uploadCv(PlatformFile file);
  Future<CvModel> setDefaultCv(String id);
  Future<void> deleteCv(String id);
}
