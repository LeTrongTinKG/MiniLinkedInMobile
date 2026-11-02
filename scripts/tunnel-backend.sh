#!/bin/bash
# Khởi chạy Cloudflare Quick Tunnel cho Backend API (port 5001)
# Tạo URL công khai https://*.trycloudflare.com miễn phí, có sẵn SSL

PORT=${PORT:-5001}

echo "========================================================"
echo "🚀 Đang khởi tạo Cloudflare Tunnel cho Backend API..."
echo "📍 Local Service: http://localhost:${PORT}"
echo "========================================================"

if ! command -v cloudflared &> /dev/null; then
    echo "❌ Lỗi: cloudflared chưa được cài đặt."
    echo "Cài đặt bằng lệnh: brew install cloudflared"
    exit 1
fi

cloudflared tunnel --url "http://localhost:${PORT}"
