#!/bin/bash
# Khởi chạy Cloudflare Quick Tunnel cho Flutter Web Client (port 3000)
# Tạo URL công khai https://*.trycloudflare.com miễn phí, có sẵn SSL

PORT=${PORT:-3000}

echo "========================================================"
echo "🌐 Đang khởi tạo Cloudflare Tunnel cho Flutter Web..."
echo "📍 Local Service: http://localhost:${PORT}"
echo "========================================================"

if ! command -v cloudflared &> /dev/null; then
    echo "❌ Lỗi: cloudflared chưa được cài đặt."
    echo "Cài đặt bằng lệnh: brew install cloudflared"
    exit 1
fi

cloudflared tunnel --url "http://localhost:${PORT}"

