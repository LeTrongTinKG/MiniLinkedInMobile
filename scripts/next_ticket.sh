#!/bin/bash
# scripts/next_ticket.sh: Tìm ticket tiếp theo sẵn sàng cho Agent thực hiện (ready-for-agent).
tickets_dir="docs/tickets"
found=0

for t in "$tickets_dir"/[0-9][0-9]-*.md; do
  [[ -f "$t" ]] || continue
  grep -qE '^\*\*Status:\*\* ready-for-agent$' "$t" || continue

  open=""
  for n in $(sed -n 's/^\*\*Blocked by:\*\* //p' "$t" | grep -oE '[0-9]{2}'); do
    if ! grep -qE '^\*\*Status:\*\* resolved$' "$tickets_dir/$n-"*.md 2>/dev/null; then
      open="$open $n"
    fi
  done

  if [[ -z "$open" ]]; then
    echo "NEXT TICKET SẴN SÀNG: $t"
    echo "Tiêu đề: $(head -n 1 "$t")"
    found=1
  fi
done

if [[ $found -eq 0 ]]; then
  echo "next-ticket: Không có ticket nào ở trạng thái ready-for-agent đã giải phóng toàn bộ blocker." >&2
  exit 1
fi

