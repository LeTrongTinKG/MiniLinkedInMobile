-- Đăng nhập GitHub (F4): thêm cột githubId vào bảng users.
-- Cột trống (nullable) và duy nhất, không đụng dữ liệu cũ. Chạy lại nhiều lần vẫn an toàn.
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS "githubId" text UNIQUE;
