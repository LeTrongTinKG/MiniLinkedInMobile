// Lưu ảnh social lên Supabase Storage (bucket riêng, mặc định "social-media").
const crypto = require("node:crypto");
const storageService = require("../../storage/storage.service");

function getBucket() {
  return process.env.SOCIAL_STORAGE_BUCKET || "social-media";
}

// Đường dẫn thumbnail suy ra từ đường dẫn ảnh chính: abc.webp -> abc_thumb.webp
function thumbPathOf(storagePath) {
  return storagePath.replace(/\.webp$/, "_thumb.webp");
}

// Upload ảnh chính + thumbnail. Đường dẫn: social/{userId}/{uuid}.webp
async function saveImages({ userId, main, thumb }) {
  const bucket = getBucket();
  const basePath = `social/${userId}/${crypto.randomUUID()}.webp`;

  const mainFile = await storageService.uploadToBucket({
    bucket,
    path: basePath,
    buffer: main,
    contentType: "image/webp",
  });
  const thumbFile = await storageService.uploadToBucket({
    bucket,
    path: thumbPathOf(basePath),
    buffer: thumb,
    contentType: "image/webp",
  });
  return { storagePath: mainFile.path, url: mainFile.url, thumbnailUrl: thumbFile.url };
}

// Xóa ảnh (cả bản thumbnail) theo danh sách đường dẫn ảnh chính
async function removeImages(storagePaths) {
  const paths = storagePaths.flatMap((p) => [p, thumbPathOf(p)]);
  return storageService.removeFromBucket(getBucket(), paths);
}

module.exports = { saveImages, removeImages, thumbPathOf, getBucket };
