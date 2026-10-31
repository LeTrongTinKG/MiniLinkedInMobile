-- Chatbot kỹ năng và lộ trình (ADR-0008). Chạy lại nhiều lần vẫn an toàn.
-- Chạy xong thì chạy lại rls_lockdown.sql.

ALTER TABLE public.student_profiles ADD COLUMN IF NOT EXISTS "coachConsentAt" timestamp(3);
ALTER TABLE public.student_profiles ADD COLUMN IF NOT EXISTS "targetRole" text;

CREATE TABLE IF NOT EXISTS public.coach_usage (
  "userId" text NOT NULL REFERENCES public.users("id") ON DELETE CASCADE ON UPDATE CASCADE,
  "day"    text NOT NULL,
  "count"  integer NOT NULL DEFAULT 0,
  CONSTRAINT coach_usage_pkey PRIMARY KEY ("userId", "day"),
  CONSTRAINT coach_usage_count CHECK ("count" >= 0)
);
