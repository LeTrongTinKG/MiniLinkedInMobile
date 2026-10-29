-- Module mạng xã hội: toàn bộ bảng nằm trong schema riêng "social"
-- (Prisma của nhóm không đụng tới schema này).
-- Lưu ý: public.users.id là kiểu TEXT nên author_id/user_id cũng là TEXT.

CREATE SCHEMA IF NOT EXISTS social;

-- Bài viết (xóa mềm bằng deleted_at). shared_post_id != NULL nghĩa là bài chia sẻ.
CREATE TABLE social.posts (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  author_id      text NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  content        text NOT NULL DEFAULT '',
  shared_post_id uuid REFERENCES social.posts(id),
  edited_at      timestamptz,
  deleted_at     timestamptz,
  created_at     timestamptz NOT NULL DEFAULT now(),
  updated_at     timestamptz NOT NULL DEFAULT now()
);
-- Feed: mới nhất trước, trùng giờ thì so thêm id
CREATE INDEX posts_feed_idx ON social.posts (created_at DESC, id DESC) WHERE deleted_at IS NULL;
CREATE INDEX posts_author_idx ON social.posts (author_id, created_at DESC, id DESC) WHERE deleted_at IS NULL;
CREATE INDEX posts_shared_idx ON social.posts (shared_post_id) WHERE shared_post_id IS NOT NULL;

-- Ảnh của bài. post_id = NULL nghĩa là ảnh vừa upload, chưa gắn bài.
CREATE TABLE social.post_media (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id      uuid REFERENCES social.posts(id) ON DELETE CASCADE,
  uploader_id  text NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  url          text NOT NULL,
  thumbnail_url text,
  storage_path text NOT NULL,
  type         text NOT NULL DEFAULT 'image' CHECK (type IN ('image')),
  position     int NOT NULL DEFAULT 0,
  width        int,
  height       int,
  created_at   timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX post_media_post_idx ON social.post_media (post_id, position);
CREATE INDEX post_media_orphan_idx ON social.post_media (created_at) WHERE post_id IS NULL;

-- Cảm xúc vào bài: mỗi người 1 cảm xúc / 1 bài
CREATE TABLE social.post_reactions (
  post_id    uuid NOT NULL REFERENCES social.posts(id) ON DELETE CASCADE,
  user_id    text NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  type       text NOT NULL CHECK (type IN ('LIKE','LOVE','HAHA','WOW','SAD','ANGRY')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (post_id, user_id)
);
CREATE INDEX post_reactions_type_idx ON social.post_reactions (post_id, type, created_at DESC);

-- Bình luận: parent_id != NULL là trả lời (tối đa 2 cấp)
CREATE TABLE social.comments (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id    uuid NOT NULL REFERENCES social.posts(id) ON DELETE CASCADE,
  author_id  text NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  parent_id  uuid REFERENCES social.comments(id) ON DELETE CASCADE,
  content    varchar(1000) NOT NULL,
  edited_at  timestamptz,
  deleted_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX comments_post_idx ON social.comments (post_id, created_at, id) WHERE parent_id IS NULL;
CREATE INDEX comments_parent_idx ON social.comments (parent_id, created_at, id) WHERE parent_id IS NOT NULL;

CREATE TABLE social.comment_reactions (
  comment_id uuid NOT NULL REFERENCES social.comments(id) ON DELETE CASCADE,
  user_id    text NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  type       text NOT NULL CHECK (type IN ('LIKE','LOVE','HAHA','WOW','SAD','ANGRY')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (comment_id, user_id)
);

-- Lịch sử sửa bài: lưu nội dung TRƯỚC khi sửa
CREATE TABLE social.post_revisions (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id        uuid NOT NULL REFERENCES social.posts(id) ON DELETE CASCADE,
  content_before text NOT NULL,
  edited_at      timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX post_revisions_idx ON social.post_revisions (post_id, edited_at DESC);
