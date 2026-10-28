import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../domain/entities/uploaded_media.dart';
import '../providers/post_uploader.dart';
import '../social_strings.dart';

/// Lưới xem trước ảnh đã chọn: mỗi ô có nút xóa (X) và trạng thái tải lên (xoay / xong / lỗi).
class PickedImagesGrid extends StatelessWidget {
  const PickedImagesGrid({
    super.key,
    required this.images,
    required this.uploads,
    required this.canRemove,
    required this.onRemove,
  });

  final List<PickedImage> images;
  final List<UploadItem> uploads; // trạng thái upload do provider giữ
  final bool canRemove; // đang đăng thì khóa nút xóa
  final void Function(int index) onRemove;

  // Tìm trạng thái upload của đúng ảnh này (null = chưa bắt đầu đăng)
  UploadItem? _statusOf(PickedImage img) {
    for (final u in uploads) {
      if (identical(u.image, img)) return u;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < images.length; i++)
          _tile(images[i], _statusOf(images[i]), () => onRemove(i)),
      ],
    );
  }

  Widget _tile(PickedImage img, UploadItem? upload, VoidCallback remove) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(fit: StackFit.expand, children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(Uint8List.fromList(img.bytes), fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: const Color(0xFFE4E6EB))),
        ),
        // Lớp trạng thái upload
        if (upload != null && upload.status != UploadStatus.waiting) _statusLayer(upload),
        // Nút xóa
        Positioned(
          top: 2,
          right: 2,
          child: GestureDetector(
            onTap: canRemove ? remove : null,
            child: Tooltip(
              message: SocialStrings.removeImage,
              child: Container(
                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                padding: const EdgeInsets.all(2),
                child: const Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _statusLayer(UploadItem upload) {
    switch (upload.status) {
      case UploadStatus.uploading:
        return _overlay(Colors.black38,
            const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)));
      case UploadStatus.done:
        return _overlay(Colors.transparent, const Icon(Icons.check_circle, color: Colors.greenAccent));
      case UploadStatus.failed:
        return _overlay(
            Colors.black54,
            Tooltip(
                message: upload.error ?? SocialStrings.uploadFailed,
                child: const Icon(Icons.error, color: Colors.redAccent)));
      case UploadStatus.waiting:
        return const SizedBox.shrink();
    }
  }

  Widget _overlay(Color color, Widget child) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: ColoredBox(color: color, child: Center(child: child)),
    );
  }
}
