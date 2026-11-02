// Tạo 5 tài khoản demo + 5 bài mỗi người qua API thật. Chạy: node scripts/social/seed-demo.js
const path = require("path");
const fs = require("fs");
const crypto = require("crypto");

// Nạp .env TRƯỚC khi require app (để Prisma/pg có DATABASE_URL)
require("dotenv").config({ path: path.join(__dirname, "../../.env") });
const app = require("../../src/index");
const { prisma } = require("../../src/lib/prisma");
const { pool } = require("../../src/lib/social/db");
const { ACCOUNTS, POSTS } = require("./demo-data");

const CRED_FILE = path.join(__dirname, "demo-accounts.local.txt");
const POSTS_PER_USER = 5;
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

// Mật khẩu ngẫu nhiên mạnh: đủ chữ hoa, thường, số (16 ký tự)
function genPassword() {
  const U = "ABCDEFGHJKLMNPQRSTUVWXYZ", L = "abcdefghijkmnpqrstuvwxyz", D = "23456789";
  const pick = (set) => set[crypto.randomInt(set.length)];
  const chars = [pick(U), pick(L), pick(D), pick(U), pick(L), pick(D)];
  while (chars.length < 16) chars.push(pick(U + L + D));
  return chars.sort(() => crypto.randomInt(3) - 1).join("");
}

// Đọc file thông tin đăng nhập cũ (nếu có) -> { email: matKhau }
function loadSavedPasswords() {
  const saved = {};
  if (!fs.existsSync(CRED_FILE)) return saved;
  let email = null;
  for (const line of fs.readFileSync(CRED_FILE, "utf8").split(/\r?\n/)) {
    if (line.startsWith("Email: ")) email = line.slice(7).trim();
    else if (line.startsWith("Mật khẩu: ") && email) saved[email] = line.slice(10).trim();
  }
  return saved;
}

// Ghi file thông tin đăng nhập (dễ copy: mỗi giá trị một dòng riêng)
function saveCredentials(accounts) {
  const head = "CẢNH BÁO: file nội bộ, KHÔNG commit lên git.\n\n";
  const body = accounts
    .map((a, i) => `=== Tài khoản ${i + 1}: ${a.fullName} ===\nEmail: ${a.email}\nMật khẩu: ${a.password}\n`)
    .join("\n");
  fs.writeFileSync(CRED_FILE, head + body, "utf8");
}

async function main() {
  // Mở server trên cổng ngẫu nhiên, gọi API bằng fetch
  const server = app.listen(0, "127.0.0.1");
  await new Promise((r) => server.once("listening", r));
  const base = `http://127.0.0.1:${server.address().port}`;
  const call = async (method, url, body, token) => {
    const res = await fetch(base + url, {
      method,
      headers: { "Content-Type": "application/json", ...(token ? { Authorization: `Bearer ${token}` } : {}) },
      body: body ? JSON.stringify(body) : undefined,
    });
    return { status: res.status, json: await res.json().catch(() => ({})) };
  };

  try {
    const saved = loadSavedPasswords();
    const accounts = ACCOUNTS.map((a) => ({ ...a, email: `demo.${a.slug}@example.com` }));

    // 1) Đăng ký (nếu chưa có) rồi đăng nhập lấy token
    for (const acc of accounts) {
      acc.password = saved[acc.email] || genPassword();
      const reg = await call("POST", "/api/v1/auth/register", {
        email: acc.email, password: acc.password, fullName: acc.fullName, role: "student",
      });
      if (reg.status === 409 && !saved[acc.email]) {
        throw new Error(`Tài khoản ${acc.email} đã tồn tại nhưng không có mật khẩu trong file demo-accounts.local.txt. Dừng, không reset mật khẩu.`);
      }
      if (reg.status !== 201 && reg.status !== 409) throw new Error(`Đăng ký ${acc.email} lỗi ${reg.status}`);
      // Ghi file ngay sau mỗi tài khoản để không mất mật khẩu nếu lỗi giữa chừng
      saveCredentials(accounts.filter((x) => x.password));
      const login = await call("POST", "/api/v1/auth/login", { email: acc.email, password: acc.password });
      if (login.status !== 200) throw new Error(`Đăng nhập ${acc.email} lỗi ${login.status}`);
      acc.token = login.json.data.accessToken;
      acc.userId = login.json.data.user.id;
    }

    // 2) Đăng bài (bỏ qua người đã đủ bài)
    for (let i = 0; i < accounts.length; i++) {
      const acc = accounts[i];
      const { rows } = await pool.query("SELECT count(*)::int AS n FROM social.posts WHERE author_id = $1", [acc.userId]);
      if (rows[0].n >= POSTS_PER_USER) { console.log(`${acc.email}: đã có ${rows[0].n} bài, bỏ qua`); continue; }
      for (const content of POSTS[i]) {
        const r = await call("POST", "/api/social/posts", { content }, acc.token);
        if (r.status !== 201) throw new Error(`Đăng bài lỗi ${r.status}`);
        await sleep(150 + crypto.randomInt(150)); // giãn thời gian để created_at khác nhau
      }
      console.log(`${acc.email}: đã đăng ${POSTS[i].length} bài`);
    }
    console.log("Xong. File thông tin đăng nhập:", CRED_FILE);
  } finally {
    // Đóng sạch để script tự thoát
    await new Promise((r) => server.close(r));
    await prisma.$disconnect();
    await pool.end();
  }
}

main().catch((e) => { console.error("LỖI:", e.message); process.exitCode = 1; });
