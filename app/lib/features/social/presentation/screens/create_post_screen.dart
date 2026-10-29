import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../ui_kit/ui_kit.dart';
import '../../domain/entities/post.dart';
import '../../domain/entities/uploaded_media.dart';
import '../providers/social_feed_provider.dart';
import '../social_strings.dart';
import '../utils/pick_images.dart';
import '../widgets/max_width_box.dart';
import '../widgets/picked_images_grid.dart';

/// Màn soạn bài. Truyền `editing` thì là chế độ SỬA (chỉ sửa chữ), không thì là TẠO MỚI.
/// Giống 1 component React có state: text, danh sách ảnh đã chọn, đang gửi hay không.
class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key, required this.userName, this.userAvatar, this.editing});

  final String userName;
  final String? userAvatar;
  final Post? editing; // null = tạo mới

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  late final _controller = TextEditingController(text: widget.editing?.content ?? '');
  final List<PickedImage> _images = []; // ảnh đã chọn, chưa tải lên
  bool _saving = false; // chỉ dùng cho chế độ sửa (chế độ tạo dùng feed.creating)

  bool get _isEdit => widget.editing != null;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    try {
      final result = await pickImages(maxImagesPerPost - _images.length);
      if (!mounted) return;
      setState(() => _images.addAll(result.images));
      if (result.error != null) showAppError(context, result.error!);
    } catch (_) {
      if (mounted) showAppError(context, SocialStrings.imageReadError);
    }
  }

  Future<void> _submit() async {
    final feed = context.read<SocialFeedProvider>();
    setState(() => _saving = true);
    final error = _isEdit
        ? await feed.updatePost(widget.editing!.id, _controller.text)
        : await feed.createPost(_controller.text, _images);
    if (!mounted) return;
    setState(() => _saving = false);

    if (error != null) {
      showAppError(context, error);
      return;
    }
    showAppSuccess(context, _isEdit ? SocialStrings.editedOk : SocialStrings.createdOk);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final feed = context.watch<SocialFeedProvider>(); // ~ useContext
    final busy = _saving || feed.creating;
    final hasText = _controller.text.trim().isNotEmpty;
    final hasMedia = _isEdit ? widget.editing!.media.isNotEmpty : _images.isNotEmpty;
    final canPost = !busy && (hasText || hasMedia); // bài rỗng thì khóa nút Đăng

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_isEdit ? SocialStrings.editTitle : SocialStrings.createTitle),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
        actions: [
          AppButton(
            label: _isEdit ? SocialStrings.save : SocialStrings.post,
            loading: busy,
            onPressed: canPost ? _submit : null,
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: MaxWidthBox(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Người đăng
              Row(children: [
                AppAvatar(imageUrl: widget.userAvatar, name: widget.userName, size: 44),
                const SizedBox(width: 10),
                Text(widget.userName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              ]),
              const SizedBox(height: 12),

              // 2. Ô nhập chữ
              AppTextArea(
                controller: _controller,
                placeholder: SocialStrings.createHint,
                enabled: !busy,
                minHeight: 140,
                maxHeight: 320,
                onChanged: (_) => setState(() {}), // để nút Đăng cập nhật theo chữ
              ),

              // 3. Lỗi từ lần đăng trước (chế độ tạo)
              if (!_isEdit && feed.createError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(feed.createError!, style: const TextStyle(color: UiTokens.destructive)),
                ),

              // 4. Ảnh: chỉ khi tạo mới
              if (!_isEdit) ...[
                const SizedBox(height: 12),
                if (_images.isNotEmpty)
                  PickedImagesGrid(
                    images: _images,
                    uploads: feed.uploads,
                    canRemove: !busy,
                    onRemove: (i) => setState(() => _images.removeAt(i)),
                  ),
                const SizedBox(height: 12),
                AppButton(
                  label: '${SocialStrings.addPhotos} (${_images.length}/$maxImagesPerPost)',
                  icon: Icons.photo_library_outlined,
                  variant: AppButtonVariant.outline,
                  onPressed: busy || _images.length >= maxImagesPerPost ? null : _pick,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
