import 'package:app/features/coach/presentation/widgets/chat_suggestions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ChatSuggestions renders header and suggestions', (tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatSuggestions(
            header: const ChatSuggestionsHeader(
              title: 'Gợi ý câu hỏi',
              description: 'Chạm để hỏi nhanh',
            ),
            content: ChatSuggestionsContent(
              children: [
                ChatSuggestion(
                  label: 'Tôi còn thiếu skill gì?',
                  onTap: () {
                    tapped = true;
                  },
                ),
                const ChatSuggestion(
                  label: 'Nút bị khóa',
                  enabled: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Gợi ý câu hỏi'), findsOneWidget);
    expect(find.text('Chạm để hỏi nhanh'), findsOneWidget);
    expect(find.text('Tôi còn thiếu skill gì?'), findsOneWidget);
    expect(find.text('Nút bị khóa'), findsOneWidget);

    await tester.tap(find.text('Tôi còn thiếu skill gì?'));
    expect(tapped, isTrue);
  });
}
