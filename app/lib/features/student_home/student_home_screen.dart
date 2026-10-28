import 'package:flutter/material.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/storage/preferences_storage.dart';
import 'package:app/features/jobs/presentation/screens/job_list_screen.dart';
import 'package:app/features/news/news_page.dart';
import 'package:app/features/social/social_page.dart';
import 'package:app/features/student_home/student_nav.dart';
import 'package:app/features/student_home/widgets/app_header.dart';
import 'package:app/features/student_home/widgets/student_bottom_bar.dart';

/// Khung chính của sinh viên: header chung ở trên, 3 tab ở giữa, thanh nút ở dưới.
/// StatefulWidget ~ component React có useState.
class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  // Tab đang chọn (0 = Việc làm, 1 = Mạng xã hội, 2 = Tin tức).
  int _selectedIndex = 0;
  late final IAppPreferences _preferences;

  // Tiêu đề header và nội dung trang, cùng thứ tự với 3 nút dưới.
  static const _titles = <String>['Việc làm', 'Mạng xã hội', 'Tin tức'];
  static const _pages = <Widget>[
    JobListScreen(),
    SocialPage(),
    NewsPage(),
  ];

  // Giống useEffect(() => {...}, []): chạy 1 lần khi màn hình được tạo.
  @override
  void initState() {
    super.initState();
    _preferences = AppPreferencesStorage.defaultStorage();
    _restoreSavedTab();
  }

  // Đọc tab đã lưu lần trước, chỉ nhận nếu nằm trong 0..2.
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

  // Khi bấm nút dưới: đổi tab (setState) và lưu lại.
  void _onTabSelected(int index) {
    setState(() => _selectedIndex = index);
    _preferences.saveSelectedTab(index);
  }

  // Phần return JSX: header + IndexedStack (giữ trạng thái từng tab) + bottom bar.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: studentScaffoldKey,
      backgroundColor: AppColors.background,
      drawer: const StudentDrawer(),
      body: Column(
        children: [
          AppHeader(title: _titles[_selectedIndex]),
          Expanded(
            // Header đã chừa chỗ cho tai thỏ, nên thân không cần chừa nữa.
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: IndexedStack(index: _selectedIndex, children: _pages),
            ),
          ),
        ],
      ),
      bottomNavigationBar: StudentBottomBar(
        selectedIndex: _selectedIndex,
        onSelect: _onTabSelected,
      ),
    );
  }
}
