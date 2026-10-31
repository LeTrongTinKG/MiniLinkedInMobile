-- Skill có bằng chứng (ADR-0005): bảng đề xuất skill từ GitHub + nguồn/bằng chứng cho user_skills.
-- Khớp schema.prisma. Chạy lại nhiều lần vẫn an toàn. Chạy xong thì chạy lại rls_lockdown.sql.

DO $$ BEGIN
  CREATE TYPE "SuggestionStatus" AS ENUM ('pending', 'accepted', 'rejected');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

ALTER TABLE public.user_skills ADD COLUMN IF NOT EXISTS "source" text NOT NULL DEFAULT 'self';
ALTER TABLE public.user_skills ADD COLUMN IF NOT EXISTS "evidence" jsonb;

CREATE TABLE IF NOT EXISTS public.skill_suggestions (
  "id"        text PRIMARY KEY,
  "userId"    text NOT NULL REFERENCES public.users("id") ON DELETE CASCADE ON UPDATE CASCADE,
  "skillName" text NOT NULL,
  "evidence"  jsonb NOT NULL,
  "status"    "SuggestionStatus" NOT NULL DEFAULT 'pending',
  "decidedAt" timestamp(3),
  "createdAt" timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" timestamp(3) NOT NULL,
  -- Đề xuất không có bằng chứng thì không được lưu.
  CONSTRAINT skill_suggestions_evidence_not_empty
    CHECK (jsonb_typeof("evidence") = 'array' AND jsonb_array_length("evidence") > 0)
);

CREATE UNIQUE INDEX IF NOT EXISTS "skill_suggestions_userId_skillName_key"
  ON public.skill_suggestions ("userId", "skillName");
CREATE INDEX IF NOT EXISTS "skill_suggestions_userId_status_idx"
  ON public.skill_suggestions ("userId", "status");
