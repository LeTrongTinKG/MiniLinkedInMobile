import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/cv_entity.dart';
import '../../domain/usecases/cv_usecases.dart';

enum CvStatus { initial, loading, loaded, error }

class CvProvider extends ChangeNotifier {
  final GetCvsUseCase _getCvs;
  final UploadCvUseCase _uploadCv;
  final SetDefaultCvUseCase _setDefault;
  final DeleteCvUseCase _deleteCv;

  CvProvider({
    required GetCvsUseCase getCvs,
    required UploadCvUseCase uploadCv,
    required SetDefaultCvUseCase setDefault,
    required DeleteCvUseCase deleteCv,
  })  : _getCvs = getCvs,
        _uploadCv = uploadCv,
        _setDefault = setDefault,
        _deleteCv = deleteCv;

  CvStatus _status = CvStatus.initial;
  List<CvEntity> _cvs = [];
  bool _isUploading = false;
  String? _errorMessage;

  CvStatus get status => _status;
  List<CvEntity> get cvs => _cvs;
  bool get isLoading => _status == CvStatus.loading;
  bool get isUploading => _isUploading;
  String? get errorMessage => _errorMessage;

  Future<void> loadCvs() async {
    _status = CvStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _cvs = await _getCvs();
      _status = CvStatus.loaded;
    } catch (e) {
      _status = CvStatus.error;
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<bool> uploadCv(PlatformFile file) async {
    _isUploading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final newCv = await _uploadCv(file);
      _cvs = [newCv, ..._cvs];
      _isUploading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isUploading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> setDefault(String id) async {
    try {
      final updated = await _setDefault(id);
      _cvs = _cvs.map((cv) {
        if (cv.id == updated.id) return updated;
        return cv.copyWith(isDefault: false);
      }).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCv(String id) async {
    try {
      await _deleteCv(id);
      _cvs = _cvs.where((cv) => cv.id != id).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
