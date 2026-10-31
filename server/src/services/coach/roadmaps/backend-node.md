---
role: backend-node
title: Lập trình viên Backend (Node.js)
status: reviewed
reviewed_by: ssaas (chủ dự án)
updated: 2026-10-31
---

# Lộ trình Backend (Node.js)

Dành cho sinh viên học 1–2 giờ mỗi ngày. Tổng khoảng 24 tuần (6 tháng).
Tên skill viết đúng như từ điển `skillsDictionary.js`.

| Bước | Skill cần có | Học gì | Bằng chứng nên có | Thời gian gợi ý |
|---|---|---|---|---|
| 1. JavaScript vững | `javascript`, `git` | Hàm, closure, object, class, mảng; Promise, async/await, try/catch; dòng lệnh. | Repo bài tập JavaScript bất đồng bộ, commit đều. | 3 tuần |
| 2. Lõi Node.js | `nodejs` | Event loop, module (ES và CommonJS), `fs`, `path`, stream, biến môi trường, npm. | Công cụ dòng lệnh đọc file CSV lớn bằng stream; có `package.json`. | 4 tuần |
| 3. Xây API | `rest api`, `postman` | Express hoặc Fastify, router, middleware, kiểm tra dữ liệu vào, mã lỗi HTTP, phân trang. | API quản lý công việc có tài liệu và kiểm tra dữ liệu vào. | 4 tuần |
| 4. Cơ sở dữ liệu và đăng nhập | `sql`, `postgresql` | SQL cơ bản, thiết kế bảng; Prisma hoặc Knex; băm mật khẩu, JWT, phân quyền theo vai trò. | API nhiều người dùng trên PostgreSQL, mỗi người chỉ xem được dữ liệu của mình. | 5 tuần |
| 5. Kiểm thử và chất lượng | `typescript`, `jest` | Unit test, test API; chuyển sang TypeScript; log có cấu trúc; CORS, Helmet, giữ bí mật. | Repo có `tsconfig.json` và test chạy trong GitHub Actions. | 4 tuần |
| 6. Chạy thật | `docker`, `redis`, `ci/cd` | Docker và Docker Compose, cache và giới hạn tần suất bằng Redis, hàng đợi việc nền, triển khai lên Render. | Repo có `Dockerfile` và workflow CI, có link bản đã triển khai. | 4 tuần |

## Sẵn sàng đi làm khi

- Có một backend hoàn chỉnh đã triển khai: đăng nhập, database, test, Docker.
- Giải thích được event loop, cách chống SQL injection và cách giữ bí mật.

## Thị trường

- TopDev: gần 80% công ty ở Việt Nam tuyển JavaScript; Backend, Full-stack và Front-end là các vị trí tuyển nhiều nhất.
- Stack Overflow 2025: Node.js được 48,7% lập trình viên dùng, PostgreSQL 55%, Docker 71%.

## Nguồn

- roadmap.sh, Backend: <https://roadmap.sh/backend>; Node.js: <https://roadmap.sh/nodejs>
- Node.js Roadmap 2026 (6 giai đoạn, 24 tuần): <https://www.roadmap-creator.com/blog/learn-node-js-roadmap>
- Stack Overflow Developer Survey 2025: <https://survey.stackoverflow.co/2025/technology>
- TopDev, xu hướng tuyển dụng IT 2024–2025: <https://topdev.vn/blog/xu-huong-tuyen-dung-it-tai-viet-nam-2024/>
