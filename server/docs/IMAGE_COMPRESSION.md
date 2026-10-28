# Thuật toán nén ảnh (Module Social)

> Giải thích cách ảnh được nén khi người dùng đăng bài trong module mạng xã hội, và lý do chọn các tham số.
> Đọc file này khi thắc mắc: vì sao ảnh bị thu nhỏ, vì sao đổi sang WebP, vì sao mất thông tin EXIF, vì sao screenshot code không bị nhòe.

---

## 1. Vì sao phải nén

- Ảnh chụp bằng điện thoại hiện nay thường nặng **3–8MB**.
- Không nén thì: upload chậm, feed tải chậm, tốn data di động của người dùng, Supabase Storage (free tier) nhanh đầy.
- Sau khi nén, ảnh còn khoảng **300–500KB**, mắt thường gần như không thấy khác.

---

## 2. Hai loại nén

| Loại | Ý nghĩa | Ví dụ | Dùng cho |
|---|---|---|---|
| **Không mất dữ liệu** (lossless) | Giải nén ra giống hệt bản gốc | ZIP, PNG, WebP lossless | Văn bản, ảnh chụp màn hình |
| **Có mất dữ liệu** (lossy) | Bỏ đi những chi tiết mắt người khó nhận ra | JPEG, WebP lossy | Ảnh chụp |

Nén ảnh cho mạng xã hội dựa trên **giới hạn của mắt người**: phần mắt không thấy rõ thì bỏ bớt.

---

## 3. Pipeline 5 bước

```
Ảnh gốc ─► ① Xoay đúng chiều ─► ② Thu nhỏ ─► ③ Mã hóa JPEG/WebP ─► ④ Xóa EXIF ─► ⑤ Tạo thumbnail
 ~5MB                                                                              ~400KB + ~40KB
```

### Bước ① Xoay đúng chiều

Điện thoại thường **không xoay điểm ảnh** khi chụp dọc. Nó lưu ảnh nằm ngang và ghi thêm cờ `Orientation = xoay 90°` vào EXIF.

→ Phải **xoay điểm ảnh theo cờ này trước**, rồi mới xóa EXIF ở bước ④.
Làm ngược thứ tự thì cờ mất, ảnh chụp dọc đăng lên bị **nằm ngang**.

### Bước ② Thu nhỏ (resize): giảm dung lượng nhiều nhất

- Camera 12MP cho ảnh 4000×3000 = **12 triệu điểm ảnh**. Màn hình điện thoại chỉ rộng khoảng 1080 điểm.
- Thu về **cạnh dài 1920px**: 1920×1440 = **2,76 triệu điểm ảnh**, giảm khoảng **4,3 lần** trước khi nén.
- Ảnh vốn đã nhỏ hơn 1920px thì **không phóng to**.

**Thuật toán lấy mẫu lại (resampling):**

| Thuật toán | Cách làm | Kết quả | Dùng? |
|---|---|---|---|
| **Lanczos** | Mỗi điểm ảnh mới được tính từ nhiều điểm gốc xung quanh, có trọng số | Nét, không răng cưa | ✅ |
| Bilinear | Trung bình 4 điểm gần nhất | Hơi mờ khi thu nhỏ nhiều | Tạm được |
| Nearest neighbor | Lấy 1 điểm gần nhất | Răng cưa | ❌ |

### Bước ③ Mã hóa JPEG: 5 bước con

#### a. Đổi hệ màu RGB → YCbCr

Tách ảnh thành 1 kênh **độ sáng (Y)** và 2 kênh **màu (Cb, Cr)**.
Lý do: mắt người nhạy với **độ sáng** hơn nhiều so với **màu sắc**.

#### b. Lấy mẫu màu thưa (chroma subsampling 4:2:0)

- Kênh sáng: giữ nguyên.
- Kênh màu: cứ **4 điểm ảnh (2×2) chỉ giữ 1 giá trị màu**.

→ **Giảm 50% dữ liệu**, mắt gần như không nhận ra.

#### c. Chia khối 8×8 và biến đổi DCT (Discrete Cosine Transform)

Ảnh được cắt thành các khối 8×8 điểm. Mỗi khối được biểu diễn lại theo **tần số** thay vì từng điểm ảnh:

- **Tần số thấp:** mảng màu lớn, chuyển màu từ từ. Mắt **rất nhạy**.
- **Tần số cao:** chi tiết li ti, nhiễu, cạnh sắc. Mắt **kém nhạy**.

Bước này **chưa mất dữ liệu**, chỉ đổi cách biểu diễn. Nó gom phần quan trọng về một góc của khối.

#### d. Lượng tử hóa (quantization): bước duy nhất làm mất dữ liệu

Mỗi hệ số tần số được **chia cho một số trong bảng lượng tử rồi làm tròn**:

- Tần số thấp chia số nhỏ → giữ lại gần như nguyên vẹn.
- Tần số cao chia số lớn → đa số bị làm tròn về **0**.

Tham số **quality (1–100)** quyết định bảng lượng tử:
quality càng thấp → số chia càng lớn → càng nhiều số 0 → **file càng nhỏ, ảnh càng mờ**.

#### e. Mã hóa entropy (không mất dữ liệu)

