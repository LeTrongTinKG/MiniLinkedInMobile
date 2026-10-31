---
role: backend-node
status: reviewed
---

# Ngữ cảnh Backend (Node.js)

Nguồn: tài liệu học của Node.js về event loop và việc không được chặn vòng lặp, roadmap.sh phần Backend và Node.js, khảo sát Stack Overflow năm 2025, và báo cáo TopDev rằng gần tám mươi phần trăm công ty ở Việt Nam tìm người biết JavaScript.

## step 1

Giọng: Viết JavaScript bất đồng bộ cho chắc trước khi mở framework.

JavaScript là ngôn ngữ bước này, Node chỉ là nơi chạy nó ở ngoài trình duyệt.
Hàm, object, mảng và cách duyệt mảng phải thành phản xạ.
Promise là một việc sẽ xong sau, async và await là cách viết cho dễ đọc.
try và catch phải nằm quanh chỗ bạn chờ việc, không để lỗi rơi mất.
Một bài tập đọc danh sách, đổi dạng, rồi in kết quả là đủ.
Git nên có mặt từ bài tập đầu, commit nhỏ và có lời nhắn đọc được.
Đừng học TypeScript ở tuần đầu nếu bạn còn nhầm callback với async.
Đừng cài framework khi chưa viết được một hàm chờ hai việc theo đúng thứ tự.
Biến môi trường là chỗ để đường dẫn và cổng, không gõ cổng cứng ở mười file.
Terminal và Git là công cụ, không phải môn phụ.
Nếu bạn chỉ biết JavaScript trên trình duyệt, hãy tập chạy file bằng Node cho quen.
Lỗi hay gặp là quên return trong nhánh lỗi nên hàm chạy tiếp như chưa có chuyện gì.
Mục tiêu là một bộ bài tập nhỏ trên GitHub, không phải một trang web.
Hết bước này bạn mới đụng module và file của Node.
Học đều còn hơn học một mạch rồi nghỉ.
Mình không nhận một đoạn copy từ tài liệu là bằng chứng.

## step 2

Giọng: Hiểu vòng lặp sự kiện bằng một công cụ đọc file lớn, đừng học thuộc định nghĩa.

Node có một vòng lặp sự kiện để phục vụ nhiều yêu cầu, nên một hàm nặng sẽ chặn mọi người khác.
Đừng dùng hàm đồng bộ để đọc file lớn trong server.
Stream là cách đọc từng khúc, hợp với file CSV dài.
Module ES và require cũ cùng tồn tại, bạn cần đọc được cả hai vì thư viện cũ vẫn dùng require.
package.json là danh sách việc và thư viện, phải có trong repo.
fs, path và biến môi trường là phần lõi mình muốn bạn chạm tay vào.
Một công cụ dòng lệnh đọc CSV và in báo cáo ngắn là sản phẩm của bước.
Đừng đưa Express vào trước khi bạn thấy một server HTTP thô trả được một dòng.
Đừng chặn vòng lặp bằng một vòng for trên dữ liệu khổng lồ trong lúc đang phục vụ request.
Lỗi hay gặp là quên đóng stream nên tiến trình không thoát.
Process và tín hiệu dừng giúp bạn tắt server cho sạch khi triển khai.
npm hoặc pnpm chỉ cần một, đừng để hai file khóa cùng tồn tại nếu bạn không hiểu vì sao.
Bằng chứng là package.json và mã có stream hoặc đọc file bất đồng bộ.
Hết bước này bạn mới thiết kế đường dẫn API.
Đọc trang Node về việc không chặn event loop một lần, rồi làm bài, đừng chỉ gạch đầu dòng.

## step 3

Giọng: Một API việc cần làm, có kiểm tra dữ liệu vào và mã lỗi đúng, là đủ.

API là hợp đồng, đường dẫn và mã HTTP phải nói được chuyện gì đã xảy ra.
Express hoặc Fastify chọn một, rồi giữ router và middleware cho đều.
Kiểm tra dữ liệu vào trước khi chạm cơ sở dữ liệu.
Mã 400 là dữ liệu xấu, 401 là chưa đăng nhập, 404 là không thấy, 500 là lỗi của bạn.
Phân trang ngay từ danh sách, đừng trả cả bảng khi mới có mười dòng.
Một API quản lý công việc, tạo, xem, sửa, xóa, là bài của bước.
Viết vài câu nói mỗi đường dẫn nhận gì và trả gì.
Đừng trả stack trace cho người gọi.
Đừng để một hàm router dài hai trăm dòng, tách chỗ đọc dữ liệu và chỗ kiểm tra.
Postman hoặc một file thử request giúp bạn không phải nhớ lệnh.
Lỗi hay gặp là quên return sau khi đã gửi lỗi, nên server gửi tiếp một phản hồi thứ hai.
CORS chỉ cần khi có trình duyệt khác gốc gọi tới, đừng bật tất cả cho xong chuyện.
Bằng chứng là repo có router, có kiểm tra dữ liệu, và có ví dụ request.
Hết bước này bạn mới nối database và đăng nhập.
Nếu mới có mỗi console.log, bước API chưa xong.

