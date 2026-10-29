/// 1 trang kết quả phân trang theo cursor (đặt tên CursorPage để không trùng `Page` của Flutter).
class CursorPage<T> {
  const CursorPage({required this.items, this.nextCursor, this.hasMore = false});

  final List<T> items;
  final String? nextCursor; // gửi lại làm ?cursor= để lấy trang kế
  final bool hasMore;
}
