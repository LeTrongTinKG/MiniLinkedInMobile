import 'package:flutter/material.dart';
import '../storage/preferences_storage.dart';

/// ViewModel quản lý đa ngôn ngữ (F-017, Ticket 03)
/// Cho phép chuyển đổi tức thì giữa tiếng Việt (vi) và tiếng Anh (en) tại runtime.
class LocaleViewModel extends ChangeNotifier {
  final IAppPreferences _preferences;
  Locale _locale = const Locale('vi');

  LocaleViewModel(this._preferences);

  Locale get locale => _locale;
  bool get isVietnamese => _locale.languageCode == 'vi';

  Future<void> loadLocale() async {
    final saved = await _preferences.getLocale();
    if (saved == 'en' || saved == 'vi') {
      _locale = Locale(saved!);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale newLocale) async {
    if (_locale == newLocale) return;
    if (newLocale.languageCode != 'vi' && newLocale.languageCode != 'en') return;
    _locale = newLocale;
    await _preferences.saveLocale(newLocale.languageCode);
    notifyListeners();
  }

  Future<void> toggleLanguage() async {
    final next = _locale.languageCode == 'vi' ? const Locale('en') : const Locale('vi');
    await setLocale(next);
  }
}
