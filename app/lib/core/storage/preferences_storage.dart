import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';

/// Interface định nghĩa hợp đồng lưu trữ trạng thái giao diện và tùy chọn người dùng (DIP)
abstract interface class IAppPreferences {
  Future<void> saveSelectedTab(int index);
  Future<int?> getSelectedTab();
  Future<void> saveJobFilterJson(String jsonStr);
  Future<String?> getJobFilterJson();
  Future<void> clearJobFilter();
  Future<void> saveLocale(String languageCode);
  Future<String?> getLocale();
}

/// Triển khai lưu trữ Preferences dùng FlutterSecureStorage (hoạt động tốt trên cả Web localStorage và Mobile)
class AppPreferencesStorage implements IAppPreferences {
  final FlutterSecureStorage _storage;

  const AppPreferencesStorage(this._storage);

  factory AppPreferencesStorage.defaultStorage() {
    const storage = FlutterSecureStorage();
    return AppPreferencesStorage(storage);
  }

  @override
  Future<void> saveSelectedTab(int index) async {
    await _storage.write(
      key: AppConfig.keySelectedTab,
      value: index.toString(),
    );
  }

  @override
  Future<int?> getSelectedTab() async {
    final raw = await _storage.read(key: AppConfig.keySelectedTab);
    if (raw == null) return null;
    return int.tryParse(raw);
  }

  @override
  Future<void> saveJobFilterJson(String jsonStr) async {
    await _storage.write(
      key: AppConfig.keyJobFilter,
      value: jsonStr,
    );
  }

  @override
  Future<String?> getJobFilterJson() {
    return _storage.read(key: AppConfig.keyJobFilter);
  }

  @override
  Future<void> clearJobFilter() async {
    await _storage.delete(key: AppConfig.keyJobFilter);
  }

  @override
  Future<void> saveLocale(String languageCode) async {
    await _storage.write(key: 'app_locale', value: languageCode);
  }

  @override
  Future<String?> getLocale() {
    return _storage.read(key: 'app_locale');
  }
}