1. **Zigzag:** đọc 64 hệ số theo đường chéo từ tần số thấp tới cao, để các số 0 dồn về cuối.
2. **RLE (Run-Length Encoding):** chuỗi số 0 liên tiếp được viết gọn kiểu "23 số 0 liên tiếp".
3. **Huffman:** giá trị xuất hiện nhiều được gán mã ngắn, giá trị hiếm được gán mã dài.

**Giải nén** chạy ngược lại: Huffman → nhân với bảng lượng tử → DCT ngược → ghép khối → đổi về RGB.

**Dấu hiệu nén quá tay:** ảnh lộ ô vuông 8×8 (blocking) và có gợn quanh chữ và cạnh sắc (ringing).

#### WebP: định dạng app dùng

WebP (của Google) dựa trên cùng ý tưởng với JPEG, cộng thêm:

- **Dự đoán khối (intra prediction):** đoán nội dung một khối từ các khối kế bên, và **chỉ lưu phần sai khác**. Phần sai khác thường nhỏ nên nén được nhiều hơn.
- Khối biến đổi nhỏ hơn (4×4), và mã hóa số học hiệu quả hơn Huffman.

→ **Nhỏ hơn JPEG khoảng 25–30% ở cùng chất lượng nhìn thấy**, có thêm chế độ **lossless**.
Flutter và Android/iOS hiện đại đều hiển thị được WebP.

### Bước ④ Xóa EXIF: bảo vệ quyền riêng tư

EXIF là siêu dữ liệu đi kèm ảnh, chứa:

- **Tọa độ GPS nơi chụp.** Ảnh chụp ở nhà sẽ lộ địa chỉ nhà.
- Model điện thoại, thời điểm chụp, thông số máy.

Server **mã hóa lại ảnh và không ghi lại EXIF**, nên toàn bộ siêu dữ liệu biến mất.
Bước này **bắt buộc ở server**, vì client có thể bỏ qua bước nén (ví dụ gọi thẳng API).

### Bước ⑤ Tạo thumbnail

- Server tạo thêm 1 bản **cạnh dài 400px, quality 70**, nặng khoảng **30–50KB**.
- Feed hiển thị thumbnail. Ảnh 1920px chỉ tải khi người dùng bấm vào xem.

---

## 4. Trường hợp đặc biệt

### 4.1 Ảnh chụp màn hình code

Đây là mạng xã hội cho dev, nên người dùng sẽ đăng nhiều **screenshot code**.

JPEG / WebP lossy làm **nhòe chữ**: bảng lượng tử cắt tần số cao, mà cạnh của chữ chính là tần số cao.

| Ảnh gốc | Thường là | Nén bằng |
|---|---|---|
| **PNG** | Ảnh chụp màn hình | **WebP lossless**: chữ sắc nét, vẫn nhỏ hơn PNG |
| **JPEG / HEIC** | Ảnh chụp camera | **WebP lossy**, quality 80 |

### 4.2 Tránh nén chồng (generation loss)

Mỗi lần nén lossy lại làm tròn thêm một lần, nên chất lượng giảm dần qua từng lần nén. Do đó:

- Ảnh đã nhỏ (**≤ 1920px và ≤ 500KB**) thì **không nén lại**, chỉ xoay và xóa EXIF.
- Client nén 1 lần, server **chỉ mã hóa lại khi cần** (để xóa EXIF hoặc khi ảnh vượt giới hạn).

---

## 5. Tham số chốt

| | Ảnh chụp | Ảnh chụp màn hình | Thumbnail |
|---|---|---|---|
| Kích thước tối đa | Cạnh dài 1920px | Cạnh dài 1920px | Cạnh dài 400px |
| Định dạng đầu ra | WebP lossy | WebP lossless | WebP lossy |
| Quality | 80 | — | 70 |
| Resampling | Lanczos | Lanczos | Lanczos |
| Giới hạn file nhận vào | ≤ 10MB | ≤ 10MB | — |
| Dung lượng sau nén | ~300–500KB | Tùy nội dung | ~30–50KB |
| EXIF | Xóa | Xóa | Xóa |

---

## 6. Phân công client / server

| Bước | Flutter (trước khi gửi) | Server (khi nhận) |
|---|---|---|
| ① Xoay đúng chiều | ✅ | ✅ (phòng khi client bỏ qua) |
| ② Thu nhỏ | ✅ | ✅ nếu ảnh vẫn vượt 1920px |
| ③ Nén | ✅ lần đầu | Chỉ khi cần (mục 4.2) |
| ④ Xóa EXIF | Nên làm | ✅ **bắt buộc** |
| ⑤ Thumbnail | — | ✅ |
| Kiểm tra magic bytes (JPEG, PNG, WebP, HEIC) | — | ✅ **bắt buộc** (cùng cách đang kiểm tra PDF cho CV) |
| Chặn file > 10MB | ✅ báo lỗi sớm | ✅ **bắt buộc** |

**Nguyên tắc:** client nén để **upload nhanh**, server kiểm tra và xử lý lại để **an toàn**. Server không bao giờ tin dữ liệu từ client.

---

## 7. Video

Video dùng thuật toán khác (H.264: khung I/P/B, ước lượng chuyển động) và không đi qua server Node.
Video thuộc **giai đoạn 2**, sẽ có tài liệu riêng trong thư mục này khi triển khai.
