import 'package:app/ui_kit/app_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: Center(child: child)));

void main() {
  testWidgets('không có ảnh: hiện chữ cái đầu của tên', (t) async {
    await t.pumpWidget(_wrap(const AppAvatar(name: 'Hoàng Anh')));
    expect(find.text('H'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('không có tên: hiện dấu ?', (t) async {
    await t.pumpWidget(_wrap(const AppAvatar()));
    expect(find.text('?'), findsOneWidget);
  });

  testWidgets('ảnh lỗi: hiện chữ cái đầu, không ném lỗi, và KHÔNG tải lại lần sau', (t) async {
    // Môi trường test luôn trả lỗi HTTP cho ảnh mạng, giống Google trả 429
    const url = 'https://lh3.example.test/avatar-loi-429.png';
    await t.pumpWidget(_wrap(const AppAvatar(imageUrl: url, name: 'Hoàng Anh')));
    await t.pump();
    await t.pump(const Duration(milliseconds: 200));

    expect(find.text('H'), findsOneWidget); // lỗi thì hiện chữ cái đầu
    expect(t.takeException(), isNull); // không có lỗi đỏ ném ra

    // Vẽ lại một avatar cùng địa chỉ: phải bỏ qua mạng hoàn toàn (không còn widget Image)
    await t.pumpWidget(_wrap(const AppAvatar(imageUrl: url, name: 'Hoàng Anh', size: 36)));
    expect(find.byType(Image), findsNothing);
    expect(find.text('H'), findsOneWidget);
  });
}
