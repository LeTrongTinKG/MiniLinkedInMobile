---
role: evidence
status: reviewed
---

# Bằng chứng skill

Giọng: Bằng chứng là commit của đúng tài khoản GitHub bạn đã liên kết, không phải một chữ trong README.

Một chữ flutter trong README chưa đủ để gọi là có hoạt động mã nguồn đáng kể.
Ngưỡng nhóm đang dùng là ít nhất năm commit, hai trăm dòng thêm, trải mười bốn ngày.
Mỗi ngày chỉ tính tối đa ba commit, nên dồn một ngày không làm ngưỡng tăng nhanh.
File sinh tự động và file khóa không được tính vào dòng thêm.
Commit đầu cực lớn chỉ bị bỏ khi lịch sử đã đọc tới gốc, để khỏi tính nhầm file tạo dự án.
Skill được gọi là evidenced khi có tín hiệu commit mạnh và thêm một tín hiệu độc lập.
Tín hiệu độc lập có thể là thư viện khai báo trong repo đã có commit hợp lệ, hoặc commit mạnh ở một repo khác.
Mọi trường hợp còn lại là bạn tự khai, dù bạn đã bấm thêm vào hồ sơ.
Nút thêm vào hồ sơ không tự nâng độ tin cậy.
Skill trong CV là một nguồn riêng, có câu trích nếu đọc được file, và vẫn chưa phải commit.
Khi nói về skill từ CV, mình nói có trong CV, không nói đã có bằng chứng.
Khi nói về skill GitHub đủ ngưỡng, mình nói có hoạt động mã nguồn đáng kể.
Quét GitHub chỉ nhìn repo công khai của đúng tài khoản đã liên kết.
Repo người khác, bài fork trống, hoặc tài khoản chưa liên kết thì không lấy làm bằng chứng.
Không có token đọc GitHub thì lượt quét dễ bị giới hạn và lần đó không trừ hạn mức tháng.
Hạn mức quét là ba lần thành công mỗi tháng theo giờ Việt Nam.
Lượt quét lỗi không bị tính vào hạn mức.
Skill bạn đã từ chối sẽ không được đề xuất lại trong bản này.
Muốn một skill cụ thể có bằng chứng, hãy commit đều vào repo có dùng skill đó rồi quét lại.
Khai báo thư viện trong pubspec hoặc package.json là tín hiệu nhìn thấy được, còn hơn chỉ viết tên trong README.
README vẫn nên có, vì người đọc và nhà tuyển dụng mở repo là thấy, nhưng README không thay commit.
Đừng tạo mười repo rỗng để đủ số, vì không repo nào đủ dòng và đủ ngày.
Một repo nhỏ làm thật, commit trong hai tuần, thường đáng tin hơn năm repo tutorial.
Mình không bảo bạn sửa lịch sử commit cho đẹp.
Mình không bảo bạn commit hộ bằng tài khoản người khác.
Nếu quét không thấy skill bạn biết là mình có, thường là do repo riêng tư hoặc commit chưa đủ ngày.
Khi đó cứ nói chưa đủ ngưỡng, rồi chỉ việc nên làm tiếp, không tranh cãi với máy quét.
Câu trích trong CV dài quá sẽ bị cắt, nên mình không dựa vào một câu trích để khen trình độ.
Skill job yêu cầu và skill bạn có là hai danh sách khác nhau, mình đối chiếu chứ không trộn.
Điểm khớp job dùng skill CV cộng skill GitHub đã duyệt, không dùng skill tự khai.
Chatbot vẫn được nhắc skill tự khai, nhưng phải gắn câu chưa có commit đủ ngưỡng.
Nguồn của phần này là ADR độ tin cậy và cách quét GitHub đang chạy trong server.
