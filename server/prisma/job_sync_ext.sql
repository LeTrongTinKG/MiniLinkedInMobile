-- Job Sync: cho phép job nguồn ngoài (không có recruiter) + thông tin nguồn + nhật ký lượt chạy.
-- Idempotent (chạy lại nhiều lần không lỗi).
-- Chạy: npx prisma db execute --file prisma/job_sync_ext.sql --schema prisma/schema.prisma
-- (không dùng `db push` vì nó sẽ xoá cột users."tokenVersion" đang có trong DB nhưng thiếu trong schema)

-- 1. Kiểu enum nguồn job
DO $$ BEGIN
  CREATE TYPE "JobSource" AS ENUM ('internal', 'jsearch', 'serpapi', 'remotive');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- 2. recruiterId cho phép NULL
ALTER TABLE "jobs" ALTER COLUMN "recruiterId" DROP NOT NULL;

-- 3. Cột mới
ALTER TABLE "jobs" ADD COLUMN IF NOT EXISTS "source" "JobSource" NOT NULL DEFAULT 'internal';
ALTER TABLE "jobs" ADD COLUMN IF NOT EXISTS "externalId" TEXT;
ALTER TABLE "jobs" ADD COLUMN IF NOT EXISTS "applyUrl" TEXT;
ALTER TABLE "jobs" ADD COLUMN IF NOT EXISTS "salaryCurrency" TEXT;
ALTER TABLE "jobs" ADD COLUMN IF NOT EXISTS "dedupeKey" TEXT;
ALTER TABLE "jobs" ADD COLUMN IF NOT EXISTS "lastSeenAt" TIMESTAMP(3);

-- 4. Index
CREATE UNIQUE INDEX IF NOT EXISTS "jobs_source_externalId_key" ON "jobs"("source", "externalId");
CREATE INDEX IF NOT EXISTS "jobs_dedupeKey_idx" ON "jobs"("dedupeKey");

-- 5. Bảng nhật ký
CREATE TABLE IF NOT EXISTS "job_sync_runs" (
  "id" TEXT NOT NULL,
  "startedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "finishedAt" TIMESTAMP(3),
  "dryRun" BOOLEAN NOT NULL DEFAULT false,
  "stats" JSONB,
  CONSTRAINT "job_sync_runs_pkey" PRIMARY KEY ("id")
);
