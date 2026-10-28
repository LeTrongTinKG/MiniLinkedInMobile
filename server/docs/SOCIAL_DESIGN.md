# Module Social (mạng xã hội cho dev)

Đăng bài, ảnh, react, bình luận + trả lời, chia sẻ, sửa bài/bình luận. Tách hoàn toàn với code nhóm: mỗi tầng có thư mục con `social/`, dùng **SQL thuần** qua thư viện `pg` (không Prisma).

## Database

Schema Postgres riêng `social` (Prisma của nhóm không đụng tới). `public.users.id` là kiểu `text` nên mọi cột `author_id`/`user_id` cũng là `text`.

| Bảng | Ý nghĩa |
|---|---|
| `posts` | Bài viết. `shared_post_id` khác NULL = bài chia sẻ. Xóa mềm bằng `deleted_at` |
| `post_media` | Ảnh. `post_id = NULL` là ảnh mới upload chưa gắn bài (quá 24h là rác) |
| `post_reactions`, `comment_reactions` | Cảm xúc, khóa chính (đối tượng, user): mỗi người 1 cảm xúc |
| `comments` | Bình luận, `parent_id` khác NULL là trả lời (tối đa 2 cấp). Xóa mềm |
| `post_revisions` | Nội dung bài TRƯỚC mỗi lần sửa |
| `schema_migrations` | File SQL đã chạy |

Cảm xúc: `LIKE, LOVE, HAHA, WOW, SAD, ANGRY`.

Chạy migration: `node scripts/social/migrate.js` (file ở `sql/social/`). Dọn ảnh rác: `node scripts/social/cleanup-media.js`.

## API (`/api/social`, bắt buộc accessToken)

Thành công `{data, meta}`, lỗi `{error:{code,message}}`. Danh sách dùng cursor: `meta {nextCursor, hasMore}`; query `?cursor=&limit=` (limit mặc định 10, tối đa 30).

| Method + path | Việc |
|---|---|
| GET `/posts` | Feed |
| GET `/posts/:postId`, GET `/users/:userId/posts` | Một bài / bài của một người |
| POST `/posts` | Đăng `{content, mediaIds[]}` |
| PATCH `/posts/:postId` | Sửa (chỉ tác giả, lưu revision) |
| DELETE `/posts/:postId` | Xóa mềm (chỉ tác giả) |
| GET `/posts/:postId/revisions` | Lịch sử sửa |
| POST `/posts/:postId/shares` | Chia sẻ (share của share trỏ về bài gốc) |
| PUT / DELETE `/posts/:postId/reaction` | Thả/đổi, bỏ cảm xúc |
| GET `/posts/:postId/reactions?type=` | Ai đã react |
| GET / POST `/posts/:postId/comments` | Bình luận gốc / viết bình luận hoặc trả lời |
| GET `/comments/:commentId/replies` | Các trả lời |
| PATCH / DELETE `/comments/:commentId` | Sửa (người viết) / xóa mềm (người viết hoặc chủ bài) |
| PUT / DELETE `/comments/:commentId/reaction` | Cảm xúc cho bình luận |
| POST `/media` | Upload 1 ảnh (multipart field `file`) |

Mã lỗi: `POST_NOT_FOUND, COMMENT_NOT_FOUND, NOT_POST_OWNER, NOT_COMMENT_OWNER, POST_EMPTY, INVALID_REACTION_TYPE, MEDIA_NOT_FOUND, INVALID_FILE_TYPE, FILE_TOO_LARGE, INVALID_CURSOR`.

## Cursor

`cursor = base64url("<created_at>|<id>")` của dòng cuối trang trước. Server lấy `limit + 1` dòng: dư 1 dòng nghĩa là còn trang sau. So sánh theo cặp `(created_at, id)` nên không bị trùng/sót khi nhiều bài cùng giờ. Cursor sai định dạng trả 400 `INVALID_CURSOR`.

## Ảnh

Nén ảnh xem [IMAGE_COMPRESSION.md](IMAGE_COMPRESSION.md). Ảnh lưu ở bucket `SOCIAL_STORAGE_BUCKET` (mặc định `social-media`), đường dẫn `social/{userId}/{uuid}.webp` và `..._thumb.webp`.

## Cấu trúc file

`routes/social` → `controllers/social` → `services/social` → `repositories/social` → `lib/social/db.js`. Validate input ở `validations/social`, cursor ở `utils/social/cursor.js`.
