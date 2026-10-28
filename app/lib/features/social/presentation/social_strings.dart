/// Mọi chữ hiển thị của phần mạng xã hội gom ở đây (giống file constants/strings.js trong React).
/// Muốn đổi câu chữ chỉ cần sửa 1 chỗ này.
class SocialStrings {
  SocialStrings._();

  // ---- feed ----
  static const feedEmptyTitle = 'Chưa có bài viết nào';
  static const feedEmptyMessage = 'Hãy là người đầu tiên chia sẻ điều gì đó.';
  static const feedErrorTitle = 'Không tải được bảng tin';
  static const retry = 'Thử lại';
  static const composerHint = 'Bạn đang nghĩ gì?';
  static const composerPhoto = 'Ảnh';

  // ---- thẻ bài ----
  static const edited = 'Đã chỉnh sửa';
  static const menuEdit = 'Sửa';
  static const menuDelete = 'Xóa';
  static const seeMore = 'Xem thêm';
  static const sharedGone = 'Nội dung này không còn tồn tại';
  static const like = 'Thích';
  static const comment = 'Bình luận';
  static const share = 'Chia sẻ';
  static const deletePostTitle = 'Xóa bài viết?';
  static const deletePostMessage = 'Bài viết sẽ bị xóa vĩnh viễn.';
  static const deletedOk = 'Đã xóa bài viết';
  static String commentsCount(int n) => '$n bình luận';
  static String sharesCount(int n) => '$n lượt chia sẻ';
  static String moreImages(int n) => '+$n';

  // ---- soạn bài ----
  static const createTitle = 'Tạo bài viết';
  static const editTitle = 'Sửa bài viết';
  static const post = 'Đăng';
  static const save = 'Lưu';
  static const createHint = 'Bạn đang nghĩ gì?';
  static const addPhotos = 'Thêm ảnh';
  static const removeImage = 'Xóa ảnh';
  static const maxImagesError = 'Tối đa 6 ảnh cho mỗi bài viết';
  static const imageTypeError = 'Chỉ nhận ảnh JPG, PNG hoặc WebP';
  static const imageSizeError = 'Mỗi ảnh không được vượt quá 10MB';
  static const imageReadError = 'Không đọc được ảnh, hãy chọn ảnh khác';
  static const uploading = 'Đang tải lên...';
  static const uploadFailed = 'Tải lên lỗi';
  static const editedOk = 'Đã cập nhật bài viết';
  static const createdOk = 'Đã đăng bài viết';

  // ---- cảm xúc ----
  static const reactorsTitle = 'Cảm xúc';
  static const reactorsAll = 'Tất cả';
  static const reactorsEmpty = 'Chưa có ai thả cảm xúc';

  // ---- chia sẻ ----
  static const shareTitle = 'Chia sẻ bài viết';
  static const shareHint = 'Nói gì đó về bài viết này (không bắt buộc)';
  static const shareNow = 'Chia sẻ ngay';
  static const shareOk = 'Đã chia sẻ bài viết';
  static String shareOf(String name) => 'Bài viết của $name';

  // ---- bình luận ----
  static const commentsTitle = 'Bình luận';
  static const commentsEmpty = 'Chưa có bình luận nào';
  static const commentsEmptyMessage = 'Hãy là người đầu tiên bình luận.';
  static const commentsError = 'Không tải được bình luận';
  static const commentHint = 'Viết bình luận...';
  static const reply = 'Trả lời';
  static const send = 'Gửi';
  static const cancel = 'Hủy';
  static const commentEdited = '(đã chỉnh sửa)';
  static const loadMoreComments = 'Xem thêm bình luận';
  static const loadMoreReplies = 'Xem thêm phản hồi';
  static const deleteCommentTitle = 'Xóa bình luận?';
  static const deleteCommentMessage = 'Bình luận sẽ bị xóa vĩnh viễn.';
  static String viewReplies(int n) => 'Xem $n phản hồi';
  static String replyingTo(String name) => 'Đang trả lời $name';
}
