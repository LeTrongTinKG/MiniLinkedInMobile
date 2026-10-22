import 'package:flutter/material.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/storage/preferences_storage.dart';
import 'package:app/features/jobs/presentation/screens/job_list_screen.dart';
import 'package:app/features/applications/applications_page.dart';
import 'package:app/features/profile/profile_page.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _selectedIndex = 0;
  late final IAppPreferences _preferences;

  static const _pages = <Widget>[
    JobListScreen(), // Tích hợp Màn danh sách việc làm IT kèm tìm kiếm và lọc (Task F5)
    ApplicationsPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _preferences = AppPreferencesStorage.defaultStorage();
    _restoreSavedTab();
  }

  Future<void> _restoreSavedTab() async {
    try {
      final savedTab = await _preferences.getSelectedTab();
      if (savedTab != null && savedTab >= 0 && savedTab < _pages.length) {
        if (mounted) {
          setState(() => _selectedIndex = savedTab);
        }
      }
    } catch (_) {}
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    _preferences.saveSelectedTab(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.work_outline),
              selectedIcon: Icon(Icons.work),
              label: 'Việc làm',
            ),
            NavigationDestination(
              icon: Icon(Icons.assignment_turned_in_outlined),
              selectedIcon: Icon(Icons.assignment_turned_in),
              label: 'Đã ứng tuyển',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Hồ sơ',
            ),
          ],
        ),
      ),
    );
  }
}
