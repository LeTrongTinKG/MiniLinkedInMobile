#!/bin/bash
# scripts/doctor.sh: Kiểm tra môi trường phát triển cần thiết cho MiniLinkedInMobile.
fail=0

need() {
  local cmd="$1"
  local ver_cmd="$2"
  local expected="$3"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "MISSING  $cmd"
    fail=1
    return
  fi
  local ver
  ver=$(eval "$ver_cmd" 2>/dev/null | head -1)
  if [[ -n "$expected" && "$ver" != *"$expected"* ]]; then
    echo "VERSION  $cmd: có '$ver', yêu cầu '$expected'"
    fail=1
  else
    echo "OK       $cmd ($ver)"
  fi
}

optional() {
  local cmd="$1"
  local hint="$2"
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "OK       $cmd (optional)"
  else
    echo "OPTIONAL $cmd không tìm thấy: $hint"
  fi
}

echo "=== MiniLinkedInMobile Doctor ==="
need flutter "flutter --version" ""
need node "node -v" ""
need npm "npm -v" ""
need git "git --version" ""
optional python3 "Cần cho mô hình AI / python benchmark"
optional ollama "Cần cho AI Coach chạy cục bộ (port 11434)"

if [[ $fail -eq 0 ]]; then
  echo "Doctor check: Tất cả công cụ bắt buộc đều sẵn sàng!"
else
  echo "Doctor check: Một số công cụ còn thiếu hoặc không đạt yêu cầu."
fi

exit $fail
