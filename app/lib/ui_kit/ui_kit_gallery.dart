import 'package:flutter/material.dart';

import 'ui_kit.dart';

// Màn hình xem thử mọi component của ui_kit (chỉ để dev xem, không gắn vào app).
class UiKitGallery extends StatefulWidget {
  const UiKitGallery({super.key});

  @override
  State<UiKitGallery> createState() => _UiKitGalleryState();
}

class _UiKitGalleryState extends State<UiKitGallery> {
  bool _loading = false;

  // Tiêu đề nhỏ cho từng nhóm
  Widget _section(String title, Widget child) => Padding(
        padding: const EdgeInsets.only(bottom: UiTokens.gapLarge * 1.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: UiTokens.gap),
            child,
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('UI Kit Gallery')),
      body: ListView(
        padding: const EdgeInsets.all(UiTokens.gapLarge),
        children: [
          _section(
            'AppButton',
            Wrap(spacing: 8, runSpacing: 8, children: [
              AppButton(label: 'Primary', onPressed: () {}),
              AppButton(
                  label: 'Secondary',
                  variant: AppButtonVariant.secondary,
                  onPressed: () {}),
              AppButton(
                  label: 'Outline',
                  variant: AppButtonVariant.outline,
                  icon: Icons.add,
                  onPressed: () {}),
              AppButton(
                  label: 'Ghost',
                  variant: AppButtonVariant.ghost,
                  onPressed: () {}),
              AppButton(
                  label: 'Destructive',
                  variant: AppButtonVariant.destructive,
                  onPressed: () {}),
              AppButton(label: 'Disabled', onPressed: null),
              AppButton(
                  label: _loading ? 'Đang gửi...' : 'Bấm để loading',
                  loading: _loading,
                  onPressed: () async {
                    setState(() => _loading = true);
                    await Future<void>.delayed(const Duration(seconds: 2));
                    if (mounted) setState(() => _loading = false);
                  }),
            ]),
          ),
          _section('AppButton full width',
              AppButton(label: 'Full width', fullWidth: true, onPressed: () {})),
          _section(
            'AppIconButton',
            Row(children: [
              AppIconButton(icon: Icons.favorite_border, onPressed: () {}),
              AppIconButton(
                  icon: Icons.share,
                  variant: AppButtonVariant.outline,
                  onPressed: () {}),
              AppIconButton(
                  icon: Icons.delete,
                  variant: AppButtonVariant.destructive,
                  onPressed: () {}),
            ]),
          ),
          _section(
            'AppAvatar',
            const Row(children: [
              AppAvatar(name: 'Anh', size: 48),
              SizedBox(width: 8),
              AppAvatar(name: '', size: 32),
              SizedBox(width: 8),
              AppAvatar(
                  imageUrl: 'https://invalid.example/x.png',
                  name: 'Bình',
                  size: 48),
            ]),
          ),
          _section(
            'AppBadge',
            const Wrap(spacing: 8, children: [
              AppBadge('Primary', variant: AppBadgeVariant.primary),
              AppBadge('Secondary'),
              AppBadge('Outline', variant: AppBadgeVariant.outline),
              AppBadge('Destructive', variant: AppBadgeVariant.destructive),
            ]),
          ),
          _section(
            'AppCard',
            const AppCard(
                title: 'Tiêu đề thẻ',
                description: 'Mô tả ngắn',
                child: Text('Nội dung thẻ')),
          ),
          _section('AppTextField',
              const AppTextField(placeholder: 'Nhập email', leadingIcon: Icons.mail)),
          _section('AppTextArea',
              const AppTextArea(placeholder: 'Viết bài...', maxLength: 200)),
          _section('AppDivider', const AppDivider()),
          _section(
            'AppSkeleton',
            const Row(children: [
              AppSkeleton(width: 48, height: 48, circle: true),
              SizedBox(width: 12),
              Expanded(child: AppSkeleton(height: 16)),
            ]),
          ),
          _section(
            'Dialog / Sheet / Toast',
            Wrap(spacing: 8, runSpacing: 8, children: [
              AppButton(
                label: 'Confirm dialog',
                variant: AppButtonVariant.outline,
                onPressed: () async {
                  final ok = await showAppConfirmDialog(context,
                      title: 'Xóa bài viết?',
                      message: 'Không thể hoàn tác.',
                      confirmLabel: 'Xóa',
                      destructive: true);
                  if (!context.mounted) return;
                  showAppToast(context, ok ? 'Đã xóa' : 'Đã hủy', isError: !ok);
                },
              ),
              AppButton(
                label: 'Bottom sheet',
                variant: AppButtonVariant.outline,
                onPressed: () => showAppBottomSheet<void>(context,
                    builder: (_) => const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('Nội dung bottom sheet'))),
              ),
              AppButton(
                  label: 'Toast OK',
                  variant: AppButtonVariant.outline,
                  onPressed: () => showAppSuccess(context, 'Thành công')),
              AppButton(
                  label: 'Toast lỗi',
                  variant: AppButtonVariant.outline,
                  onPressed: () => showAppError(context, 'Có lỗi xảy ra')),
            ]),
          ),
          _section(
            'AppEmptyState',
            const SizedBox(
                height: 220,
                child: AppEmptyState(
                    title: 'Chưa có dữ liệu', message: 'Hãy thử lại sau.')),
          ),
        ],
      ),
    );
  }
}
