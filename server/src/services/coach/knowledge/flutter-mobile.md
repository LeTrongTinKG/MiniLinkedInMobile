---
role: flutter-mobile
status: reviewed
---

# Ngữ cảnh Mobile (Flutter)

Nguồn: lộ trình học chính thức của Flutter tại docs.flutter.dev, roadmap.sh phần Flutter, và ghi nhận của TopDev rằng Flutter là một lựa chọn chính cho việc làm di động ở Việt Nam.

## step 1

Giọng: Học Dart vừa đủ để đọc lỗi, rồi mới mở Flutter, đừng đảo thứ tự.

Dart là ngôn ngữ Flutter dùng, nên tuần đầu mình dành cho Dart chứ không cho widget.
Cài Flutter SDK, Git và một trình soạn thảo là đủ để chạy app đầu tiên.
Máy ảo Android hoặc một điện thoại thật đều được, không cần đủ cả hai hệ điều hành ngay.
Biến, hàm, lớp và null safety là phần Dart mình cần trước.
Null safety nghĩa là chỗ nào có thể rỗng phải viết rõ, để lỗi hiện lúc viết chứ không lúc người dùng bấm.
async và await là cách chờ một việc lâu mà không khóa giao diện.
Nếu bạn đã biết một ngôn ngữ hướng đối tượng, Dart sẽ quen ở lớp và lạ ở cách chờ việc.
Đừng học isolate, generator hay metaprogramming ở bước này.
Một repo chỉ có vài file Dart, commit nhiều ngày, đã là bằng chứng của bước nền.
Tên repo và README một đoạn ngắn nói bài tập làm gì.
Đừng để tuần đầu trôi vào việc chọn theme và icon.
Lỗi đỏ đầu tiên thường là SDK chưa vào PATH hoặc máy ảo chưa bật, đọc dòng đó trước.
Bạn chưa cần hiểu cách Flutter vẽ từng pixel.
Mục tiêu của bước này là sửa được một chương trình Dart nhỏ khi nó báo lỗi.
Hết bước này bạn chuyển sang màn hình tĩnh, chưa cần nút bấm phức tạp.
Học đều mỗi ngày ngắn còn hơn một buổi dài rồi nghỉ cả tuần.
Mình không tính bạn đã biết Dart chỉ vì làm xong một video.
Nếu GitHub chưa có commit Dart nào, bước này chưa có bằng chứng dù máy bạn chạy được.
Câu hỏi hay gặp là sự khác nhau giữa một biến có thể rỗng và một biến chắc chắn có giá trị.

## step 2

Giọng: Làm một màn hình tĩnh chạy được trước khi nghĩ tới trạng thái.

Flutter dựng giao diện bằng widget, và hầu hết widget bạn dùng lúc đầu là widget có sẵn.
Stateless widget là màn không tự nhớ gì, stateful widget là màn có thể đổi sau một sự kiện.
Row, Column, Stack và ListView giải quyết phần lớn bố cục của app sinh viên.
Container chỉ nên bọc khi bạn thật sự cần khoảng cách, màu hoặc bo góc.
Scaffold và AppBar cho bạn khung một màn hình chuẩn, đừng tự vẽ thanh trên từ đầu.
Làm app máy tính hoặc app chỉ số cơ thể là đủ cho bước này.
App phải chạy trên máy ảo và mã phải nằm trên GitHub cùng file pubspec.
Đừng cài thư viện trạng thái ở bước widget.
Đừng làm đẹp từng pixel trước khi danh sách cuộn được.
Lỗi tràn một vài pixel là lỗi bố cục, đọc dòng overflow rồi bọc Expanded hoặc cuộn, đừng đoán số.
Theme sáng tối có thể để sau, khi màn chính đã đứng.
Bạn nên đặt tên widget theo màn hình, không đặt tên Widget1.
Tách một màn dài thành vài widget nhỏ ngay khi bạn phải cuộn mã để tìm nút.
Bằng chứng là repo có pubspec và nhiều file Dart, không phải một ảnh chụp màn hình.
Hết bước này bạn mới cho người dùng nhập và chuyển màn.
Nếu mới chỉ có trang HTML, bước Flutter này vẫn chưa bắt đầu.
Mình muốn thấy app mở lên được, không cần animation.

## step 3

Giọng: Một app việc cần làm có lưu lại là đủ cho bước trạng thái, đừng làm app lớn.

Bước này là lúc app có nhiều màn và có dữ liệu người dùng gõ vào.
Điều hướng là chuyển màn và đưa dữ liệu sang màn sau, không phải vẽ lại mọi thứ trong một file.
Form cần báo lỗi ngay dưới ô nhập, không chỉ hiện một dòng chung chung.
setState đủ cho app một màn đang đổi.
Provider là cách tách chỗ nhớ dữ liệu ra khỏi widget khi app có vài màn cùng đọc.
Chọn Provider cho bước này, chưa cần thư viện nặng hơn.
App việc cần làm, thêm được, xóa được, tắt app mở lại vẫn còn, là sản phẩm của bước.
Khai báo thư viện trong pubspec để lần quét GitHub nhìn thấy.
Đừng vừa học điều hướng vừa đổi sang kiến trúc nhiều lớp.
Đừng lưu mật khẩu vào bộ nhớ cục bộ không mã hóa.
Truyền cả object lớn qua điều hướng dễ vỡ, truyền cái id rồi đọc lại thì rõ hơn.
Nút bấm phải có lúc đang xử lý, kẻo người dùng bấm hai lần.
Danh sách rỗng cần một câu trên màn, không để trang trắng.
Bằng chứng là repo có Provider trong pubspec và commit trải nhiều ngày.
Nếu Provider mới là chữ bạn tự khai, mình vẫn nói chưa đủ ngưỡng commit.
Hết bước này bạn mới gọi mạng.

