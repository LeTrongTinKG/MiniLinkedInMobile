// Màn hình chính dành cho sinh viên trong ứng dụng MiniLinkedIn
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';

/// Màn hình chính của sinh viên với thanh điều hướng dưới gồm 5 tab
class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  // Chỉ số tab đang được chọn
  int _selectedIndex = 0;

  /// Danh sách các trang tương ứng với từng tab
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _buildPlaceholderPage(
        icon: Icons.dynamic_feed,
        title: 'Đầu trang',
        subtitle: 'Các bài viết sẽ xuất hiện ở đây',
      ),
      _buildPlaceholderPage(
        icon: Icons.work_outline,
        title: 'Tìm việc',
        subtitle: 'Khám phá các cơ hội việc làm',
      ),
      _buildPlaceholderPage(
        icon: Icons.post_add,
        title: 'Đăng bài',
        subtitle: 'Chia sẻ cập nhật với mạng lưới của bạn',
      ),
      _buildPlaceholderPage(
        icon: Icons.notifications_none,
        title: 'Thông báo',
        subtitle: 'Chưa có thông báo mới',
      ),
      // Trang hồ sơ sẽ đọc dữ liệu từ AuthProvider
      const _ProfilePage(roleLabel: 'Sinh viên'),
    ];
  }

  /// Xử lý khi người dùng chọn tab
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ── AppBar ──────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        // Logo LinkedIn 'in' nhỏ ở góc trái
        leading: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF0A66C2),
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: const Text(
              'in',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        title: const Text(
          'Mini LinkedIn',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Nút tìm kiếm
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black54),
            onPressed: () {
              // TODO: Mở màn hình tìm kiếm
            },
          ),
        ],
      ),

      // ── Nội dung chính – dùng IndexedStack để giữ trạng thái mỗi tab ──
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      // ── Thanh điều hướng dưới ───────────────────────────────────────────
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF0A66C2),
        unselectedItemColor: const Color(0xFF666666),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Đầu trang',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            label: 'Tìm việc',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            label: 'Đăng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none),
            label: 'Thông báo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Hồ sơ',
          ),
        ],
      ),
    );
  }

  /// Tạo widget placeholder chung cho các trang chưa triển khai
  Widget _buildPlaceholderPage({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 72, color: const Color(0xFF0A66C2)),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
/// Trang hồ sơ – hiển thị thông tin người dùng từ AuthProvider
// ─────────────────────────────────────────────────────────────────────────────
class _ProfilePage extends StatelessWidget {
  /// Nhãn vai trò hiển thị trên Chip (vd: 'Sinh viên')
  final String roleLabel;

  const _ProfilePage({required this.roleLabel});

  @override
  Widget build(BuildContext context) {
    // Lắng nghe AuthProvider để lấy thông tin người dùng hiện tại
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.currentUser;

        final displayName = user?.displayName ?? '';
        final String avatarLetter =
            displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Avatar ────────────────────────────────────────────────
                CircleAvatar(
                  radius: 40,
                  backgroundColor: const Color(0xFF0A66C2),
                  child: Text(
                    avatarLetter,
                    style: const TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Tên hiển thị ──────────────────────────────────────────
                Text(
                  user?.displayName ?? 'Người dùng',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),

                // ── Email ─────────────────────────────────────────────────
                Text(
                  user?.email ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // ── Chip hiển thị vai trò ─────────────────────────────────
                Chip(
                  label: Text(
                    roleLabel,
                    style: const TextStyle(
                      color: Color(0xFF0A66C2),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  backgroundColor: const Color(0xFFE8F0FE),
                  side: const BorderSide(color: Color(0xFF0A66C2)),
                ),
                const SizedBox(height: 32),

                // ── Nút đăng xuất ─────────────────────────────────────────
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A66C2),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(200, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: () async {
                    // Đăng xuất và chuyển về màn hình đăng nhập
                    await authProvider.logout();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  },
                  child: const Text(
                    'Đăng xuất',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
