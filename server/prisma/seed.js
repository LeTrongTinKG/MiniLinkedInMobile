require("dotenv").config({ path: `${__dirname}/../.env` });
const bcrypt = require("bcryptjs");
const { PrismaClient } = require("@prisma/client");
const recruitersData = require("./data/recruiters");
const jobsData = require("./data/jobs");

const prisma = new PrismaClient();
const DEMO_PASSWORD = "Demo@123456";

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

async function seedJobs(recruiters) {
  const emailToId = Object.fromEntries(recruiters.map((r) => [r.email, r.id]));

  await prisma.job.deleteMany();

  const jobs = jobsData.map(({ recruiterEmail, ...job }) => ({
    ...job,
    recruiterId: emailToId[recruiterEmail],
  }));

  const { count } = await prisma.job.createMany({ data: jobs });
  return count;
}

async function main() {
  console.log("🌱 Bắt đầu seed dữ liệu...");

  const recruiters = await seedRecruiters();
  console.log(`✅ ${recruiters.length} recruiter accounts:`);
  recruiters.forEach((r) => console.log(`   ${r.email} → ${r.company}`));

  const jobCount = await seedJobs(recruiters);
  console.log(`✅ ${jobCount} job listings`);

  console.log("\n📋 Thông tin đăng nhập demo:");
  console.log("   Password chung: Demo@123456");
  recruiters.forEach((r) => console.log(`   ${r.email} (${r.company})`));
}

main()
  .catch((e) => {
    console.error("❌ Seed thất bại:", e.message);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
