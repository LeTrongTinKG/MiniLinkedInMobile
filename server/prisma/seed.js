// Nạp biến môi trường từ server/.env
require("dotenv").config({ path: `${__dirname}/../.env` });
const bcrypt = require("bcryptjs");
const { PrismaClient } = require("@prisma/client");
// Dữ liệu mẫu của recruiter
const recruitersData = require("./data/recruiters");

const prisma = new PrismaClient();
const DEMO_PASSWORD = "Demo@123456";

// Tạo (hoặc giữ nguyên nếu đã có) tài khoản recruiter demo
async function seedRecruiters() {
  const passwordHash = await bcrypt.hash(DEMO_PASSWORD, 10);

  const results = [];
  for (const r of recruitersData) {
    const user = await prisma.user.upsert({
      where: { email: r.email },
      update: {},
      create: {
        email: r.email,
        fullName: r.fullName,
        passwordHash,
        role: "recruiter",
        recruiterProfile: { create: r.profile },
      },
    });
    results.push({ id: user.id, email: user.email, company: r.profile.companyName });
  }
  return results;
}

async function main() {
  console.log("🌱 Bắt đầu seed dữ liệu...");

  // Seed recruiter và in danh sách
  const recruiters = await seedRecruiters();
  console.log(`✅ ${recruiters.length} recruiter accounts:`);
  recruiters.forEach((r) => console.log(`   ${r.email} → ${r.company}`));

  // In thông tin đăng nhập demo
  console.log("\n📋 Thông tin đăng nhập demo:");
  console.log("   Password chung: Demo@123456");
  recruiters.forEach((r) => console.log(`   ${r.email} (${r.company})`));
}

// Chạy seed, báo lỗi nếu thất bại, luôn ngắt kết nối DB khi xong
main()
  .catch((e) => {
    console.error("❌ Seed thất bại:", e.message);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
