# Hướng Dẫn Quay & Dựng Video Demo Dự Án Atom Với Remotion

Tài liệu này hướng dẫn cách sử dụng [Remotion](https://www.remotion.dev/) đã được tích hợp trong dự án **Atom** (`MiniLinkedInMobile`) để tạo video demo chuyên nghiệp, đồ họa chuyển động mượt mà (60/30fps), phục vụ báo cáo đồ án, thuyết trình nhà tuyển dụng và đăng tải mạng xã hội (YouTube, TikTok, Facebook).

---

## 1. Cấu trúc Thư mục Remotion trong Dự án

Toàn bộ mã nguồn video được đóng gói độc lập trong thư mục `video/`:

```
video/
├── remotion.config.ts        # Cấu hình Rspack & TailwindCSS v4
├── package.json              # Remotion v4.0.540, React 19, Lucide Icons
├── public/                   # Thư mục chứa tài nguyên tĩnh (video quay thật, ảnh)
│   └── demo-screen.mp4       # Video quay màn hình thực tế (nếu có)
├── src/
│   ├── Root.tsx              # Đăng ký các Composition & Still
│   ├── index.ts              # Entry point Remotion Studio
│   └── AtomDemo/
│       ├── AtomDemo.tsx      # Timeline tổng hợp 5 phân cảnh (30s)
│       ├── IntroScene.tsx    # Phân cảnh 1: Giới thiệu thương hiệu Atom & Logo phát sáng
│       ├── SkillExtractionScene.tsx # Phân cảnh 2: AI Scan CV & 3-Tier Git Verification
│       ├── CareerCoachScene.tsx     # Phân cảnh 3: Chatbot AI Coach (Qwen 2B & Guardrails)
│       ├── JobMatchingScene.tsx     # Phân cảnh 4: Khớp việc 96% & Nộp hồ sơ 1 chạm
│       ├── OutroScene.tsx    # Phân cảnh 5: Call To Action & Link Web Vercel
│       ├── ScreenRecordingPlayer.tsx # Mockup trình duyệt/điện thoại lồng video quay thật
│       ├── AtomThumbnail.tsx # Ảnh bìa Thumbnail chất lượng cao 1920x1080
│       └── types.ts          # Bảng màu Atom Clay Minimalist (#2563EB)
└── out/                      # Nơi xuất video và ảnh đã render
    ├── atom-demo.mp4         # Video demo hoàn chỉnh
    └── atom-thumbnail.png    # Ảnh bìa sắc nét
```

---

## 2. Các Lệnh Điều Khiển Nhanh (Root Terminal)

Từ thư mục gốc dự án `MiniLinkedInMobile/`, bạn có thể chạy:

| Lệnh | Mô tả |
| :--- | :--- |
| `npm run video:dev` | Khởi chạy **Remotion Studio** tại `http://localhost:3100` để xem trước, kéo timeline và chỉnh sửa real-time |
| `npm run video:render` | Biên dịch và xuất video Full HD 16:9 (`out/atom-demo.mp4`) |
| `npm run video:render:portrait` | Biên dịch video dọc 9:16 cho TikTok / Reels / Shorts (`out/atom-demo-portrait.mp4`) |
| `npm run video:still` | Xuất ảnh bìa Thumbnail 1920x1080 (`out/atom-thumbnail.png`) |

---

## 3. Xem Trước & Tinh Chỉnh Trên Remotion Studio

1. Chạy lệnh:
   ```bash
   npm run video:dev
   ```
2. Mở trình duyệt tại: `http://localhost:3100`
3. Tại giao diện Remotion Studio:
   - Cột bên trái hiển thị danh sách các Composition:
     - **AtomDemo**: Bản demo ngang 16:9 chuẩn thuyết trình.
     - **AtomDemoPortrait**: Bản demo dọc 9:16 cho di động.
     - **AtomScreenMockup**: Khung MacBook phát video quay màn hình thật.
     - **AtomThumbnail**: Ảnh cover độ phân giải cao.
   - Bạn có thể ấn Space để phát/dừng, kéo thanh thời gian (Timeline) tới từng frame, hoặc thay đổi các thông số (props) ngay trên bảng điều khiển bên phải.

---

## 4. Cách Lồng Video Màn Hình Thực Tế (Screen Recording)

Nếu bạn muốn kết hợp giữa motion graphics và video quay màn hình thực tế (trên web Vercel `https://atom-web-ten.vercel.app` hoặc máy ảo iOS/Android):

1. **Quay màn hình**:
   - Trên macOS: Bấm `Cmd + Shift + 5` $\rightarrow$ Chọn vùng màn hình web Atom $\rightarrow$ Bấm **Record**.
   - Thao tác các tính năng: Đăng nhập GitHub, Chat với Career Coach, Duyệt việc, Tải lên CV.
   - Dừng quay và lưu file video dạng `.mp4` hoặc `.webm`.
2. **Đưa file vào thư mục Remotion**:
   - Đổi tên file video thành `demo-screen.mp4`.
   - Đặt file vào thư mục: `video/public/demo-screen.mp4`.
3. **Mở Composition `AtomScreenMockup`**:
   - Remotion sẽ tự động lồng video của bạn vào bên trong khung MacBook Retina bóng bẩy với thanh tiêu chỉ `https://atom-web-ten.vercel.app`.
   - Chạy lệnh render riêng cho phân đoạn này:
     ```bash
     cd video && npx remotion render AtomScreenMockup out/screen-demo.mp4
     ```

---

## 5. Xuất Video Ra File MP4 Hoàn Chỉnh

Để render bản video chính thức:
```bash
npm run video:render
```
Quá trình render sử dụng phần cứng GPU (Apple Silicon / Chrome Headless Shell đa luồng) để xuất file video chuẩn `H.264` sắc nét, dung lượng tối ưu, sẵn sàng nộp bài và trình chiếu.

