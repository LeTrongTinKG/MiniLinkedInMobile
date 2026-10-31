import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/core/localization/locale_view_model.dart';
import 'package:app/core/storage/preferences_storage.dart';

class FakePreferences implements IAppPreferences {
  String? _locale;

  @override
  Future<void> saveLocale(String languageCode) async {
    _locale = languageCode;
  }

  @override
  Future<String?> getLocale() async => _locale;

  @override
  Future<void> clearJobFilter() async {}
  @override
  Future<String?> getJobFilterJson() async => null;
  @override
  Future<int?> getSelectedTab() async => null;
  @override
  Future<void> saveJobFilterJson(String jsonStr) async {}
  @override
  Future<void> saveSelectedTab(int index) async {}
}

void main() {
  test('LocaleViewModel switches language instantly between vi and en', () async {
    final prefs = FakePreferences();
    final vm = LocaleViewModel(prefs);

    expect(vm.locale.languageCode, 'vi');
    expect(vm.isVietnamese, true);

    await vm.setLocale(const Locale('en'));
    expect(vm.locale.languageCode, 'en');
    expect(vm.isVietnamese, false);
    expect(await prefs.getLocale(), 'en');

    await vm.toggleLanguage();
    expect(vm.locale.languageCode, 'vi');
    expect(vm.isVietnamese, true);
    expect(await prefs.getLocale(), 'vi');
  });

  test('LocaleViewModel loads saved locale from preferences', () async {
    final prefs = FakePreferences();
    await prefs.saveLocale('en');

    final vm = LocaleViewModel(prefs);
    await vm.loadLocale();
    expect(vm.locale.languageCode, 'en');
  });
}
