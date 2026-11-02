---
role: data-ai
status: reviewed
---

# Ngữ cảnh Dữ liệu và AI (Python)

Nguồn: roadmap.sh phần Data Analyst và AI Engineer, tài liệu pandas về làm sạch dữ liệu và groupby, khảo sát Stack Overflow năm 2025 về mức dùng Python, và TopDev ghi Python trong nhóm kỹ năng được tuyển nhiều, với pandas là lựa chọn hay gặp.

## step 1

Giọng: Viết Python đọc một file và in một kết quả đúng trước khi mở notebook cho đẹp.

Python là ngôn ngữ của lộ trình này, dùng cho dữ liệu và cho API về sau.
Kiểu, hàm, list, dict và cách đọc file là phần tuần đầu.
Môi trường ảo giúp máy bạn không lẫn thư viện của từng bài.
pip cài vào môi trường đó, và requirements.txt ghi lại những gì bạn đã cài.
Git commit bài tập, dù chỉ là vài file.
Đừng mở pandas khi bạn còn nhầm indent.
Đừng học framework web ở bước này.
Lỗi hay gặp là chạy nhầm Python của hệ thống nên thiếu thư viện vừa cài.
Một repo có Python chiếm phần rõ và commit nhiều ngày là bằng chứng.
README nói cách tạo môi trường và cách chạy.
Hết bước này bạn mới viết SQL.
Mình không nhận một notebook không chạy lại được là xong bước.
Học đều mỗi ngày.
Nếu máy báo thiếu module, hãy kiểm tra môi trường trước khi cài lại toàn bộ.

## step 2

Giọng: Viết SQL trả lời một câu hỏi thật trên dữ liệu công khai, đừng học thuộc cú pháp suông.

SQL là cách hỏi dữ liệu đang nằm trong bảng.
SELECT, WHERE, JOIN, GROUP BY và ORDER BY là bộ tối thiểu.
JOIN sai sẽ nhân dòng, hãy đếm dòng trước và sau khi nối.
GROUP BY đi với hàm gộp, và mọi cột không gộp phải nằm trong nhóm.
Excel vẫn hữu ích để nhìn một bảng nhỏ và để đối chiếu một kết quả SQL.
Bài là một tệp các câu SQL, mỗi câu có một câu hỏi bằng lời ở trên.
Dữ liệu nên là bộ công khai, ghi nguồn trong README.
Đừng SELECT sao rồi xử lý hết trong đầu.
Đừng học cơ sở dữ liệu phân tán ở bước này.
Lỗi hay gặp là WHERE sau GROUP BY, trong khi điều kiện sau khi gộp phải là HAVING.
Bằng chứng là file SQL trong repo và kết quả bạn giải thích được.
Hết bước này bạn mới để pandas làm phần lặp lại cho nhanh.
Một câu JOIN đúng còn hơn mười hàm cửa sổ bạn chưa cần.
Mình không chấm cao vì câu SQL dài.

## step 3

Giọng: Làm sạch rồi mới vẽ, và mỗi bảng kết quả phải trả lời một câu hỏi.

Pandas là thư viện bảng của Python, hợp khi dữ liệu vừa, chưa cần một cụm máy.
Đọc file, xem vài dòng, đếm ô trống và đếm dòng trùng là việc đầu.
dropna hoặc điền giá trị phải có lý do, đừng xóa nửa bảng cho bảng sạch.
groupby là tách nhóm, tính trên từng nhóm, rồi ghép lại.
Đừng dùng apply nếu một phép có sẵn trên cả cột chạy được.
copy khi bạn cần một bảng mới, kẻo sửa nhầm bảng gốc.
Bài là một notebook hoặc một script phân tích một bộ dữ liệu thật, có requirements.txt.
Viết kết luận bằng câu, không chỉ để một biểu đồ không chú thích.
Đừng trộn dữ liệu thử và dữ liệu thật trong một file không ghi.
Lỗi hay gặp là lọc trên bản xem chứ không gán lại nên bước sau vẫn dùng dữ liệu cũ.
Bằng chứng là file khai báo pandas và một phân tích chạy lại được.
Hết bước này bạn trình bày cho người không viết mã.
Nếu kết quả không kèm câu hỏi, bước này chưa xong.
Ghi nguồn dữ liệu và ngày bạn tải.

