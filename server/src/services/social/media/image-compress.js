// Nén ảnh bằng sharp. Giải thích thuật toán: server/Thuật toán/IMAGE_COMPRESSION.md
const sharp = require("sharp");
const { ApiError } = require("../../../middleware/error");

const MAX_SIDE = 1920; // cạnh dài tối đa của ảnh chính
const THUMB_SIDE = 400; // cạnh dài của thumbnail
const SMALL_BYTES = 500 * 1024; // ảnh đã nhỏ hơn mức này thì không nén lại
const QUALITY = 80;
const THUMB_QUALITY = 70;

// Thu nhỏ về cạnh dài tối đa `side`, không phóng to ảnh nhỏ, dùng thuật toán Lanczos3 cho nét
function resizeOptions(side) {
  return { width: side, height: side, fit: "inside", withoutEnlargement: true, kernel: "lanczos3" };
}

// Không gọi withMetadata() nên sharp tự BỎ toàn bộ EXIF (vị trí GPS, tên máy ảnh...)
async function compressImage(buffer, kind) {
  try {
    // Bước 1: xoay ảnh đúng chiều theo cờ EXIF (phải làm TRƯỚC khi bỏ EXIF)
    const rotated = await sharp(buffer).rotate().toBuffer({ resolveWithObject: true });
    const { width, height } = rotated.info;
    const isSmall = Math.max(width, height) <= MAX_SIDE && buffer.length <= SMALL_BYTES;

    // Bước 2 + 3: thu nhỏ rồi mã hóa WebP
    //  - PNG (screenshot, chữ): WebP lossless, giữ nguyên từng điểm ảnh, không bị nhòe
    //  - Ảnh nhỏ sẵn: không nén lossy thêm, dùng near-lossless (gần như giữ nguyên)
    //  - Ảnh khác (ảnh chụp): WebP lossy quality 80
    let webpOptions = { quality: QUALITY };
    if (kind === "png") webpOptions = { lossless: true };
    else if (isSmall) webpOptions = { nearLossless: true, quality: 90 };

    const main = await sharp(rotated.data)
      .resize(resizeOptions(MAX_SIDE))
      .webp(webpOptions)
      .toBuffer({ resolveWithObject: true });

    // Bước 5: thumbnail cạnh dài 400, quality 70
    const thumb = await sharp(rotated.data)
      .resize(resizeOptions(THUMB_SIDE))
      .webp({ quality: THUMB_QUALITY })
      .toBuffer({ resolveWithObject: true });

    return {
      main: { buffer: main.data, width: main.info.width, height: main.info.height },
      thumb: { buffer: thumb.data, width: thumb.info.width, height: thumb.info.height },
    };
  } catch (err) {
    if (err instanceof ApiError) throw err;
    // Ảnh hỏng / sharp không đọc được
    throw new ApiError(400, "INVALID_FILE_TYPE", "Không đọc được ảnh, file có thể bị hỏng");
  }
}

module.exports = { compressImage, MAX_SIDE, THUMB_SIDE };
