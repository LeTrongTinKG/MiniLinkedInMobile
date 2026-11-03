#!/bin/bash
set -e

echo "🚀 [Atom Vercel Build] Bắt đầu quy trình build Flutter Web..."

# 1. Kiểm tra hoặc cài đặt Flutter SDK
if command -v flutter >/dev/null 2>&1; then
  echo "✅ Đã tìm thấy Flutter SDK có sẵn:"
  flutter --version | head -n 2
else
  echo "📦 Chưa có Flutter SDK, tiến hành tải Flutter stable (shallow clone)..."
  if [ ! -d "/tmp/flutter" ]; then
    git clone https://github.com/flutter/flutter.git --depth 1 -b stable /tmp/flutter
  fi
  export PATH="/tmp/flutter/bin:$PATH"
  echo "✅ Đã tải và thiết lập Flutter SDK thành công:"
  flutter --version | head -n 2
fi

# 2. Tắt telemetry
flutter config --no-analytics >/dev/null 2>&1 || true

# 3. Chuẩn bị biến môi trường
API_URL="${API_URL:-https://minilinkedinmobile.onrender.com/api/v1}"
GITHUB_CLIENT_ID="${GITHUB_CLIENT_ID:-Ov23liAsAW4RrAeNbMsn}"
echo "🌐 Backend API URL: $API_URL"
echo "🔑 GitHub Client ID: $GITHUB_CLIENT_ID"

# 4. Di chuyển vào thư mục app và tiến hành build
cd app
echo "📥 Đang tải dependencies (flutter pub get)..."
flutter pub get

echo "🔨 Đang biên dịch Flutter Web release..."
flutter build web --release --dart-define=API_URL="$API_URL" --dart-define=GITHUB_CLIENT_ID="$GITHUB_CLIENT_ID"

# 5. Đảm bảo file cấu hình SPA vercel.json có mặt trong output
if [ -f "web/vercel.json" ]; then
  cp web/vercel.json build/web/vercel.json
fi

echo "🎉 [Atom Vercel Build] Biên dịch hoàn tất tại app/build/web!"