## step 4

Giọng: Một biểu đồ đúng loại và một câu quyết định còn hơn một dashboard nhiều màu.

Trực quan hóa là chọn đúng dạng, không phải chọn màu đẹp.
So sánh vài nhóm thì biểu đồ cột thường rõ hơn biểu đồ tròn.
Đường hợp với thứ thay đổi theo thời gian.
Trục phải có tên và đơn vị.
Tableau hoặc một công cụ tương đương giúp bạn làm dashboard khi dữ liệu đã sạch.
Người đọc cần một câu họ làm được, ví dụ nên xem nhóm nào trước.
Hai hoặc ba bài phân tích, mỗi bài một quyết định, là đủ cho bước.
Đừng vẽ mười biểu đồ cùng một ý.
Đừng cắt trục để một khác biệt nhỏ trông thành lớn, trừ khi bạn ghi rõ.
Bằng chứng là file dashboard hoặc ảnh có chú thích nằm trong repo, kèm đoạn kết luận.
Hết bước này bạn mới đụng mô hình.
Mình không khen một báo cáo không nói nên làm gì.
Nếu số liệu và câu kết không khớp, hãy sửa câu, đừng sửa cho đẹp.

## step 5

Giọng: Chia tập học và tập kiểm trước khi kể một con số chính xác.

Học máy ở bước này là dùng mô hình có sẵn cho một câu hỏi phân loại hoặc dự đoán số.
Chia dữ liệu thành phần học và phần kiểm trước khi đo.
Đừng đo trên đúng dữ liệu đã học rồi báo một con số rất cao.
Hồi quy tuyến tính và một mô hình phân loại đơn giản là đủ để hiểu đo lường.
Độ chính xác không phải thước duy nhất khi một lớp chiếm gần hết dữ liệu.
Viết trong README bạn đo bằng gì và vì sao thước đó hợp.
scikit-learn là thư viện vừa sức, chưa cần tự viết thuật toán.
Đừng tải một mô hình lớn về cho một bảng vài trăm dòng.
Lỗi hay gặp là để cột đáp án lọt vào đặc trưng.
Bài là một mô hình chạy lại được, có số đo trên tập kiểm, và có câu mô hình này chưa đủ tốt chỗ nào.
Bằng chứng là mã và README, không phải một ảnh điểm số.
Hết bước này bạn mới bọc mô hình thành một API.
Mình không nói bạn đã biết học máy sâu.
Một kết quả trung thực còn hơn một kết quả đẹp trên dữ liệu đã thấy.

## step 6

Giọng: Một API nhận câu hỏi và trả kết quả có kiểm tra là đủ, đừng xây một agent.

Bước này là đưa một mô hình có sẵn vào một đường dẫn người khác gọi được.
FastAPI hợp vì khai báo dữ liệu vào và dữ liệu ra rõ.
Kiểm tra dữ liệu vào, và chịu được mô hình trả về một chuỗi lạ.
Đừng tin đầu ra của mô hình như một sự thật đã kiểm chứng.
Một bộ câu nhỏ để xem câu trả lời có đứng được không là phần đánh giá tối thiểu.
Huggingface là chỗ lấy mô hình có sẵn, bạn không cần huấn luyện lại trên máy cá nhân.
Đừng hứa mô hình không bịa.
Khóa gọi dịch vụ bên ngoài không được nằm trong repo.
Bài là một API nhỏ, README nói cách chạy và cách bạn đã thử vài câu.
Bằng chứng là file khai báo fastapi và mã mở được một cổng.
Hết lộ trình dữ liệu bạn có vài bài phân tích, và nếu theo hướng AI thì có thêm API này.
Việc AI engineer thường đến sau khi bạn đã có nền dữ liệu hoặc backend, đừng nhảy cóc.
Mình không nói bạn thành thạo AI.
Biết chỉ ra mô hình được đo bằng gì mới là dấu hiệu của bước này.
