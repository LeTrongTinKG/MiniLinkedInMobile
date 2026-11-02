/// Đổi thời điểm thành câu "x phút trước" bằng tiếng Việt.
/// `now` chỉ để test truyền giờ giả; bình thường bỏ trống.
String timeAgo(DateTime time, {DateTime? now}) {
  final diff = (now ?? DateTime.now()).difference(time);

  if (diff.inMinutes < 1) return 'Vừa xong'; // cả trường hợp giờ máy lệch (số âm)
  if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
  if (diff.inHours < 24) return '${diff.inHours} giờ trước';
  if (diff.inDays < 7) return '${diff.inDays} ngày trước';
  if (diff.inDays < 30) return '${diff.inDays ~/ 7} tuần trước';
  if (diff.inDays < 365) return '${diff.inDays ~/ 30} tháng trước';
  return '${diff.inDays ~/ 365} năm trước';
}
