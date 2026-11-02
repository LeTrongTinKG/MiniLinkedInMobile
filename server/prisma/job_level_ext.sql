-- Thêm cấp độ mới cho enum JobLevel (chạy lại nhiều lần vẫn an toàn)
ALTER TYPE "JobLevel" ADD VALUE IF NOT EXISTS 'mid';
ALTER TYPE "JobLevel" ADD VALUE IF NOT EXISTS 'senior';
ALTER TYPE "JobLevel" ADD VALUE IF NOT EXISTS 'lead';
