#!/bin/bash
# scripts/docs_check.sh: Giữ tính đồng bộ giữa SPEC.md, ADRs và Tickets.
tickets_dir="docs/tickets"
statuses="needs-triage|needs-info|ready-for-agent|ready-for-human|wontfix|claimed|resolved"
fail=0

problem() {
  echo "docs-check error: $1"
  fail=1
}

# 1. Mọi feature F-xxx trong SPEC.md phải được nhắc đến trong ít nhất 1 ticket
for f in $(grep -oE 'F-[0-9]{3}' docs/SPEC.md 2>/dev/null | sort -u); do
  if ! grep -qw "$f" "$tickets_dir"/*.md 2>/dev/null; then
    problem "$f xuất hiện trong docs/SPEC.md nhưng không có ticket nào nhắc tới"
  fi
done

# 2. Kiểm tra tính hợp lệ của từng ticket
for t in "$tickets_dir"/*.md; do
  [[ -f "$t" ]] || continue
  name=$(basename "$t")

  # Kiểm tra dòng Status
  if ! grep -qE "^\*\*Status:\*\* ($statuses)\$" "$t"; then
    problem "$name không có dòng **Status:** hợp lệ ($statuses)"
  fi

  # Kiểm tra các ticket mà nó bị blocked bởi
  blocked=$(sed -n 's/^\*\*Blocked by:\*\* //p' "$t")
  for n in $(echo "$blocked" | grep -oE '[0-9]{2}'); do
    if ! ls "$tickets_dir/$n-"*.md >/dev/null 2>&1; then
      problem "$name bị chặn bởi ticket $n, nhưng ticket $n không tồn tại"
    fi
  done

  # Kiểm tra các ADR được trích dẫn
  for adr in $(grep -oE 'ADR-[0-9]{4}' "$t" | sort -u); do
    adr_num="${adr#ADR-}"
    if ! ls docs/adr/"$adr_num"-*.md >/dev/null 2>&1; then
      problem "$name trích dẫn $adr nhưng không tìm thấy trong docs/adr/"
    fi
  done
done

# 3. Kiểm tra các link markdown tương đối trong docs/
for doc in docs/SPEC.md docs/tickets/*.md docs/adr/*.md; do
  [[ -f "$doc" ]] || continue
  dir=$(dirname "$doc")
  for link in $(grep -oE '\]\([^)#[:space:]]+' "$doc" | sed 's/^](//' | grep -vE '^(https?:|mailto:)'); do
    if [[ ! -e "$dir/$link" ]]; then
      problem "$doc trỏ tới link '$link' nhưng tệp không tồn tại"
    fi
  done
done

if [[ $fail -eq 0 ]]; then
  echo "docs-check: Tất cả tài liệu đặc tả, ADRs và tickets đều đồng bộ chuẩn xác!"
fi

exit $fail

