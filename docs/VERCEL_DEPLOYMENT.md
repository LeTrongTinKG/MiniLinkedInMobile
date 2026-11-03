# HƯỚNG DẪN TRIỂN KHAI TỰ ĐỘNG FRONTEND LÊN VERCEL (ATOM WEB)

> **Dự án Atom** — Cập nhật: 2026-11-03  
> Hướng dẫn thiết lập quy trình CI/CD và triển khai ứng dụng Flutter Web lên Vercel.

---

## 1. TỔNG QUAN KIẾN TRÚC TRIỂN KHAI

Frontend của Atom được xây dựng bằng **Flutter Web**. Khi biên dịch sang Web Release:
- Sản phẩm đầu ra nằm tại: `app/build/web/`.
- Bao gồm các tệp tĩnh (Single Page Application - SPA): `index.html`, `main.dart.js`, `canvaskit/canvaskit.wasm`, thư mục `assets/` và biểu tượng icons.

Hệ thống đã được thiết lập sẵn **3 cơ chế tự động hóa**:
1. **Root `vercel.json`**: Cấu hình SPA rewrites (chuyển mọi URL về `index.html`), định tuyến header tối ưu hóa bộ nhớ đệm (Cache-Control) cho `wasm` và assets.
2. **Kịch bản tự động `scripts/build-vercel.sh`**: Tự động tải Flutter SDK, chạy `flutter pub get` và `flutter build web --release` với biến `API_URL`.
3. **GitHub Actions Workflow `.github/workflows/deploy-vercel.yml`**: Tự động kích hoạt khi có commit đẩy lên nhánh `main`.

---

## 2. CÁCH 1: KẾT NỐI TỰ ĐỘNG QUA GIAO DIỆN VERCEL (KHUYÊN DÙNG - KHÔNG CẦN CÀI ĐẶT THÊM)

Đây là cách phổ biến và tiện lợi nhất. Vercel sẽ tự động lắng nghe GitHub repository của bạn:

1. **Đăng nhập vào Vercel**: Truy cập [https://vercel.com/dashboard](https://vercel.com/dashboard).
2. **Thêm dự án mới**:
   - Bấm **Add New...** $\rightarrow$ **Project**.
   - Chọn kho mã nguồn GitHub của bạn: `MiniLinkedInMobile` (hoặc tên repo hiện tại).
3. **Cấu hình Project Settings trên Vercel**:
   - **Framework Preset**: Chọn **Other**.
   - **Root Directory**: Để trống (mặc định là thư mục gốc `./`).
   - **Build Command**: Vercel sẽ tự động nhận diện từ file `vercel.json`:
     ```bash
     bash scripts/build-vercel.sh
     ```
   - **Output Directory**: Vercel tự động nhận diện:
     ```text
     app/build/web
     ```
4. **Cấu hình Biến Môi trường (Environment Variables)**:
   - Thêm biến:
     - `API_URL`: Điền URL backend của bạn (ví dụ: `https://minilinkedinmobile.onrender.com/api/v1` hoặc URL Cloudflare Tunnel).
5. **Bấm "Deploy"**:
   - Vercel sẽ khởi chạy script `scripts/build-vercel.sh`, tải Flutter SDK và build toàn bộ website trong khoảng 2–3 phút.
   - Khi hoàn tất, bạn sẽ nhận được một đường link miễn phí dạng: `https://atom-mobile-xxx.vercel.app`.

---

## 3. CÁCH 2: TỰ ĐỘNG HÓA BẰNG GITHUB ACTIONS (CI/CD HOÀN CHỈNH)

Workflow đã được tạo tại `.github/workflows/deploy-vercel.yml`. Mỗi khi bạn merge code vào nhánh `main`, GitHub Actions sẽ:
- Chạy toàn bộ Unit Tests kiểm tra chất lượng.
- Biên dịch Flutter Web Release với cache Flutter SDK tốc độ cao.
- Triển khai trực tiếp lên Vercel.

### Cần thiết lập 3 Secrets trên GitHub Repository:
Vào GitHub $\rightarrow$ **Settings** $\rightarrow$ **Secrets and variables** $\rightarrow$ **Actions** $\rightarrow$ Bấm **New repository secret**:
1. `VERCEL_TOKEN`: Tạo tại [Vercel Account Settings -> Tokens](https://vercel.com/account/tokens).
2. `VERCEL_ORG_ID`: Lấy từ file `.vercel/project.json` hoặc trong Team Settings trên Vercel.
3. `VERCEL_PROJECT_ID`: Lấy từ Vercel Project Settings $\rightarrow$ General.
*(Tùy chọn: Thêm `API_URL` nếu muốn trỏ backend khác).*

---

## 4. CÁCH 3: TRIỂN KHAI NHANH BẰNG DÒNG LỆNH TỪ MÁY TÍNH (CLI)

Nếu bạn muốn deploy ngay lập tức từ máy cá nhân lên Vercel:

```bash
# 1. Đăng nhập Vercel (chỉ cần làm 1 lần)
npx vercel login

# 2. Chạy lệnh build và deploy production tự động
npm run deploy:vercel
```

Lệnh này sẽ tự động:
- Gọi `scripts/build-vercel.sh` để biên dịch Flutter Web ra `app/build/web/`.
- Triển khai trực tiếp bản build lên Vercel với cờ `--prod`.

---

## 5. KIỂM TRA ĐỊNH TUYẾN SPA VÀ TỐC ĐỘ

Sau khi deploy lên Vercel:
- **Kiểm tra F5 / Reload**: Bạn có thể truy cập bất kỳ trang nào (ví dụ: `https://your-domain.vercel.app/jobs`, `https://your-domain.vercel.app/profile`) và bấm F5 tải lại trang. Nhờ cấu hình `rewrites` trong `vercel.json`, trang sẽ không bao giờ bị lỗi 404.
- **Tối ưu hóa CanvasKit**: Toàn bộ file `canvaskit.wasm` và assets được gắn header `Cache-Control: immutable`, giúp các lần truy cập tiếp theo của người dùng tải gần như tức thì.
