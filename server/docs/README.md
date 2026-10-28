# Thuật toán

Tài liệu giải thích thuật toán và thiết kế của các module. Có thắc mắc về cách một phần hoạt động thì đọc ở đây trước.

| Tài liệu | Nội dung |
|---|---|
| [JOB_SYNC_DESIGN.md](JOB_SYNC_DESIGN.md) | Kéo job từ JSearch, SerpApi, Remotive: chiến lược quota, pipeline điều phối, lọc & làm sạch, lọc trùng |
| [JOB_SYNC_CACHE.md](JOB_SYNC_CACHE.md) | Vì sao ghi câu trả lời API ra file `.json`: tiết kiệm request khi chỉnh cleaner, khi nào đọc, khi nào ghi đè |
| [SOCIAL_DESIGN.md](SOCIAL_DESIGN.md) | Module mạng xã hội: DB schema `social`, danh sách API, cursor pagination |
| [IMAGE_COMPRESSION.md](IMAGE_COMPRESSION.md) | Nén ảnh khi đăng bài (module Social): resize, JPEG/WebP, xóa EXIF, thumbnail |

> Không ghi API key, mật khẩu hay secret vào thư mục này. Chỉ ghi **tên** biến môi trường.

## Chạy Job Sync

Chạy từ thư mục `server/` (cần các biến `RAPIDAPI_KEY`, `RAPIDAPI_HOST`, `SERPAPI_KEY` trong `.env`):

```
node scripts/job-sync/sync-jobs.js --dry-run --cache   # chạy thử: in báo cáo, KHÔNG ghi DB
node scripts/job-sync/sync-jobs.js --cache             # chạy thật: ghi bảng jobs + nhật ký job_sync_runs
node scripts/job-sync/sync-jobs.js --show=10           # thêm --show=N để in thử N job
```

- `--cache`: đọc/ghi JSON thô trong `server/.cache/job-sync/` (đã gitignore). Có cache rồi thì không tốn thêm request khi chỉnh cleaner. Bỏ cờ này thì luôn gọi mạng. Mỗi lần gọi mạng đều tốn quota thật, kể cả khi `--dry-run`.
- Ngân sách mỗi lượt, mục tiêu số job, từ khóa: sửa ở `src/services/job-sync/keywords.config.js`.
- DB: các cột/bảng của Job Sync thêm bằng `prisma/job_sync_ext.sql` (không dùng `prisma db push`).
