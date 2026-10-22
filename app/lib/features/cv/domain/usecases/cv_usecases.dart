import 'package:file_picker/file_picker.dart';
import '../entities/cv_entity.dart';
import '../repositories/cv_repository.dart';

class GetCvsUseCase {
  final CvRepository _repo;
  GetCvsUseCase(this._repo);
  Future<List<CvEntity>> call() => _repo.getCvs();
}

class UploadCvUseCase {
  final CvRepository _repo;
  UploadCvUseCase(this._repo);
  Future<CvEntity> call(PlatformFile file) => _repo.uploadCv(file);
}

class SetDefaultCvUseCase {
  final CvRepository _repo;
  SetDefaultCvUseCase(this._repo);
  Future<CvEntity> call(String id) => _repo.setDefaultCv(id);
}

class DeleteCvUseCase {
  final CvRepository _repo;
  DeleteCvUseCase(this._repo);
  Future<void> call(String id) => _repo.deleteCv(id);
}
