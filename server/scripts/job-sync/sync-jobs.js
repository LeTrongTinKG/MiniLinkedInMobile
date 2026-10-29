// Lệnh chạy kéo job: node scripts/job-sync/sync-jobs.js [--dry-run] [--cache] [--show=N]
//   --dry-run : chỉ in báo cáo, KHÔNG ghi DB
//   --cache   : dùng/ghi JSON thô trong server/.cache/job-sync/ (không tốn thêm request khi đã có cache)
//   --show=N  : in thử N job đầu tiên (mặc định 0)
const path = require("path");
require("dotenv").config({ path: path.join(__dirname, "..", "..", ".env"), quiet: true });

const { prisma } = require("../../src/lib/prisma");
const repo = require("../../src/repositories/job-sync/job-sync.repository");
const { runSync } = require("../../src/services/job-sync/job-sync.service");
const { formatReport } = require("../../src/services/job-sync/report");
const adapters = {
  jsearch: require("../../src/services/job-sync/adapters/jsearch.adapter"),
  serpapi: require("../../src/services/job-sync/adapters/serpapi.adapter"),
  remotive: require("../../src/services/job-sync/adapters/remotive.adapter"),
};

async function main() {
  const args = process.argv.slice(2);
  const dryRun = args.includes("--dry-run");
  const useCache = args.includes("--cache");
  const showArg = args.find((a) => a.startsWith("--show="));
  const show = showArg ? Number(showArg.split("=")[1]) : 0;

  const { report, jobs } = await runSync({ dryRun, useCache }, { repo, adapters, db: prisma });
  console.log(formatReport(report));

  // In thử vài job (không in mô tả dài)
  for (const job of jobs.slice(0, show)) {
    console.log(
      JSON.stringify({
        source: job.source, title: job.title, company: job.companyName, location: job.location,
        level: job.level, workMode: job.workMode, salary: [job.salaryMin, job.salaryMax, job.salaryCurrency],
        skills: job.requiredSkills, nice: job.niceToHave, applyUrl: job.applyUrl,
      })
    );
  }
}

main()
  .catch((error) => {
    // Không in cả object lỗi (có thể chứa URL kèm key)
    console.error("Job Sync lỗi:", String(error.message).replace(/(api_key|key|token)=[^&\s]+/gi, "$1=***"));
    process.exitCode = 1;
  })
  .finally(() => prisma.$disconnect());
