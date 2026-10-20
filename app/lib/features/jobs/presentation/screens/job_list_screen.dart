import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/job_entity.dart';
import '../providers/job_provider.dart';
import '../widgets/job_card.dart';
import '../widgets/job_filter_sheet.dart';
import '../widgets/job_search_bar.dart';

/// Màn hình danh sách công việc IT dành cho sinh viên kèm tìm kiếm và lọc
class JobListScreen extends StatefulWidget {
  const JobListScreen({super.key});

  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  @override
  void initState() {
    super.initState();
    // Nạp dữ liệu ban đầu sau frame đầu tiên
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobProvider>().init();
    });
  }

  void _openFilterSheet(JobProvider provider) {
    JobFilterSheet.show(context, provider);
  }

  void _showJobDetailSheet(JobEntity job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _JobQuickDetailSheet(job: job),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<JobProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF3F2EF),
          body: Column(
            children: [
              // Thanh tìm kiếm và bộ lọc nhanh phong cách LinkedIn
              JobSearchBar(
                provider: provider,
                onOpenFilterSheet: () => _openFilterSheet(provider),
              ),

              // Nội dung danh sách
              Expanded(
                child: RefreshIndicator(
                  color: const Color(0xFF0A66C2),
                  onRefresh: () => provider.loadJobs(),
                  child: _buildBody(provider),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(JobProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF0A66C2)),
            SizedBox(height: 16),
            Text(
              'Đang tìm kiếm cơ hội việc làm IT...',
              style: TextStyle(color: Color(0xFF666666), fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 56,
                color: Color(0xFFB00020),
              ),
              const SizedBox(height: 16),
              Text(
                provider.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: Color(0xFF444444)),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => provider.loadJobs(),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Thử lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A66C2),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.jobs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFFEAF4FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.work_off_outlined,
                  size: 40,
                  color: Color(0xFF0A66C2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Không tìm thấy công việc phù hợp',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF191919),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Hãy thử thay đổi từ khóa tìm kiếm hoặc điều chỉnh lại tiêu chí bộ lọc của bạn.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => provider.resetFilter(),
                icon: const Icon(Icons.filter_alt_off_rounded, size: 18),
                label: const Text('Xóa tất cả bộ lọc'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0A66C2),
                  side: const BorderSide(color: Color(0xFF0A66C2)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount: provider.jobs.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          // Tiêu đề thống kê kết quả tìm kiếm
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tìm thấy ${provider.jobs.length} công việc',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF666666),
                  ),
                ),
                if (provider.hasFilter)
                  InkWell(
                    onTap: () => provider.resetFilter(),
                    child: const Text(
                      'Xóa lọc',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF0A66C2),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }

        final job = provider.jobs[index - 1];
        return JobCard(
          job: job,
          onTap: () => _showJobDetailSheet(job),
        );
      },
    );
  }
}

/// Sheet xem nhanh chi tiết công việc (Chuẩn bị tích hợp Task F6)
class _JobQuickDetailSheet extends StatelessWidget {
  final JobEntity job;

  const _JobQuickDetailSheet({required this.job});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  job.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF191919),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  job.companyName,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF0A66C2),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${job.location} • ${job.workMode.label}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F2EF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoCol('Mức lương', job.formattedSalary),
                      _buildInfoCol('Cấp bậc', job.level.label),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Kỹ năng bắt buộc (Required Skills)',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF191919),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: job.requiredSkills.map((s) {
                    return Chip(
                      label: Text(s),
                      backgroundColor: const Color(0xFFEAF4FF),
                      labelStyle: const TextStyle(
                        color: Color(0xFF0A66C2),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      side: BorderSide.none,
                    );
                  }).toList(),
                ),
                if (job.niceToHave.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Kỹ năng ưu tiên (Nice to have)',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF191919),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: job.niceToHave.map((s) {
                      return Chip(
                        label: Text(s),
                        backgroundColor: const Color(0xFFF3F2EF),
                        labelStyle: const TextStyle(
                          color: Color(0xFF555555),
                          fontSize: 12,
                        ),
                        side: BorderSide.none,
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 20),
                const Text(
                  'Mô tả công việc',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF191919),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  job.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF444444),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE0DFDC))),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Tính năng Nộp CV ứng tuyển sẽ được kết nối ở Task F8!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A66C2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Ứng tuyển ngay',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCol(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF777777)),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF191919),
          ),
        ),
      ],
    );
  }
}

