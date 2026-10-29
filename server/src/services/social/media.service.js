// Upload ảnh: kiểm tra -> nén -> lưu storage -> ghi DB (chưa gắn bài).
const mediaRepo = require("../../repositories/social/media.repository");
const { validateImage } = require("./media/image-validate");
const { compressImage } = require("./media/image-compress");
const socialStorage = require("./media/social-storage");

async function uploadImage({ userId, file }) {
  const kind = validateImage(file);
  const { main, thumb } = await compressImage(file.buffer, kind);

  const saved = await socialStorage.saveImages({
    userId,
    main: main.buffer,
    thumb: thumb.buffer,
  });

  const media = await mediaRepo.insertMedia({
    uploaderId: userId,
    url: saved.url,
    thumbnailUrl: saved.thumbnailUrl,
    storagePath: saved.storagePath,
    width: main.width,
    height: main.height,
  });

  return {
    mediaId: media.id,
    url: media.url,
    thumbnailUrl: media.thumbnailUrl,
    width: media.width,
    height: media.height,
  };
}

// Dọn ảnh rác (upload quá 24h mà không gắn bài nào): xóa file trên storage rồi xóa dòng DB
async function cleanupOrphanMedia(olderThanHours = 24) {
  const orphans = await mediaRepo.findOrphanMedia(olderThanHours);
  if (orphans.length === 0) return 0;
  await socialStorage.removeImages(orphans.map((o) => o.storagePath));
  return mediaRepo.deleteMediaByIds(orphans.map((o) => o.id));
}

module.exports = { uploadImage, cleanupOrphanMedia };
