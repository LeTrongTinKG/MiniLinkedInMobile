const express = require("express");
const cors = require("cors");
const dotenv = require("dotenv");
const { prisma } = require("./lib/prisma");
const authRoutes = require("./routes/auth.routes");

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;

// Middlewares
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use("/api/v1/auth", authRoutes);

// Health check endpoint
app.get("/health", async (_req, res) => {
  try {
    await prisma.$queryRaw`SELECT 1`;
    res.json({
      status: "ok",
      database: "connected",
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    res.status(500).json({
      status: "error",
      database: "disconnected",
      error: error.message || "Unknown error",
    });
  }
});

// Root API endpoint
app.get("/api/v1", (_req, res) => {
  res.json({
    message: "Welcome to Mini LinkedIn REST API",
    version: "1.0.0",
    docs: "/api/v1/docs",
  });
});

// Centralized Error Handler (đặt ở cuối cùng các routes)
const { errorHandler } = require("./middleware/error");
app.use(errorHandler);

// Khởi chạy server
app.listen(PORT, async () => {
  console.log(`🚀 Server đang chạy tại http://localhost:${PORT}`);
  try {
    await prisma.$connect();
    console.log("✅ Đã kết nối cơ sở dữ liệu Supabase thành công!");
  } catch (error) {
    console.error("❌ Lỗi kết nối Supabase:", error);
  }
});

module.exports = app;
