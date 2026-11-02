import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/core/theme/theme_view_model.dart';
import 'package:app/core/storage/preferences_storage.dart';

class _FakePreferences implements IAppPreferences {
  String? _mode;

  @override
  Future<void> saveThemeMode(String mode) async => _mode = mode;

  @override
  Future<String?> getThemeMode() async => _mode;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  test('ThemeViewModel initializes with light mode and toggles to dark', () async {
    final prefs = _FakePreferences();
    final vm = ThemeViewModel(prefs);

    expect(vm.themeMode, ThemeMode.light);
    expect(vm.isDarkMode, false);

    await vm.toggleTheme();
    expect(vm.themeMode, ThemeMode.dark);
    expect(vm.isDarkMode, true);
    expect(await prefs.getThemeMode(), 'dark');

    await vm.toggleTheme();
    expect(vm.themeMode, ThemeMode.light);
    expect(vm.isDarkMode, false);
    expect(await prefs.getThemeMode(), 'light');
  });

  test('ThemeViewModel loads saved dark theme mode', () async {
    final prefs = _FakePreferences();
    await prefs.saveThemeMode('dark');

    final vm = ThemeViewModel(prefs);
    await vm.loadThemeMode();

    expect(vm.themeMode, ThemeMode.dark);
    expect(vm.isDarkMode, true);
  });
}

