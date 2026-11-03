import 'package:flutter/material.dart';
import '../storage/preferences_storage.dart';

/// ViewModel quản lý chế độ Sáng / Tối (Light / Dark mode) cho toàn bộ ứng dụng.
class ThemeViewModel extends ChangeNotifier {
  final IAppPreferences _preferences;

  ThemeViewModel(this._preferences);

  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> loadThemeMode() async {
    try {
      final saved = await _preferences.getThemeMode();
      if (saved == 'dark') {
        _themeMode = ThemeMode.dark;
      } else if (saved == 'system') {
        _themeMode = ThemeMode.system;
      } else {
        _themeMode = ThemeMode.light;
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> toggleTheme() async {
    final next = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(next);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    try {
      final str = mode == ThemeMode.dark
          ? 'dark'
          : mode == ThemeMode.system
              ? 'system'
              : 'light';
      await _preferences.saveThemeMode(str);
    } catch (_) {}
  }
}