## step 4

Giọng: Mỗi người chỉ đọc được dữ liệu của mình, đó là bài đăng nhập chứ không phải bài làm màu.

SQL cơ bản là chọn, nối bảng, nhóm và lọc.
PostgreSQL là database mình chọn trong lộ trình này vì dễ chạy thật và hay gặp việc.
Thiết kế bảng trước khi viết ORM, kẻo ORM giấu một quan hệ xấu.
Prisma hoặc một lớp truy vấn chọn một, rồi đọc được câu SQL nó sinh ra.
Mật khẩu phải được băm, không bao giờ lưu chữ gốc.
JWT là một cách giữ phiên, phải có hạn và phải kiểm chữ ký.
Phân quyền nghĩa là một route biết ai được vào, không phải giấu nút ở giao diện.
Bài của bước là API nhiều người dùng, mỗi người chỉ thấy việc của mình.
Đừng tin id người dùng do client gửi nếu token đã có id đó.
Đừng nối chuỗi để tạo câu SQL.
Index để sau, khi một câu hỏi thật sự chậm, nhưng hãy biết nhìn một câu hỏi đang quét cả bảng.
Redis ở bước sau mới dùng cho cache, chưa cần trong bài đăng nhập đầu.
Bằng chứng là repo có schema, có băm mật khẩu, và có một route từ chối người không phải chủ dữ liệu.
Hết bước này bạn mới thêm kiểu và kiểm thử cho chắc.
Mình không gọi một API chưa có đăng nhập là xong phần backend.

## step 5

Giọng: Đổi sang TypeScript khi API đã chạy, và để test chạy trong GitHub Actions.

TypeScript giúp bắt nhầm tên trường trước khi chạy.
Thêm kiểu cho dữ liệu vào và dữ liệu ra trước, đừng kiểu hóa mọi thứ một ngày.
Jest hoặc bộ test sẵn của Node đều được, miễn là có lệnh npm test.
Test API nên dựng dữ liệu giả hoặc một database thử, không trỏ vào database thật.
Log nên có cấu trúc, có mã yêu cầu, không phải một chuỗi tùy hứng.
Helmet và CORS cấu hình hẹp là phần an toàn tối thiểu.
Bí mật nằm trong biến môi trường, file ví dụ chỉ ghi tên biến để trống.
Bài của bước là repo có tsconfig, có test, và test chạy khi bạn đẩy mã.
Đừng tắt một test cho qua.
Đừng dùng any cho mọi hàm rồi vẫn nói là có TypeScript.
Lỗi hay gặp là test phụ thuộc thứ tự vì dùng chung một bảng.
Hết bước này bạn đóng gói và chạy trên một máy khác máy của bạn.
Một test đỏ được sửa còn hơn mười test không ai chạy.

## step 6

Giọng: Dockerfile và một đường dẫn sức khỏe là đủ để coi là chạy thật.

Docker giúp máy khác chạy cùng phiên bản Node và cùng cách bật database.
Docker Compose hợp khi API và PostgreSQL phải lên cùng lúc.
Redis lúc này mới đáng để cache một route bị gọi liên tục hoặc để giới hạn số lần gọi.
Hàng đợi dành cho việc lâu như gửi thư, đừng nhét việc đó vào request.
Một bản triển khai có đường dẫn báo server còn sống.
Log phải xem được khi app nằm trong container.
Đừng chạy container bằng quyền root nếu bạn không cần.
Đừng đưa file env thật vào ảnh.
Bài cuối là một backend có đăng nhập, database, test và Docker, có link hoặc hướng dẫn chạy.
GitHub Actions nên chạy test trước khi bạn khoe là đã triển khai.
Hết lộ trình bạn giải thích được vì sao không chặn event loop và vì sao không nối chuỗi SQL.
Mình vẫn không nói bạn thành thạo Node chỉ vì đã có Dockerfile.
Hai dự án nhỏ rõ ràng hơn một dự án ôm mọi từ khóa tuyển dụng.
