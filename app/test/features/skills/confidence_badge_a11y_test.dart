import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/skills/domain/models/skill_confidence.dart';
import 'package:app/features/skills/presentation/widgets/confidence_badge.dart';

void main() {
  group('ConfidenceBadge A11y & Rendering (F-008, F-009, F-010, F-019)', () {
    testWidgets('renders self-claimed badge with correct semantics', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConfidenceBadge(confidence: SkillConfidence.selfClaimed),
          ),
        ),
      );

      expect(find.text('Tự khai'), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
      expect(
        tester.getSemantics(find.byType(ConfidenceBadge)),
        matchesSemantics(label: 'Mức tin cậy: Tự khai'),
      );
    });

    testWidgets('renders evidenced badge with correct semantics', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConfidenceBadge(confidence: SkillConfidence.evidenced),
          ),
        ),
      );

      expect(find.text('Có bằng chứng'), findsOneWidget);
      expect(find.byIcon(Icons.link), findsOneWidget);
      expect(
        tester.getSemantics(find.byType(ConfidenceBadge)),
        matchesSemantics(label: 'Mức tin cậy: Có bằng chứng'),
      );
    });

    testWidgets('renders endorsed badge with correct semantics', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConfidenceBadge(confidence: SkillConfidence.endorsed),
          ),
        ),
      );

      expect(find.text('Được xác nhận'), findsOneWidget);
      expect(find.byIcon(Icons.verified_outlined), findsOneWidget);
      expect(
        tester.getSemantics(find.byType(ConfidenceBadge)),
        matchesSemantics(label: 'Mức tin cậy: Được xác nhận'),
      );
    });
  });
}

