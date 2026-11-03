import 'package:flutter/material.dart';
import 'package:app/core/theme/app_colors.dart';
import '../../skills/presentation/screens/repo_upload_screen.dart';

/// Card "Proof of work: Upload GitHub, not CV" theo thiết kế v0.
class ProofOfWorkCard extends StatefulWidget {
  const ProofOfWorkCard({super.key});

  @override
  State<ProofOfWorkCard> createState() => _ProofOfWorkCardState();
}

class _ProofOfWorkCardState extends State<ProofOfWorkCard> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openRepoScanner() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RepoUploadScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E3A8A).withValues(alpha: 0.35), const Color(0xFF0F172A)]
              : [const Color(0xFFEFF6FF), Colors.white],
        ),
        border: Border.all(
          color: isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.5) : const Color(0xFFDBEAFE),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D4ED8).withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PROOF OF WORK',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.8,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Upload GitHub, not CV',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Chứng thực năng lực lập trình bằng mã nguồn và commit thực tế.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : Colors.black54,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(Icons.fork_right_rounded, size: 22, color: isDark ? Colors.white : const Color(0xFF0F172A)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: _openRepoScanner,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A).withValues(alpha: 0.8) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.6) : const Color(0xFFBFDBFE),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.link_rounded, size: 16, color: isDark ? Colors.white38 : Colors.black38),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'https://github.com/user/repo',
                      style: TextStyle(fontSize: 11.5, color: isDark ? Colors.white38 : Colors.black38),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Quét Repo',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
