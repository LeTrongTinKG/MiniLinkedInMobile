// Kiểm tra cửa sau đã đóng chưa (ADR-0006). Chỉ đọc, không sửa gì.
// Chạy: cd server && node scripts/check-rls.js   (dùng DATABASE_URL trong .env)
// Thoát mã 1 nếu còn bảng chưa bật khóa dòng hoặc anon/authenticated còn quyền.
require("dotenv").config();
const { Client } = require("pg");

const url = (process.env.DATABASE_URL || "").split("?")[0];
const local = /@(localhost|127\.0\.0\.1)[:/]/.test(url);

async function main() {
  const client = new Client({ connectionString: url, ssl: local ? false : { rejectUnauthorized: false } });
  await client.connect();
  try {
    const noRls = await client.query(`
      SELECT n.nspname || '.' || c.relname AS name
      FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
      WHERE n.nspname IN ('public', 'social') AND c.relkind IN ('r', 'p') AND NOT c.relrowsecurity
      ORDER BY 1`);
    const open = await client.query(`
      SELECT r.rolname || ' -> ' || n.nspname || '.' || c.relname AS name
      FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
      JOIN pg_roles r ON r.rolname IN ('anon', 'authenticated')
      WHERE n.nspname IN ('public', 'social') AND c.relkind IN ('r', 'p', 'v', 'm', 'f')
        AND has_table_privilege(r.oid, c.oid, 'SELECT, INSERT, UPDATE, DELETE')
      ORDER BY 1`);
    for (const row of noRls.rows) console.log(`Chưa bật khóa dòng: ${row.name}`);
    for (const row of open.rows) console.log(`Còn mở quyền: ${row.name}`);
    if (noRls.rowCount + open.rowCount > 0) {
      console.log("=> Chạy prisma/rls_lockdown.sql rồi kiểm tra lại.");
      process.exitCode = 1;
    } else {
      console.log("OK: mọi bảng đã bật khóa dòng, anon/authenticated không còn quyền.");
    }
  } finally {
    await client.end();
  }
}

main().catch((error) => {
  console.error("Không kiểm tra được:", error.message);
  process.exitCode = 2;
});
