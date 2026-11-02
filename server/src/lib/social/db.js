// Kết nối Postgres thuần (thư viện pg) cho module social.
const { Pool } = require("pg");

// Prisma cho phép thêm ?pgbouncer=true&pool_timeout=... vào URL, còn pg thì không hiểu -> bỏ phần sau dấu ?
function cleanUrl(url) {
  if (!url) return url;
  return url.split("?")[0];
}

// Pool tạo muộn (lần gọi đầu tiên) vì index.js đọc file .env SAU khi require các route
let realPool = null;
function getPool() {
  if (realPool) return realPool;
  realPool = new Pool({
    connectionString: cleanUrl(process.env.DATABASE_URL),
    max: 3, // ít kết nối thôi vì Supabase pooler có giới hạn
    idleTimeoutMillis: 10000,
    ssl: { rejectUnauthorized: false }, // Supabase bắt buộc SSL
  });
  // Lỗi của kết nối đang rảnh không được làm sập server
  realPool.on('error', (err) => console.error('[social-db] lỗi kết nối rảnh:', err.message));
  return realPool;
}

// pool.query(...) dùng y như pg.Pool thật
const pool = {
  query: (...args) => getPool().query(...args),
  connect: () => getPool().connect(),
  end: async () => {
    if (realPool) await realPool.end();
    realPool = null;
  },
};

// Chạy nhiều câu lệnh trong 1 transaction: xong hết thì COMMIT, lỗi thì ROLLBACK
async function withTransaction(work) {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const result = await work(client);
    await client.query("COMMIT");
    return result;
  } catch (err) {
    await client.query("ROLLBACK").catch(() => {});
    throw err;
  } finally {
    client.release();
  }
}

module.exports = { pool, withTransaction, cleanUrl };
