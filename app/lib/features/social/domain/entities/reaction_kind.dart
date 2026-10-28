/// 6 loại cảm xúc của server. `api` là chuỗi gửi/nhận qua JSON.
enum ReactionKind {
  like('LIKE', 'Thích', '👍'),
  love('LOVE', 'Yêu thích', '❤️'),
  haha('HAHA', 'Haha', '😆'),
  wow('WOW', 'Wow', '😮'),
  sad('SAD', 'Buồn', '😢'),
  angry('ANGRY', 'Phẫn nộ', '😡');

  const ReactionKind(this.api, this.label, this.emoji);

  final String api; // chuỗi server dùng, vd 'LIKE'
  final String label; // nhãn tiếng Việt
  final String emoji;

  /// Chuỗi server -> enum. Không nhận ra thì trả null (không crash).
  static ReactionKind? fromApi(String? value) {
    for (final k in values) {
      if (k.api == value) return k;
    }
    return null;
  }
}
