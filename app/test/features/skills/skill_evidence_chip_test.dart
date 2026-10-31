import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/skills/domain/models/skill_confidence.dart';
import 'package:app/features/skills/presentation/widgets/skill_evidence_chip.dart';

void main() {
  testWidgets('SkillEvidenceChip renders name and confidence badge', (tester) async {
    var tapped = false;
    var deleted = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SkillEvidenceChip(
            name: 'Flutter',
            confidence: SkillConfidence.evidenced,
            onTap: () => tapped = true,
            onDelete: () => deleted = true,
          ),
        ),
      ),
    );

    expect(find.text('Flutter'), findsOneWidget);
    expect(find.text('Có bằng chứng'), findsOneWidget);

    await tester.tap(find.text('Flutter'));
    expect(tapped, isTrue);

    await tester.tap(find.byIcon(Icons.close));
    expect(deleted, isTrue);
  });
}
