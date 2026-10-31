import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:app/features/consent/data/consent_remote_datasource.dart';
import 'package:app/features/consent/presentation/screens/analysis_consent_screen.dart';
import 'package:app/features/consent/presentation/viewmodels/consent_view_model.dart';

class FakeConsentRemoteDataSource implements ConsentRemoteDataSource {
  bool status = false;

  @override
  Future<bool> getConsentStatus() async => status;

  @override
  Future<void> updateConsent(bool granted) async {
    status = granted;
  }
}

void main() {
  group('AnalysisConsentScreen A11y & Interactions (F-006, F-019, Ticket 14)', () {
    testWidgets('renders all disclosures and meets 48dp minimum button height', (tester) async {
      final fakeDs = FakeConsentRemoteDataSource();
      final vm = ConsentViewModel(fakeDs);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: vm,
            child: const AnalysisConsentScreen(),
          ),
        ),
      );

      // Verify disclosures
      expect(find.text('Đồng ý phân tích tự động'), findsOneWidget);
      expect(find.text('Hệ thống sẽ đọc những dữ liệu sau:'), findsOneWidget);
      expect(find.text('Cam kết không bao giờ đọc:'), findsOneWidget);
      expect(find.text('Từ chối'), findsOneWidget);
      expect(find.text('Đồng ý & tiếp tục'), findsOneWidget);

      // Verify 48dp A11y button tap target height
      final declineBox = tester.getSize(find.widgetWithText(OutlinedButton, 'Từ chối'));
      final agreeBox = tester.getSize(find.widgetWithText(FilledButton, 'Đồng ý & tiếp tục'));
      expect(declineBox.height, greaterThanOrEqualTo(48.0));
      expect(agreeBox.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('choosing agree updates view model', (tester) async {
      final fakeDs = FakeConsentRemoteDataSource();
      final vm = ConsentViewModel(fakeDs);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: vm,
            child: const AnalysisConsentScreen(),
          ),
        ),
      );

      await tester.tap(find.text('Đồng ý & tiếp tục'));
      await tester.pumpAndSettle();

      expect(vm.granted, isTrue);
    });
  });
}

