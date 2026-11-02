import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_spacing.dart';
import '../../../../ui_kit/ui_kit.dart';
import '../../domain/entities/post.dart';
import '../../domain/entities/uploaded_media.dart';
import '../providers/social_feed_provider.dart';
import '../social_strings.dart';
import '../utils/pick_images.dart';
import '../widgets/code_snippet_box.dart';
import '../widgets/max_width_box.dart';
import '../widgets/picked_images_grid.dart';

/// Màn soạn bài theo thiết kế v0 hỗ trợ tải ảnh và chèn Code Snippet IDE.
class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key, required this.userName, this.userAvatar, this.editing});

  final String userName;
  final String? userAvatar;
  final Post? editing;

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  late final _controller = TextEditingController(text: widget.editing?.content ?? '');
  final List<PickedImage> _images = [];
  bool _saving = false;
  bool _showCode = false;

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
    final feed = context.watch<SocialFeedProvider>();
    final busy = _saving || feed.creating;
    final hasText = _controller.text.trim().isNotEmpty;
    final hasMedia = _isEdit ? widget.editing!.media.isNotEmpty : _images.isNotEmpty;
    final canPost = !busy && (hasText || hasMedia);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          _isEdit ? SocialStrings.editTitle : SocialStrings.createTitle,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: AppButton(
              label: _isEdit ? SocialStrings.save : SocialStrings.post,
              loading: busy,
              size: AppButtonSize.small,
              onPressed: canPost ? _submit : null,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      body: MaxWidthBox(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                AppAvatar(imageUrl: widget.userAvatar, name: widget.userName, size: 44),
                const SizedBox(width: 10),
                Text(
                  widget.userName,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.textPrimary),
                ),
              ]),
              const SizedBox(height: 12),
              AppTextArea(
                controller: _controller,
                placeholder: SocialStrings.createHint,
                enabled: !busy,
                minHeight: 140,
                maxHeight: 300,
                onChanged: (_) => setState(() {}),
              ),
              if (!_isEdit && feed.createError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: AppErrorBanner(message: feed.createError!, onRetry: canPost ? _submit : null),
                ),
              if (!_isEdit) ...[
                const SizedBox(height: 12),
                if (_images.isNotEmpty)
                  PickedImagesGrid(
                    images: _images,
                    uploads: feed.uploads,
                    canRemove: !busy,
                    onRemove: (i) => setState(() => _images.removeAt(i)),
                  ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: '${SocialStrings.addPhotos} (${_images.length}/$maxImagesPerPost)',
                        icon: Icons.photo_library_outlined,
                        variant: AppButtonVariant.outline,
                        onPressed: busy || _images.length >= maxImagesPerPost ? null : _pick,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.outlined(
                      icon: Icon(_showCode ? Icons.code_off_rounded : Icons.code_rounded),
                      tooltip: 'Đoạn mã code snippet',
                      onPressed: () => setState(() => _showCode = !_showCode),
                    ),
                  ],
                ),
                if (_showCode) ...[
                  const SizedBox(height: 10),
                  CodeSnippetBox(
                    onInsert: () {
                      const snippet = '```dart\nclass MiniLinkedInApp extends StatelessWidget {\n  const MiniLinkedInApp({super.key});\n}\n```';
                      setState(() {
                        _controller.text = _controller.text.isEmpty ? snippet : '${_controller.text}\n\n$snippet';
                        _showCode = false;
                      });
                    },
                    onClose: () => setState(() => _showCode = false),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
