import 'package:flutter/material.dart';
import '../../domain/entities/post_media.dart';

/// Xem ảnh toàn màn hình: vuốt trái/phải đổi ảnh, chụm hai ngón (hoặc cuộn chuột) để phóng to.
class ImageViewerScreen extends StatefulWidget {
  const ImageViewerScreen({super.key, required this.media, this.initialIndex = 0});
  final List<PostMedia> media;
  final int initialIndex;

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  late final PageController _pages = PageController(initialPage: widget.initialIndex);
  late int _index = widget.initialIndex;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [
        // Các trang ảnh (giống map danh sách -> mỗi phần tử 1 trang)
        PageView.builder(
          controller: _pages,
          itemCount: widget.media.length,
          onPageChanged: (i) => setState(() => _index = i),
          itemBuilder: (_, i) => InteractiveViewer(
            minScale: 1,
            maxScale: 4,
            child: Center(
              child: widget.media[i].url.contains('mock-supabase.storage.local')
                  ? const Icon(Icons.image_outlined, color: Colors.white54, size: 64)
                  : Image.network(
                      widget.media[i].url,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.broken_image_outlined, color: Colors.white54, size: 64),
                    ),
            ),
          ),
        ),
        // Nút đóng + số trang
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const Spacer(),
              if (widget.media.length > 1)
                Text('${_index + 1}/${widget.media.length}',
                    style: const TextStyle(color: Colors.white)),
              const SizedBox(width: 12),
            ]),
          ),
        ),
      ]),
    );
  }
}
