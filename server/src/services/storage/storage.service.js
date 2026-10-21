const crypto = require("node:crypto");
let supabaseClient = null;

function getSupabaseClient() {
  if (supabaseClient) return supabaseClient;

  const url = process.env.SUPABASE_URL;
  const key = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_ANON_KEY;

  if (url && key) {
    try {
      const { createClient } = require("@supabase/supabase-js");
      supabaseClient = createClient(url, key);
      return supabaseClient;
    } catch (_err) {
      return null;
    }
  }
  return null;
}

function getBucketName() {
  return process.env.SUPABASE_STORAGE_BUCKET || "cvs";
}

function sanitizeFileName(name) {
  if (!name) return "cv.pdf";
  // Loại bỏ các ký tự đặc biệt, giữ lại chữ cái, số, dấu gạch nối và đuôi file
  return name.replace(/[^a-zA-Z0-9.-]/g, "_").toLowerCase();
}

/**
 * Storage Service theo kiến trúc Adapter
 * Hỗ trợ Supabase Storage thật và Mock Adapter cho môi trường test / dev offline
 */
const storageService = {
  /**
   * Upload file lên Storage
   * @param {Object} params
   * @param {Buffer} params.buffer - Nội dung file dưới dạng Buffer
   * @param {string} params.originalName - Tên gốc của file
   * @param {string} params.mimeType - Kiểu MIME của file
   * @param {string} params.userId - ID người dùng sở hữu file
   * @returns {Promise<{ path: string, url: string }>}
   */
  async uploadFile({ buffer, originalName, mimeType = "application/pdf", userId = "anonymous" }) {
    const bucket = getBucketName();
    const cleanName = sanitizeFileName(originalName);
    const uniqueId = crypto.randomUUID();
    const filePath = `users/${userId}/${uniqueId}-${cleanName}`;

    const client = getSupabaseClient();
    const isTestMode = process.env.NODE_ENV === "test";

    // Nếu ở chế độ test hoặc chưa cấu hình Supabase -> fallback sang mock adapter
    if (isTestMode || !client) {
      const mockBaseUrl = process.env.SUPABASE_URL
        ? `${process.env.SUPABASE_URL}/storage/v1/object/public/${bucket}`
        : `https://mock-supabase.storage.local/${bucket}`;
      return {
        path: filePath,
        url: `${mockBaseUrl}/${filePath}`,
      };
    }

    // Upload lên Supabase Storage thật
    const { error } = await client.storage.from(bucket).upload(filePath, buffer, {
      contentType: mimeType,
      upsert: false,
    });

    if (error) {
      throw new Error(`Supabase Storage upload error: ${error.message}`);
    }

    const { data } = client.storage.from(bucket).getPublicUrl(filePath);
    return {
      path: filePath,
      url: data.publicUrl,
    };
  },

  /**
   * Xóa file khỏi Storage
   * @param {string} fileUrlOrPath - Đường dẫn tương đối hoặc public URL của file
   * @returns {Promise<boolean>}
   */
  async deleteFile(fileUrlOrPath) {
    if (!fileUrlOrPath) return false;

    const bucket = getBucketName();
    let filePath = fileUrlOrPath;

    // Nếu truyền vào là full URL, trích xuất relative path sau tên bucket
    if (fileUrlOrPath.includes(`/${bucket}/`)) {
      filePath = fileUrlOrPath.split(`/${bucket}/`)[1];
    }

    const client = getSupabaseClient();
    const isTestMode = process.env.NODE_ENV === "test";

    if (isTestMode || !client) {
      return true; // Mock delete thành công
    }

    const { error } = await client.storage.from(bucket).remove([filePath]);
    if (error) {
      console.warn(`Không thể xóa file ${filePath} trên Supabase Storage:`, error.message);
      return false;
    }

    return true;
  },
};

module.exports = storageService;
