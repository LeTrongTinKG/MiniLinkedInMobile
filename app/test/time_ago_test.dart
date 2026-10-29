import 'package:app/features/social/presentation/utils/time_ago.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 6, 30, 12);
  String ago(Duration d) => timeAgo(now.subtract(d), now: now);

  test('timeAgo đúng từng mốc tiếng Việt', () {
    expect(ago(const Duration(seconds: 20)), 'Vừa xong');
    expect(ago(const Duration(minutes: 5)), '5 phút trước');
    expect(ago(const Duration(hours: 3)), '3 giờ trước');
    expect(ago(const Duration(days: 2)), '2 ngày trước');
    expect(ago(const Duration(days: 14)), '2 tuần trước');
    expect(ago(const Duration(days: 90)), '3 tháng trước');
    expect(ago(const Duration(days: 800)), '2 năm trước');
  });

  test('giờ trong tương lai (máy lệch giờ) không bị số âm', () {
    expect(timeAgo(now.add(const Duration(minutes: 10)), now: now), 'Vừa xong');
  });
}
