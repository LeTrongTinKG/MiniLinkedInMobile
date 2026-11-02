import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/interactions/data/datasources/interaction_mock_datasource.dart';
import 'package:app/features/interactions/data/repositories/interaction_repository_impl.dart';
import 'package:app/features/interactions/domain/repositories/interaction_repository.dart';
import 'package:app/features/interactions/presentation/providers/interaction_provider.dart';
import 'package:app/features/jobs/data/models/job_model.dart';
import 'package:app/features/jobs/presentation/widgets/job_card.dart';
import 'package:app/ui_kit/app_shad_theme.dart';
import 'package:app/ui_kit/ui_kit.dart';
import 'package:app/ui_kit/ui_kit_gallery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

// Dựng đúng cấu trúc gốc app như main.dart: ShadApp.custom > MaterialApp
Widget _app(Widget home, {ThemeData? theme}) {
  return ShadApp.custom(
    theme: buildAppShadTheme(),
    appBuilder: (context) => MaterialApp(
      theme: theme,
      builder: (context, child) => ShadAppBuilder(child: child!),
      home: Scaffold(body: home),
    ),
  );
}

void main() {
  testWidgets('Gallery (mọi component) dựng không lỗi', (t) async {
    t.view.physicalSize = const Size(800, 3000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(_app(const UiKitGallery()));
    await t.pump();
    expect(t.takeException(), isNull);
    expect(find.byType(AppButton), findsWidgets);
    expect(find.byType(AppTextArea), findsOneWidget);
  });

  testWidgets('Từng component dựng không lỗi', (t) async {
    await t.pumpWidget(_app(SingleChildScrollView(
      child: Column(children: [
        for (final v in AppButtonVariant.values) ...[
          AppButton(label: 'Nút ${v.name}', variant: v, onPressed: () {}),
          AppIconButton(icon: Icons.add, variant: v, onPressed: () {}),
        ],
        const AppAvatar(name: 'An'),
        const AppAvatar(),
        const AppBadge('x'),
        const AppCard(title: 'T', child: Text('c')),
        const AppTextField(placeholder: 'p'),
        AppSegmentedTab(
          tabs: const ['T1', 'T2'],
          selectedIndex: 0,
          onTabChanged: (_) {},
        ),
        const AppTextArea(placeholder: 'p', maxLength: 50),
        const AppDivider(),
        const AppSkeleton(height: 10),
        const SizedBox(height: 200, child: AppEmptyState(title: 'Trống')),
      ]),
    )));
    await t.pump();
    expect(t.takeException(), isNull);
  });

  testWidgets('Nút loading không bấm được, nút thường bấm được', (t) async {
    var clicks = 0;
    await t.pumpWidget(_app(Column(children: [
      AppButton(label: 'Dang tai', loading: true, onPressed: () => clicks++),
      AppButton(label: 'Binh thuong', onPressed: () => clicks += 10),
    ])));
    await t.tap(find.text('Dang tai'));
    await t.pump();
    expect(clicks, 0);
    await t.tap(find.text('Binh thuong'));
    await t.pump();
    expect(clicks, 10);
  });

  Future<void> runDialog(WidgetTester t, String tapLabel, bool expected) async {
    bool? result;
    await t.pumpWidget(_app(Builder(
      builder: (ctx) => AppButton(
        label: 'Mo',
        onPressed: () async => result = await showAppConfirmDialog(ctx,
            title: 'Xoa?', message: 'Chac chua?', confirmLabel: 'Co', cancelLabel: 'Khong'),
      ),
    )));
    await t.tap(find.text('Mo'));
    await t.pumpAndSettle();
    await t.tap(find.text(tapLabel));
    await t.pumpAndSettle();
    expect(result, expected);
  }

  testWidgets('showAppConfirmDialog trả true khi đồng ý', (t) => runDialog(t, 'Co', true));
  testWidgets('showAppConfirmDialog trả false khi hủy', (t) => runDialog(t, 'Khong', false));

  testWidgets('Màn hình cũ (JobCard) vẫn dựng với gốc app mới, giữ AppTheme', (t) async {
    final repo = InteractionRepositoryImpl(InteractionMockDataSource());
    final job = JobModel.fromJson({
      'id': 'j1', 'recruiterId': 'r1', 'title': 'Flutter Dev', 'companyName': 'ABC',
      'location': 'Hà Nội', 'workMode': 'hybrid', 'level': 'intern',
      'salaryMin': 500, 'salaryMax': 800, 'description': 'Mo ta',
      'requiredSkills': ['Flutter'], 'niceToHave': [], 'status': 'open',
      'createdAt': '2026-10-20T10:00:00.000Z',
    }).toEntity();
    await t.pumpWidget(MultiProvider(
      providers: [
        Provider<InteractionRepository>.value(value: repo),
        ChangeNotifierProvider(create: (_) => InteractionProvider(repo)),
      ],
      child: _app(JobCard(job: job), theme: AppTheme.lightTheme),
    ));
    await t.pump(const Duration(milliseconds: 600)); // chờ timer giả lập mạng của mock
    expect(t.takeException(), isNull);
    expect(find.text('Flutter Dev'), findsWidgets);
    // Theme Material của nhóm không bị đổi bởi shad
    final ctx = t.element(find.byType(JobCard));
    expect(Theme.of(ctx).colorScheme.primary, AppTheme.lightTheme.colorScheme.primary);
  });

  testWidgets('AppTextField hien errorText inline va trailingIcon', (t) async {
    var trailingTapped = false;
    await t.pumpWidget(_app(AppTextField(
      placeholder: 'Nhap email',
      errorText: 'Email khong hop le',
      trailingIcon: Icons.visibility,
      onTrailingTap: () => trailingTapped = true,
    )));
    expect(find.text('Email khong hop le'), findsOneWidget);
    expect(find.byIcon(Icons.visibility), findsOneWidget);
    await t.tap(find.byIcon(Icons.visibility));
    expect(trailingTapped, isTrue);
  });

  testWidgets('AppSegmentedTab chuyen tab khi bam', (t) async {
    var index = 0;
    await t.pumpWidget(_app(StatefulBuilder(
      builder: (ctx, setState) => AppSegmentedTab(
        tabs: const ['Dang nhap', 'Dang ky'],
        selectedIndex: index,
        onTabChanged: (i) => setState(() => index = i),
      ),
    )));
    expect(find.text('Dang nhap'), findsOneWidget);
    expect(find.text('Dang ky'), findsOneWidget);
    await t.tap(find.text('Dang ky'));
    await t.pumpAndSettle();
    expect(index, 1);
  });

  testWidgets('AppButton vung cham toi thieu >= 48dp', (t) async {
    await t.pumpWidget(_app(AppButton(label: 'Bam', onPressed: () {})));
    final size = t.getSize(find.byType(AppButton));
    expect(size.height, greaterThanOrEqualTo(48.0));
  });

  testWidgets('AppEmptyState hien 2 nut hanh dong giai cuu luong cut', (t) async {
    var primaryTapped = false;
    var secondaryTapped = false;
    await t.pumpWidget(_app(AppEmptyState(
      title: 'Chua co don',
      message: 'Hay tim viec lam ngay',
      actionLabel: 'Tim viec',
      onAction: () => primaryTapped = true,
      secondaryActionLabel: 'Ve trang chu',
      onSecondaryAction: () => secondaryTapped = true,
    )));
    expect(find.text('Chua co don'), findsOneWidget);
    expect(find.text('Tim viec'), findsOneWidget);
    expect(find.text('Ve trang chu'), findsOneWidget);
    await t.tap(find.text('Tim viec'));
    expect(primaryTapped, isTrue);
    await t.tap(find.text('Ve trang chu'));
    expect(secondaryTapped, isTrue);
  });

  testWidgets('AppErrorBanner hien thong bao loi va nut thu lai', (t) async {
    var retryCalled = false;
    await t.pumpWidget(_app(AppErrorBanner(
      message: 'Mat ket noi mang',
      onRetry: () => retryCalled = true,
    )));
    expect(find.text('Mat ket noi mang'), findsOneWidget);
    expect(find.text('Thử lại'), findsOneWidget);
    await t.tap(find.text('Thử lại'));
    expect(retryCalled, isTrue);
  });
}
