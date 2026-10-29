import '../../domain/entities/comment.dart';

/// Danh sách trả lời của 1 bình luận gốc (tải khi người dùng bấm "Xem n trả lời").
class RepliesState {
  List<Comment> items = [];
  bool loading = false;
  bool loaded = false; // đã tải trang đầu chưa
  bool hasMore = false;
  String? cursor;
  String? error;
}
