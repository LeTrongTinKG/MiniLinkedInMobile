const { spawn } = require("child_process");
const fs = require("fs");
const path = require("path");

const appDir = path.resolve(__dirname, "..", "app");
const libDir = path.resolve(appDir, "lib");

console.log("🚀 Đang khởi chạy Flutter Web kết nối Backend Local (http://localhost:5000/api/v1)...");
console.log(`📁 Theo dõi thay đổi thư mục: ${libDir}\n`);

const flutter = spawn("flutter", ["run", "-d", "chrome", "--web-port", "3000"], {
  cwd: appDir,
  shell: true,
  stdio: ["pipe", "inherit", "inherit"],
});

let debounceTimer = null;
let isReady = false;

// Đợi vài giây sau khi Flutter khởi động để tránh trigger hot reload lúc mới build
setTimeout(() => {
  isReady = true;
  console.log("\n⚡ [Auto Hot Reload] Chế độ tự động Hot Reload khi lưu file đã sẵn sàng!\n");
}, 15000);

if (fs.existsSync(libDir)) {
  fs.watch(libDir, { recursive: true }, (eventType, filename) => {
    if (!isReady) return;
    if (filename && filename.endsWith(".dart")) {
      clearTimeout(debounceTimer);
      debounceTimer = setTimeout(() => {
        console.log(`\n⚡ [Auto Hot Reload] File ${filename} đã thay đổi -> Tự động Hot Reload UI...`);
        try {
          flutter.stdin.write("r\n");
        } catch (err) {
          console.error("Lỗi gửi tín hiệu Hot Reload:", err.message);
        }
      }, 400);
    }
  });
}

// Chuyển tiếp phím bấm từ console cha (nếu có)
if (process.stdin.isTTY) {
  process.stdin.setRawMode(true);
  process.stdin.resume();
  process.stdin.on("data", (chunk) => {
    try {
      flutter.stdin.write(chunk);
    } catch (_) {}
  });
}

const cleanExit = () => {
  try {
    flutter.kill("SIGTERM");
  } catch (_) {}
  process.exit();
};

process.on("SIGINT", cleanExit);
process.on("SIGTERM", cleanExit);
flutter.on("close", (code) => {
  process.exit(code || 0);
});