## step 4

Giọng: Gọi một API công khai, có lúc đang tải và lúc lỗi, rồi hãy nghĩ tới Firebase.

Dữ liệu thật nghĩa là app lấy số từ nơi khác, không gõ sẵn trong mã.
Một lời gọi HTTP trả về JSON, bạn đổi JSON thành object của app.
Màn hình cần ba trạng thái, đang tải, có dữ liệu, và lỗi kèm nút thử lại.
FutureBuilder hoặc một chỗ tương đương giúp bạn không quên trạng thái đang tải.
App thời tiết hoặc app ghi chú gọi API là bài vừa sức.
Đừng gọi mạng ngay trong hàm build nếu mỗi lần vẽ lại là một request mới.
Đừng tin API luôn trả đúng dạng, hãy chịu được một trường thiếu.
Firebase là một lựa chọn cho đăng nhập và lưu đám mây, không phải việc bắt buộc của mọi app.
Làm Firebase khi bài của bạn thật sự có người dùng và dữ liệu cần giữ trên mây.
Shared preferences chỉ dành cho cài đặt nhỏ, không nhét cả danh sách dài vào đó.
SQLite hoặc một kho cục bộ dành cho dữ liệu bạn cần khi mất mạng.
Bằng chứng là repo có lời gọi API thật và xử lý lỗi nhìn thấy được trong mã.
Khóa API không được commit, để trong biến môi trường hoặc file bị git bỏ qua.
Hết bước này bạn mới chọn một cách quản lý trạng thái nâng cao.
Nếu job yêu cầu REST và Firebase mà repo chưa có, mình nói còn thiếu, không nói gần xong.

## step 5

Giọng: Chọn một thư viện trạng thái và một cách chia thư mục, rồi giữ đến hết dự án.

Bước này dành cho app đã có vài màn và bạn bắt đầu lạc trong setState.
Bloc hoặc Riverpod đều được việc, mình khuyên chọn một và đọc cho hiểu.
Nếu job bạn đang xem ghi Bloc, hãy chọn Bloc cho đúng bài đó.
Riverpod hợp khi bạn muốn khai báo chỗ nhớ dữ liệu mà không cần một lớp sự kiện dài.
Đừng học cả hai cùng lúc để ghi cho đủ vào CV.
MVVM ở đây nghĩa là màn hình không tự gọi mạng, màn hình chỉ hiện cái một lớp khác đưa cho.
Chia thư mục theo tính năng thường dễ tìm hơn chia theo loại file khi app lớn.
Một app chi tiêu hoặc app có danh sách và màn chi tiết là đủ để luyện.
Viết được vì sao bạn chọn thư viện đó, trong README, là phần người đọc cần.
Đừng đổi thư viện giữa chừng chỉ vì một bài viết mới.
Đừng tạo mười lớp cho một màn hình chỉ có một nút.
Bằng chứng là pubspec có đúng một thư viện trạng thái bạn chọn, và thư mục nhìn ra được ý.
Hết bước này bạn mới tính kiểm thử và đưa app lên cửa hàng.
Mình không chấm bạn cao hơn chỉ vì dùng nhiều thư viện.

## step 6

Giọng: Một bài kiểm thử cho phần tính toán và một workflow chạy khi bạn đẩy mã là đủ.

Kiểm thử đơn vị dành cho hàm tính, kiểm thử widget dành cho một màn hình với dữ liệu giả.
Bạn không cần phủ hết mọi dòng mới được nhận là có kiểm thử.
DevTools giúp nhìn widget nào vẽ lại và chỗ nào tốn bộ nhớ.
Đưa app lên bản cài được trên Android là một mốc, iOS làm khi bạn có máy và tài khoản.
GitHub Actions chạy test mỗi lần đẩy mã, đó là phần CI mình muốn thấy.
File workflow nằm trong repo là bằng chứng rõ hơn câu nói em có dùng CI.
Đừng khóa cổng ký ứng dụng trong repo.
Đừng bỏ qua một test đang đỏ rồi vẫn khoe là có CI.
Hiệu năng chỉ cần nhìn khi danh sách dài bị giật, chưa cần tối ưu từ ngày đầu.
Ảnh chuẩn để so giao diện là việc sau, khi giao diện đã ổn định.
README cuối nên có cách chạy test và cách build.
Hết lộ trình bạn có hai hoặc ba app, không phải một app duy nhất ôm mọi kỹ năng.
Biết giải thích một thư viện trạng thái còn hơn biết tên của năm thư viện.
Mình vẫn không nói bạn thành thạo Flutter chỉ vì đã đi hết các bước.
