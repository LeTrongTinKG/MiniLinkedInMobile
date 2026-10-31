-- Đóng cửa sau (ADR-0006): ai cầm anon key của Supabase cũng không đọc/ghi thẳng được bảng nào.
-- Server Node nối bằng tài khoản chủ bảng (postgres) nên không bị chặn; quyền từng người vẫn do server kiểm.
-- Chạy lại nhiều lần vẫn an toàn. Chạy lại sau mỗi lần thêm bảng (prisma db push hoặc file *_ext.sql).
-- Kiểm tra sau khi chạy: node scripts/check-rls.js

DO $$
DECLARE
  t record;
  has_supabase_roles boolean := EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'anon')
                            AND EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'authenticated');
BEGIN
  -- Bật khóa dòng trên mọi bảng, không viết policy nào: anon/authenticated không thấy dòng nào.
  FOR t IN
    SELECT schemaname, tablename FROM pg_tables WHERE schemaname IN ('public', 'social')
  LOOP
    EXECUTE format('ALTER TABLE %I.%I ENABLE ROW LEVEL SECURITY', t.schemaname, t.tablename);
  END LOOP;

  IF NOT has_supabase_roles THEN
    RETURN;
  END IF;

  -- View và sequence không có khóa dòng nên phải thu quyền riêng.
  FOR t IN
    SELECT n.nspname AS schemaname, c.relname AS tablename
    FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE n.nspname IN ('public', 'social') AND c.relkind IN ('r', 'p', 'v', 'm', 'f', 'S')
  LOOP
    EXECUTE format('REVOKE ALL ON %I.%I FROM anon, authenticated', t.schemaname, t.tablename);
  END LOOP;

  -- Bảng tạo sau này bởi postgres cũng không tự cấp quyền cho anon/authenticated.
  FOR t IN SELECT nspname AS schemaname FROM pg_namespace WHERE nspname IN ('public', 'social') LOOP
    EXECUTE format('ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA %I REVOKE ALL ON TABLES FROM anon, authenticated', t.schemaname);
    EXECUTE format('ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA %I REVOKE ALL ON SEQUENCES FROM anon, authenticated', t.schemaname);
  END LOOP;
END $$;
