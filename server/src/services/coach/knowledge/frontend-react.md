---
role: frontend-react
status: reviewed
---

# Ngữ cảnh Frontend (React)

Nguồn: MDN Learn web development, tài liệu React tại react.dev về cách nghĩ component và state như một ảnh chụp, roadmap.sh phần Frontend và React, khảo sát Stack Overflow năm 2025, và tin tuyển fresher React ở Việt Nam.

## step 1

Giọng: Làm một trang tĩnh đúng thẻ và đọc được trên điện thoại trước khi viết JavaScript.

Trình duyệt nhận HTML, CSS và địa chỉ, nên bước đầu chưa cần framework.
HTML ngữ nghĩa nghĩa là tiêu đề dùng thẻ tiêu đề, nút dùng thẻ nút, danh sách dùng thẻ danh sách.
Form cần nhãn gắn với ô nhập, không chỉ một placeholder.
CSS lúc này là bố cục và khoảng cách, chưa cần một thư viện.
Trang phải đọc được khi thu hẹp cửa sổ, vì người dùng mở trên điện thoại.
Một trang cá nhân tĩnh trên GitHub Pages là sản phẩm đủ.
Đừng bắt đầu bằng React khi bạn chưa viết được một form thuần.
Đừng dùng div cho mọi thứ rồi sửa bằng ARIA sau.
Khả năng truy cập không phải việc của phút cuối, thẻ đúng ngay từ đầu đã là một phần.
Git commit trang đó, dù nó đơn giản.
Màu chữ và màu nền phải tách nhau, đừng chữ xám trên nền xám.
Ảnh cần chữ thay thế.
Mình muốn bạn giải thích được một request đi từ trình duyệt tới server ở mức địa chỉ và mã trả về.
Hết bước này bạn mới làm trang đổi nội dung bằng JavaScript.
Nếu bạn chỉ có ảnh thiết kế mà chưa có mã, bước này chưa bắt đầu.
Đọc phần HTML của MDN trước một khóa React dài.

## step 2

Giọng: Một trang gọi API công khai và tự vẽ lại danh sách là đủ cho JavaScript.

JavaScript ở bước này chạy trên trình duyệt, đọc DOM và lắng nghe sự kiện.
Fetch là cách gọi mạng, async và await giúp bạn không viết callback lồng nhau.
Khi dữ liệu về, bạn vẽ lại danh sách, và khi lỗi thì hiện một câu chứ không để trang im.
Module giúp tách file, đừng để một file vài nghìn dòng.
Bài là một trang lấy dữ liệu công khai và hiện được.
Đừng học React song song khi bạn còn nhầm querySelector.
Đừng innerHTML một chuỗi người dùng dán vào, đó là cửa cho script lạ.
Lỗi hay gặp là quên ngăn form submit nên trang tải lại mất dữ liệu.
Console là công cụ, hãy đọc lỗi đỏ trước khi sửa đoán.
Git vẫn commit đều.
Hết bước này bạn đã có phản xạ dữ liệu bất đồng bộ, React sẽ đỡ bí.
Mình không tính một đoạn script copy từ mạng là đã biết JavaScript.
Biết sửa một lỗi kiểu undefined trên màn của chính bạn mới là dấu hiệu xong bước.

## step 3

Giọng: Chia giao diện thành component, để state ít nhất có thể, rồi mới thêm thư viện.

React khuyên nghĩ từ bản tĩnh trước, state chỉ dành cho thứ thay đổi theo thời gian.
Component là hàm trả về giao diện, props là dữ liệu cha đưa xuống.
State không phải biến thường, gán state không đổi giá trị ngay trong lần render đó mà xin một lần render mới.
useState giữ bộ nhớ của component, useEffect chỉ để đồng bộ với thứ bên ngoài như mạng hoặc trình duyệt.
Đừng dùng effect để tính một giá trị bạn suy ra được từ state sẵn có.
Danh sách cần key ổn định, đừng dùng chỉ số nếu danh sách sắp xếp lại.
React Router hoặc bộ định tuyến bạn chọn giúp có nhiều trang trong một app.
App thẻ học hoặc app trắc nghiệm là bài vừa sức.
Khai báo react trong package.json để lần quét nhìn thấy.
Đừng học Redux ở app mới có một màn.
Đừng copy class component cũ, tài liệu hiện khuyên component là hàm.
Lỗi hay gặp là effect gọi liên tục vì thiếu hoặc thừa dependency.
Bằng chứng là repo chạy được và có component tách file.
Hết bước này bạn mới đưa dữ liệu server vào và nghĩ tới kho state lớn hơn.
Đọc trang state như một ảnh chụp trên react.dev một lần, nó giải thích nhiều lỗi kỳ lạ.

