import 'package:flutter/material.dart';
import 'package:app/core/theme/app_colors.dart';

enum ApplicationFilter { all, submitted, accepted, rejected }

class RecruiterApplicationsPage extends StatefulWidget {
  const RecruiterApplicationsPage({super.key});

  @override
  State<RecruiterApplicationsPage> createState() =>
      _RecruiterApplicationsPageState();
}

class _RecruiterApplicationsPageState extends State<RecruiterApplicationsPage> {
  ApplicationFilter _filter = ApplicationFilter.all;

  final List<Map<String, dynamic>> _applications = [
    {
      'id': 'app-1',
      'name': 'Nguyễn Văn An',
      'jobTitle': 'Flutter Developer Fresher',
      'date': '24/10/2026',
      'score': 85,
      'status': 'submitted',
      'cvName': 'NguyenVanAn_CV.pdf',
    },
    {
      'id': 'app-2',
      'name': 'Trần Thị Bình',
      'jobTitle': 'Mobile App Intern',
      'date': '23/10/2026',
      'score': 92,
      'status': 'accepted',
      'cvName': 'TranThiBinh_CV_2026.pdf',
    },
    {
      'id': 'app-3',
      'name': 'Lê Hoàng Nam',
      'jobTitle': 'Flutter Developer Fresher',
      'date': '22/10/2026',
      'score': 45,
      'status': 'rejected',
      'cvName': 'LeHoangNam_Resume.pdf',
    },
  ];

  void _updateStatus(String id, String newStatus) {
    setState(() {
      final index = _applications.indexWhere((a) => a['id'] == id);
      if (index != -1) {
        _applications[index]['status'] = newStatus;
      }
    });
    final label = newStatus == 'accepted' ? 'Đã duyệt' : 'Đã từ chối';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label ứng viên thành công!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _applications.where((app) {
      if (_filter == ApplicationFilter.all) return true;
      if (_filter == ApplicationFilter.submitted) {
        return app['status'] == 'submitted';
      }
      if (_filter == ApplicationFilter.accepted) {
        return app['status'] == 'accepted';
      }
      if (_filter == ApplicationFilter.rejected) {
        return app['status'] == 'rejected';
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Duyệt Ứng viên'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _buildFilterChips(),
        ),
      ),
      body: filtered.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filtered.length,
              itemBuilder: (context, i) => _buildCard(filtered[i]),
            ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _chip('Tất cả', ApplicationFilter.all),
          const SizedBox(width: 8),
          _chip('Chờ duyệt', ApplicationFilter.submitted),
          const SizedBox(width: 8),
          _chip('Đã duyệt', ApplicationFilter.accepted),
          const SizedBox(width: 8),
          _chip('Từ chối', ApplicationFilter.rejected),
        ],
      ),
    );
  }

  Widget _chip(String label, ApplicationFilter filter) {
    final selected = _filter == filter;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _filter = filter),
      selectedColor: AppColors.primaryContainer,
      labelStyle: TextStyle(
        color:
            selected ? AppColors.onPrimaryContainer : AppColors.textSecondary,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> app) {
    final status = app['status'] as String;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primaryContainer,
                  child: Text(
                    app['name'][0],
                    style: const TextStyle(
                      color: AppColors.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app['name'],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        app['jobTitle'],
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(status),
              ],
            ),
            const Divider(height: 20),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.salary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Match ${app['score']}%',
                    style: const TextStyle(
                      color: AppColors.salary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'CV: ${app['cvName']}',
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (status == 'submitted')
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error),
                      onPressed: () => _updateStatus(app['id'], 'rejected'),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Từ chối'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.salary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => _updateStatus(app['id'], 'accepted'),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Duyệt đơn'),
                    ),
                  ),
                ],
              )
            else
              Text(
                'Ngày cập nhật: ${app['date']}',
                style:
                    const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg = Colors.orange.shade50;
    Color fg = Colors.orange.shade800;
    String text = 'Chờ duyệt';

    if (status == 'accepted') {
      bg = Colors.green.shade50;
      fg = AppColors.salary;
      text = 'Đã duyệt';
    } else if (status == 'rejected') {
      bg = Colors.red.shade50;
      fg = AppColors.error;
      text = 'Đã từ chối';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(
        text,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 56, color: AppColors.iconMuted),
          SizedBox(height: 12),
          Text(
            'Không có đơn ứng tuyển nào',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
