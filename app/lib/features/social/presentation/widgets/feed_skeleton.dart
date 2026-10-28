import 'package:flutter/material.dart';
import '../../../../ui_kit/ui_kit.dart';

/// Khung xương hiện lúc tải feed lần đầu (3 thẻ bài giả nhấp nháy).
class FeedSkeleton extends StatelessWidget {
  const FeedSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [for (var i = 0; i < 3; i++) const _SkeletonPost()],
    );
  }
}

class _SkeletonPost extends StatelessWidget {
  const _SkeletonPost();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            AppSkeleton(width: 40, height: 40, circle: true),
            SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              AppSkeleton(width: 120, height: 14),
              SizedBox(height: 6),
              AppSkeleton(width: 70, height: 10),
            ]),
          ]),
          SizedBox(height: 12),
          AppSkeleton(height: 14),
          SizedBox(height: 6),
          AppSkeleton(height: 14),
          SizedBox(height: 6),
          AppSkeleton(width: 180, height: 14),
        ],
      ),
    );
  }
}
