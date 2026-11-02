// Dữ liệu demo: 5 tài khoản + 5 bài mỗi người (tiếng Việt, chủ đề cộng đồng dev).
const ACCOUNTS = [
  { fullName: "Nguyễn Minh Khoa", slug: "khoa" },
  { fullName: "Trần Thu Hà", slug: "ha" },
  { fullName: "Lê Quốc Bảo", slug: "bao" },
  { fullName: "Phạm Ngọc Lan", slug: "lan" },
  { fullName: "Võ Hoàng Nam", slug: "nam" },
];

// POSTS[i] là 5 bài của ACCOUNTS[i]
const POSTS = [
  [
    "Mẹo Flutter: bọc widget tĩnh bằng `const` giúp Flutter không build lại khi setState. Nhớ bật lint prefer_const_constructors nhé!",
    "Dart có toán tử ?? và ??= rất tiện:\n\nString name = user.name ?? 'Ẩn danh';\ncache ??= await loadData();\n\nCode ngắn hơn hẳn if-else.",
    "Mọi người quản lý state trong Flutter bằng gì? Mình đang phân vân giữa Provider và Riverpod cho đồ án. Ai dùng rồi cho mình xin ý kiến với!",
    "Hôm nay mình học được: ListView.builder chỉ dựng item đang hiển thị, còn ListView thường dựng hết một lượt. Danh sách dài thì luôn dùng builder.",
    "Đã xong màn hình đăng nhập cho app đồ án. Bài học lớn nhất: tách widget nhỏ ngay từ đầu, đừng để một file build() dài 500 dòng.",
  ],
  [
    "Express: nhớ bọc handler async bằng asyncHandler, nếu không lỗi trong Promise sẽ làm request treo mãi mà không trả về gì.",
    "Review CV cho bạn nào cần: mỗi dự án chỉ cần 3 dòng gồm công nghệ dùng, bạn làm phần nào, kết quả ra sao. Đừng liệt kê mọi thứ đã từng chạm vào.",
    "Câu hỏi phỏng vấn thực tập mình hay gặp: 'Khác nhau giữa let, const và var?'. Nắm chắc scope và hoisting là trả lời ổn rồi. Mọi người gặp câu nào khó hơn không?",
    "Cấu trúc thư mục Node mình đang dùng:\nroutes -> controllers -> services -> repositories\nMỗi tầng làm một việc, sửa một chỗ không kéo theo cả dự án.",
    "Cảm ơn mọi người đã góp ý CV tuần trước. Mình bỏ mục sở thích chung chung, thêm link GitHub, và đã được mời phỏng vấn!",
  ],
  [
    "React: đừng để useEffect fetch dữ liệu mà quên dependency array, nếu không component sẽ gọi API vô tận.",
    "SQL mẹo nhỏ: dùng EXPLAIN ANALYZE trước khi thêm index. Đo trước, tối ưu sau, đỡ đoán mò.",
    "Git: lỡ commit nhầm file .env thì xóa file ở commit sau là chưa đủ, secret vẫn nằm trong lịch sử. Hãy đổi key ngay và dọn lịch sử.",
    "Một đoạn code React mình hay dùng cho ô tìm kiếm:\n\nuseEffect(() => {\n  const t = setTimeout(() => search(q), 400);\n  return () => clearTimeout(t);\n}, [q]);\n\nĐây là debounce đơn giản nhất.",
    "Tuần này mình tự đặt mục tiêu mỗi ngày giải một bài thuật toán dễ. Có ai muốn lập nhóm học cùng để giữ động lực không?",
  ],
  [
    "Postgres: dùng cursor pagination (created_at, id) thay cho OFFSET khi bảng lớn, trang sâu vẫn nhanh và không bị trùng bài.",
    "Git workflow cho nhóm: mỗi tính năng một nhánh, đặt tên feat/ten-tinh-nang, mở PR nhỏ dễ review. Commit message viết rõ ràng nhé.",
    "Kinh nghiệm đi phỏng vấn thực tập: chuẩn bị sẵn 2 phút giới thiệu bản thân và 1 dự án bạn tự hào nhất. Nói được vì sao chọn công nghệ đó là điểm cộng lớn.",
    "Trong Dart, async/await trông như đồng bộ nhưng không chặn UI:\n\nFuture<void> load() async {\n  final data = await api.fetch();\n  setState(() => items = data);\n}\n\nNhớ kiểm tra mounted trước khi setState.",
    "Mọi người ôn SQL JOIN bằng cách nào cho nhớ lâu? Mình hay lẫn giữa LEFT JOIN và INNER JOIN. Chia sẻ mẹo giúp mình với!",
  ],
  [
    "Học lập trình đừng chỉ xem video. Mình dành 30% thời gian xem, 70% tự gõ lại và tự sửa lỗi, nhớ lâu hơn rất nhiều.",
    "Node.js: dùng biến môi trường cho mọi cấu hình (DB, key), và luôn có file .env.example để đồng đội biết cần khai báo gì.",
    "ReactJS: key trong danh sách nên là id ổn định, tránh dùng index khi danh sách có thể thêm xóa, nếu không UI dễ nhảy lung tung.",
    "Mình vừa làm xong bài test thực tập. Phần khó nhất không phải code mà là đọc kỹ đề. Lời khuyên: đọc đề hai lần trước khi gõ dòng đầu tiên.",
    "Review CV nhanh:\n- Một trang là đủ\n- Kỹ năng ghi đúng thứ bạn dùng được\n- Có link dự án thật\n- Kiểm tra lỗi chính tả\nBạn nào muốn góp ý CV thì cứ bình luận bên dưới nhé.",
  ],
];

module.exports = { ACCOUNTS, POSTS };
