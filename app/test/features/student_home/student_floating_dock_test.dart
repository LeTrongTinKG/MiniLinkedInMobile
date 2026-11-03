import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:app/core/theme/theme_view_model.dart';
import 'package:app/core/storage/preferences_storage.dart';
import 'package:app/features/student_home/widgets/student_floating_dock.dart';
import 'package:app/features/student_home/widgets/dock_item.dart';

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
  testWidgets('StudentFloatingDock renders all 5 dock items and handles taps', (tester) async {
    final prefs = _FakePreferences();
    final themeVm = ThemeViewModel(prefs);
    int selected = 0;
    bool coachOpened = false;

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: themeVm,
        child: MaterialApp(
          home: Scaffold(
            body: StudentFloatingDock(
              selectedIndex: selected,
              onSelect: (i) => selected = i,
              onOpenCoach: () => coachOpened = true,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(DockItem), findsNWidgets(5));
    expect(find.byIcon(Icons.work_rounded), findsOneWidget);
    expect(find.byIcon(Icons.public_rounded), findsOneWidget);
    expect(find.byIcon(Icons.newspaper_rounded), findsOneWidget);
    expect(find.byIcon(Icons.auto_awesome_rounded), findsOneWidget);
    expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);

    // Tap Trợ lý AI
    await tester.tap(find.byIcon(Icons.auto_awesome_rounded));
    await tester.pump();
    expect(coachOpened, true);

    // Tap Dark Mode Toggle
    await tester.tap(find.byIcon(Icons.dark_mode_rounded));
    await tester.pump();
    expect(themeVm.isDarkMode, true);

    // Tap Tab Mạng xã hội
    await tester.tap(find.byIcon(Icons.public_rounded));
    await tester.pump();
    expect(selected, 1);
  });
}

