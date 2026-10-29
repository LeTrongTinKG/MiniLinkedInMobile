# Cache dữ liệu khi kéo job (Job Sync)

> Giải thích vì sao khi kéo job ta lưu câu trả lời của API ra file `.json`, và file đó hoạt động thế nào.
> Code nằm ở `server/src/services/job-sync/adapters/http.js`.

---

## Ý chính (2 câu)

1. **Thay vì mỗi lần sửa thuật toán lọc lại phải kéo API để test, ta ghi dữ liệu ra file một lần, các lần sau đọc lại từ file. Nhờ vậy không tốn request.**
2. **Lần sau muốn lấy dữ liệu mới thì kéo lại, và dữ liệu mới sẽ ghi đè lên file cũ nếu file đó đã có.**

---

## Vì sao cần

Mỗi lần gọi API thật là **tốn 1 request** trong số ít ỏi được phép dùng mỗi tháng (JSearch, SerpApi chỉ có vài trăm).

Khi làm, ta sửa cleaner nhiều lần (đổi cách đoán level, thêm kỹ năng...) và phải chạy lại để xem kết quả. Nếu lần nào cũng gọi API thì quota hết sau vài lần chạy. Lưu ra file thì chạy lại bao nhiêu lần cũng dùng cùng một bộ dữ liệu và không tốn request.

> Giống việc lưu kết quả `fetch` vào `localStorage` trong React: lần sau đọc `localStorage`, không gọi lại server.

---

## Hoạt động thế nào

File được lưu ở **`server/.cache/job-sync/`**, tên gồm nguồn và từ khóa, ví dụ `jsearch-fpt-software-fresher.json`.

Có hai cách chạy:

| Lệnh | Việc xảy ra |
|---|---|
| `node scripts/job-sync/sync-jobs.js --cache` | Có file thì **đọc file** (0 request). Chưa có file thì **gọi API rồi ghi file** |
| `node scripts/job-sync/sync-jobs.js` | **Luôn gọi API** (tốn request), rồi **ghi đè** file cũ bằng dữ liệu mới |

```
Chạy --cache, chưa có file:   gọi API → GHI file → đưa dữ liệu cho cleaner
Chạy --cache, đã có file:     ĐỌC file → đưa dữ liệu cho cleaner   (không tốn request)
Chạy không --cache:           gọi API → GHI ĐÈ file → đưa dữ liệu cho cleaner
```

Từ bước đưa dữ liệu cho cleaner trở đi, pipeline **không biết** dữ liệu đến từ API hay từ file, vì cả hai là cùng một khối JSON.

---

## Các bước tạo tên file

```
Từ khóa:               "FPT Software fresher"
slug (bỏ dấu, gạch nối): "fpt-software-fresher"
Thêm tiền tố nguồn:     "jsearch-fpt-software-fresher"
Ghép đường dẫn:         server/.cache/job-sync/jsearch-fpt-software-fresher.json
```

`slug` cần vì từ khóa có dấu tiếng Việt, khoảng trắng và ký tự lạ, không dùng được làm tên file trên Windows.

---

## Hai lần "ghi" khác nhau

Trong hệ thống có 2 lần ghi, đừng nhầm:

| | Ghi vào đâu | Để làm gì |
|---|---|---|
| **Ghi cache** | File `.json` trong `.cache/` | Nhớ câu trả lời của API, lần sau khỏi hỏi lại. **Dữ liệu thô**, chưa lọc |
| **Ghi database** | Bảng `jobs` | Lưu job đã qua cleaner + dedupe để app hiển thị. **Dữ liệu sạch** |

App chỉ đọc bảng `jobs`, **không bao giờ đọc file cache**.

---

## Lưu ý

- File cache là **dữ liệu cũ** tại lúc gọi. Muốn job mới thì chạy **không có `--cache`** (tốn request thật).
- Ghi đè nghĩa là **mất bản cũ**. Nếu đang chỉnh cleaner trên một bộ dữ liệu cụ thể, đừng chạy không `--cache` giữa chừng, vì dữ liệu sẽ bị thay.
- Chạy server (`node src/index.js`) **không** gọi API ngoài. Chỉ script `sync-jobs.js` mới gọi.
- Thư mục `.cache/` đã nằm trong `.gitignore`, không bị đẩy lên git. File cache không chứa API key. Xóa thư mục này chỉ mất bản lưu, lần sau phải gọi lại API và tốn request.
