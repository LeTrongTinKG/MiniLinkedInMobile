const express = require("express");
const cors = require("cors");
const helmet = require("helmet");
const dotenv = require("dotenv");
const { prisma } = require("./lib/prisma");
const aiClient = require("./services/ai/aiClient");
const authRoutes = require("./routes/auth.routes");
const jobRoutes = require("./routes/job.routes");
const recruiterRoutes = require("./routes/recruiter.routes");
const cvRoutes = require("./routes/cv.routes");
const applicationRoutes = require("./routes/application.routes");
const newsRoutes = require("./routes/news.routes");
const interactionsRoutes = require("./routes/interaction.routes");
const healthRoutes = require("./routes/health.routes");
const skillRoutes = require("./routes/skill.routes");
const coachRoutes = require("./routes/coach.routes");
const profileRoutes = require("./routes/profile.routes");

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;

// Middlewares
app.disable("x-powered-by");
app.use(helmet({
  hidePoweredBy: false,
  crossOriginResourcePolicy: { policy: "cross-origin" }
}));
const defaultOrigins = ["http://localhost:3000", "http://localhost:5001", "http://127.0.0.1:3000"];
const allowedOrigins = process.env.ALLOWED_ORIGINS
  ? process.env.ALLOWED_ORIGINS.split(",").map((o) => o.trim())
  : defaultOrigins;
app.use(cors({
  origin: (origin, callback) => {
    if (!origin || allowedOrigins.includes(origin) || allowedOrigins.includes("*")) {
      return callback(null, true);
    }
    return callback(null, false);
  },
  credentials: true,
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use("/api/v1/auth", authRoutes);
app.use("/api/v1/jobs", jobRoutes);
app.use("/api/v1/recruiter", recruiterRoutes);
app.use("/api/v1/cvs", cvRoutes);
app.use("/api/v1/applications", applicationRoutes);
app.use("/api/v1/news", newsRoutes);
app.use("/api/v1/health", healthRoutes);
app.use("/api/v1/skills", skillRoutes);
app.use("/api/v1/coach", coachRoutes);
app.use("/api/v1/profile", profileRoutes);
app.use("/api/v1", interactionsRoutes);
app.use("/api/social", require("./routes/social"));

// Health check endpoint tổng quan
app.get("/health", async (_req, res) => {
  let dbStatus = "connected";
  let dbError = null;
  try {
    await prisma.$queryRaw`SELECT 1`;
  } catch (error) {
    dbStatus = "disconnected";
    dbError = error.message || "Unknown database error";
  }

  const aiHealth = await aiClient.checkHealth();
  const isHealthy = dbStatus === "connected" && aiHealth.status !== "error";

  res.status(isHealthy ? 200 : 503).json({
    status: isHealthy ? "ok" : "degraded",
    database: dbStatus,
    aiService: aiHealth.status,
    aiMode: aiHealth.mode,
    timestamp: new Date().toISOString(),
    ...(dbError ? { dbError } : {}),
    ...(aiHealth.error ? { aiError: aiHealth.error } : {}),
  });
});

// Root endpoint
app.get("/", (_req, res) => {
  res.json({
    message: "Welcome to Mini LinkedIn REST API",
    version: "1.0.0",
    docs: "/api/v1/docs",
    endpoints: {
      health: "/health",
      healthAi: "/api/v1/health/ai",
      apiV1: "/api/v1",
      auth: "/api/v1/auth",
      jobs: "/api/v1/jobs",
      recruiter: "/api/v1/recruiter",
      cvs: "/api/v1/cvs",
      applications: "/api/v1/applications",
      news: "/api/v1/news",
    },
  });
});

// Root API endpoint
app.get("/api/v1", (_req, res) => {
  res.json({
    message: "Welcome to Mini LinkedIn REST API v1",
    version: "1.0.0",
    docs: "/api/v1/docs",
  });
});

// 404 Handler cho các route không tồn tại (trả JSON thay vì HTML lỗi mặc định)
app.use((_req, res) => {
  res.status(404).json({
    error: {
      code: "NOT_FOUND",
      message: "Route không tồn tại",
    },
  });
});

// Centralized Error Handler (đặt ở cuối cùng các routes)
const { errorHandler } = require("./middleware/error");
app.use(errorHandler);

// Khởi chạy server khi chạy trực tiếp file này (không chạy khi được require trong test)
if (require.main === module) {
  app.listen(PORT, async () => {
    console.log(`🚀 Server đang chạy tại http://localhost:${PORT}`);
    try {
      await prisma.$connect();
      console.log("✅ Đã kết nối cơ sở dữ liệu Supabase thành công!");
      const { startNewsCron } = require("./services/news/news-cron");
      const { startJobCron } = require("./services/job-cron");
      startNewsCron();
      startJobCron();
      require("./services/coach.service").warmUp();
    } catch (error) {
      console.error("❌ Lỗi kết nối Supabase:", error);
    }
  });
}

module.exports = app;
