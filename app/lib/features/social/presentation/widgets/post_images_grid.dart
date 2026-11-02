import 'package:flutter/material.dart';
import '../../domain/entities/post_media.dart';
import '../social_strings.dart';

/// Lưới ảnh kiểu Facebook: 1 ảnh to / 2 ảnh cạnh nhau / 3 ảnh (1 to + 2 nhỏ) / >=4 ảnh lưới 2x2 (+N).
class PostImagesGrid extends StatelessWidget {
  const PostImagesGrid({super.key, required this.media, required this.onTap});

  final List<PostMedia> media;
  final void Function(int index) onTap; // báo ảnh số mấy được bấm

  static const double _gap = 2;

  @override
  Widget build(BuildContext context) {
    if (media.isEmpty) return const SizedBox.shrink();

    // LayoutBuilder cho biết chiều ngang thật -> tính chiều cao từng ô
    return LayoutBuilder(builder: (context, box) {
      final w = box.maxWidth;
      final half = (w - _gap) / 2;

      switch (media.length) {
        case 1:
          return _tile(0, w, _singleHeight(w));
        case 2:
          return Row(children: [
            _tile(0, half, half),
            const SizedBox(width: _gap),
            _tile(1, half, half),
          ]);
        case 3:
          return Column(children: [
            _tile(0, w, w * 0.6),
            const SizedBox(height: _gap),
            Row(children: [
              _tile(1, half, half * 0.8),
              const SizedBox(width: _gap),
              _tile(2, half, half * 0.8),
            ]),
          ]);
        default:
          return Column(children: [
            Row(children: [
              _tile(0, half, half),
              const SizedBox(width: _gap),
              _tile(1, half, half),
            ]),
            const SizedBox(height: _gap),
            Row(children: [
              _tile(2, half, half),
              const SizedBox(width: _gap),
              _tile(3, half, half, extra: media.length - 4),
            ]),
          ]);
      }
    });
  }

  // Ảnh đơn: theo tỉ lệ thật của ảnh nhưng không quá cao / quá thấp
  double _singleHeight(double w) {
    final m = media.first;
    if (m.width == null || m.height == null || m.width == 0) return w * 0.75;
    return (w * m.height! / m.width!).clamp(w * 0.5, w * 1.1).toDouble();
  }

  Widget _tile(int index, double width, double height, {int extra = 0}) {
    final m = media[index];
    final imageUrl = m.thumbnailUrl ?? m.url;
    final isMock = imageUrl.contains('mock-supabase.storage.local') || !imageUrl.startsWith('http');

    return GestureDetector(
      onTap: () => onTap(index),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(fit: StackFit.expand, children: [
          if (isMock)
            Container(
              color: const Color(0xFFE4E6EB),
              child: const Icon(Icons.image_outlined, color: Colors.grey),
            )
          else
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFFE4E6EB),
                child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
              ),
            ),
          if (extra > 0)
            Container(
              color: Colors.black54,
              alignment: Alignment.center,
              child: Text(SocialStrings.moreImages(extra),
                  style: const TextStyle(
                      color: Colors.white, fontSize: 32, fontWeight: FontWeight.w600)),
            ),
        ]),
      ),
    );
  }
}
