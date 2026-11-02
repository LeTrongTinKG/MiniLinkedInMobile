-- Độ tin cậy theo commit + hạn mức quét (ADR-0007). Chạy lại nhiều lần vẫn an toàn.
-- Chạy xong thì chạy lại rls_lockdown.sql.

ALTER TABLE public.user_skills ADD COLUMN IF NOT EXISTS "confidence" text NOT NULL DEFAULT 'self_claimed';
ALTER TABLE public.user_skills ADD COLUMN IF NOT EXISTS "confidenceReason" text;

CREATE TABLE IF NOT EXISTS public.skill_scans (
  "id"         text PRIMARY KEY,
  "userId"     text NOT NULL REFERENCES public.users("id") ON DELETE CASCADE ON UPDATE CASCADE,
  "status"     text NOT NULL,
  "createdAt"  timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "finishedAt" timestamp(3),
  CONSTRAINT skill_scans_status CHECK ("status" IN ('running', 'succeeded', 'failed'))
);

CREATE INDEX IF NOT EXISTS "skill_scans_userId_status_createdAt_idx"
  ON public.skill_scans ("userId", "status", "createdAt");