## step 4

Giọng: Một app thời tiết gọi API, có lúc tải và lúc lỗi, quan trọng hơn một kho state phức tạp.

Gọi API trong React vẫn cần ba trạng thái, đang tải, có dữ liệu, và lỗi.
Đừng để người dùng nhìn trang trống trong lúc chờ.
Context đủ khi vài component cần cùng một giá trị đơn giản.
Redux Toolkit hoặc Zustand chỉ đáng khi nhiều màn sửa cùng một kho và bạn bắt đầu rối.
Chọn một, đừng ghi cả hai vào hồ sơ khi mới làm một app.
Form nên kiểm tra trước khi gửi.
App thời tiết hoặc app tìm repo là bài của bước.
Hủy request khi component biến mất nếu request còn đang chạy.
Đừng lưu cả phản hồi thô và bản đã biến đổi nếu một bên suy ra được từ bên kia.
Lỗi hay gặp là set state sau khi màn đã đóng.
Bằng chứng là repo có lời gọi API và một chỗ xử lý lỗi nhìn thấy trong giao diện.
Hết bước này bạn thêm kiểu và một hệ CSS cho đều.
Mình không khen một app chỉ có dữ liệu gõ sẵn.

## step 5

Giọng: Thêm kiểu cho props và cho dữ liệu API trước, Tailwind chỉ là cách viết CSS cho nhanh.

TypeScript bắt lỗi sai tên trường trước khi bạn mở trình duyệt.
Zod hoặc một lớp kiểm tra giúp dữ liệu API lạ không chui vào component.
Tailwind là một cách viết CSS ngay trên thẻ, không phải kiến thức bắt buộc để được gọi là biết CSS.
Nếu bạn dùng Tailwind, hãy vẫn hiểu flex và grid ở dưới.
Vite là công cụ tạo app và chạy dev cho nhanh, không phải framework giao diện.
tsconfig trong repo là tín hiệu rõ.
Đừng kiểu hóa bằng any cho xong.
Đừng cài một bộ component lớn rồi không sửa được một khoảng cách.
Bài là một app đã có từ bước trước, nay có kiểu và vẫn chạy.
Hết bước này bạn viết test và đo trang bằng Lighthouse.
Một lỗi kiểu được sửa ngay còn hơn một buổi tranh luận về công cụ CSS.

## step 6

Giọng: Một test cho component và một lần triển khai có link là đủ để khép lộ trình.

Vitest hoặc Jest kèm thư viện kiểm thử component đều được.
Test nên render component với dữ liệu giả và bấm một nút, không cần mở trình duyệt thật cho mọi test.
Lighthouse chỉ ra trang nặng và nút không có tên, hãy sửa một hai mục chứ đừng đuổi điểm tuyệt đối.
GitHub Actions chạy test khi bạn đẩy mã.
Trang được triển khai và mở bằng một link là mốc cuối.
Đừng commit thư mục build nếu nền tảng tự build.
Đừng để test phụ thuộc mạng thật rồi lúc CI mất mạng thì đỏ.
README có cách cài, cách test và link bản chạy.
Hết lộ trình bạn có hai hoặc ba trang, giải thích được vì sao state không đổi ngay trong lần render.
Mình không nói bạn thành thạo React.
Biết chỉ ra dữ liệu nào là state và dữ liệu nào suy ra được mới là dấu hiệu hiểu.
