const path = require("path");
require("dotenv").config({ path: path.join(__dirname, "..", "..", ".env") });
const { prisma } = require("../../src/lib/prisma");

const mobileJobs = require("./data/jobs-mobile");
const feJobs = require("./data/jobs-frontend");
const beJobs = require("./data/jobs-backend");
const aiJobs = require("./data/jobs-ai");

const ALL_JOBS = [...mobileJobs, ...feJobs, ...beJobs, ...aiJobs];

async function seedJobs() {
  console.log(`🌱 Đang nạp ${ALL_JOBS.length} công việc công nghệ chất lượng cao vào Supabase...`);

  // Tìm các recruiter mẫu để gắn job nội bộ (hỗ trợ nộp đơn in-app & AI Match)
  const recruiters = await prisma.user.findMany({
    where: { role: "recruiter" },
    include: { recruiterProfile: true },
  });

  const recruiterMap = new Map();
  for (const r of recruiters) {
    if (r.recruiterProfile?.companyName) {
      recruiterMap.set(r.recruiterProfile.companyName.toLowerCase(), r.id);
    }
  }

  const nowMs = Date.now();
  let count = 0;

  for (let i = 0; i < ALL_JOBS.length; i++) {
    const item = ALL_JOBS[i];
    const compLower = item.companyName.toLowerCase();

    const matchedRecruiterId =
      recruiterMap.get(compLower) ||
      (compLower.includes("fpt") ? recruiters.find((r) => r.email.includes("fpt"))?.id : null) ||
      (compLower.includes("vng") ? recruiters.find((r) => r.email.includes("vng"))?.id : null) ||
      (compLower.includes("shopee") ? recruiters.find((r) => r.email.includes("shopee"))?.id : null);

    const source = matchedRecruiterId ? "internal" : "jsearch";
    const dedupeKey = `${item.title.toLowerCase().trim()}|${item.companyName.toLowerCase().trim()}`;

    // Tạo thời gian đăng trải dài trong 3 ngày qua (vài giờ trước, 1 ngày trước...)
    const hoursAgo = (i % 36) * 2;
    const fakePostedDate = new Date(nowMs - hoursAgo * 60 * 60 * 1000);

    const data = {
      title: item.title,
      companyName: item.companyName,
      location: item.location,
      workMode: item.workMode,
      level: item.level,
      salaryMin: item.salaryMin,
      salaryMax: item.salaryMax,
      salaryCurrency: item.salaryCurrency,
      description: item.description,
      requiredSkills: item.requiredSkills,
      niceToHave: item.niceToHave,
      applyUrl: item.applyUrl,
      dedupeKey,
      status: "open",
      createdAt: fakePostedDate,
      lastSeenAt: new Date(),
    };

    await prisma.job.upsert({
      where: {
        source_externalId: {
          source,
          externalId: item.externalId,
        },
      },
      update: data,
      create: {
        ...data,
        source,
        externalId: item.externalId,
        recruiterId: matchedRecruiterId || null,
      },
    });
    count++;
  }

  console.log(`✅ Đã nạp thành công ${count} công việc IT sinh viên vào cơ sở dữ liệu!`);
}

seedJobs()
  .catch((e) => {
    console.error("❌ Lỗi nạp job:", e.message);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());

