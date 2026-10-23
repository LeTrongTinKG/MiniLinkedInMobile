-- Interactions: chuyển từ targetType/targetId (không khoá ngoại) sang quan hệ 1-N có FK:
--   User 1—N Reaction, Job 1—N Reaction, User 1—N Comment, Job 1—N Comment.
-- Hai bảng cũ chưa có dữ liệu thật (đã kiểm tra: 0 dòng) nên tạo lại.
-- Chạy: npx prisma db execute --file prisma/interactions_1n.sql --schema prisma/schema.prisma
-- (không dùng `db push` vì nó sẽ xoá cột users."tokenVersion" đang có trong DB nhưng thiếu trong schema)

DROP TABLE IF EXISTS "comments";
DROP TABLE IF EXISTS "reactions";
DROP TYPE IF EXISTS "InteractionTarget";

CREATE TABLE "reactions" (
  "id" TEXT NOT NULL,
  "userId" TEXT NOT NULL,
  "jobId" TEXT NOT NULL,
  "type" "ReactionType" NOT NULL,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "reactions_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "comments" (
  "id" TEXT NOT NULL,
  "userId" TEXT NOT NULL,
  "jobId" TEXT NOT NULL,
  "content" VARCHAR(1000) NOT NULL,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "comments_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "reactions_userId_jobId_key" ON "reactions"("userId", "jobId");
CREATE INDEX "reactions_jobId_idx" ON "reactions"("jobId");
CREATE INDEX "comments_jobId_createdAt_idx" ON "comments"("jobId", "createdAt");
CREATE INDEX "comments_userId_idx" ON "comments"("userId");

ALTER TABLE "reactions" ADD CONSTRAINT "reactions_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "reactions" ADD CONSTRAINT "reactions_jobId_fkey" FOREIGN KEY ("jobId") REFERENCES "jobs"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "comments" ADD CONSTRAINT "comments_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "comments" ADD CONSTRAINT "comments_jobId_fkey" FOREIGN KEY ("jobId") REFERENCES "jobs"("id") ON DELETE CASCADE ON UPDATE CASCADE;
