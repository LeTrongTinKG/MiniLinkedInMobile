// Chạy: node scripts/social/migrate.js
// Chạy các file sql/social/*.sql chưa chạy (theo thứ tự tên), ghi vào social.schema_migrations.
require("dotenv").config({ quiet: true });
const fs = require("node:fs");
const path = require("node:path");
const { pool, withTransaction } = require("../../src/lib/social/db");

const SQL_DIR = path.join(__dirname, "..", "..", "sql", "social");

async function main() {
  // Bảng ghi lại file nào đã chạy
  await pool.query("CREATE SCHEMA IF NOT EXISTS social");
  await pool.query(
    `CREATE TABLE IF NOT EXISTS social.schema_migrations (
       name text PRIMARY KEY,
       applied_at timestamptz NOT NULL DEFAULT now()
     )`
  );
  const done = await pool.query("SELECT name FROM social.schema_migrations");
  const doneNames = done.rows.map((r) => r.name);

  const files = fs.readdirSync(SQL_DIR).filter((f) => f.endsWith(".sql")).sort();
  for (const file of files) {
    if (doneNames.includes(file)) {
      console.log(`Bỏ qua (đã chạy): ${file}`);
      continue;
    }
    const sql = fs.readFileSync(path.join(SQL_DIR, file), "utf8");
    // Mỗi file chạy trong 1 transaction: lỗi thì không để lại bảng dở dang
    await withTransaction(async (client) => {
      await client.query(sql);
      await client.query("INSERT INTO social.schema_migrations (name) VALUES ($1)", [file]);
    });
    console.log(`Đã chạy: ${file}`);
  }
}

main()
  .catch((err) => {
    console.error("Migrate lỗi:", err.message);
    process.exitCode = 1;
  })
  .finally(() => pool.end());
