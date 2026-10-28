// Bước 5: xóa HTML khỏi mô tả (không cần thư viện ngoài)
// Chạy từ trên xuống: bỏ script/style -> đổi thẻ xuống dòng thành "\n" -> bỏ thẻ -> giải mã ký tự -> gộp khoảng trắng.

// Bảng ký tự đặc biệt hay gặp, ví dụ &amp; -> &
const NAMED_ENTITIES = {
  amp: "&", lt: "<", gt: ">", quot: '"', apos: "'", nbsp: " ",
  ndash: "-", mdash: "-", bull: "-", hellip: "...", middot: "-",
  rsquo: "'", lsquo: "'", ldquo: '"', rdquo: '"', copy: "(c)", reg: "(r)",
};

// Giải mã &amp; &#39; &#x27; ... Không biết thì giữ nguyên.
function decodeEntities(text) {
  return text.replace(/&(#x[0-9a-f]+|#\d+|[a-z]+);/gi, (match, name) => {
    if (name[0] === "#") {
      const isHex = name[1] === "x" || name[1] === "X";
      const code = parseInt(name.slice(isHex ? 2 : 1), isHex ? 16 : 10);
      return code > 0 && code < 0x110000 ? String.fromCodePoint(code) : match;
    }
    const value = NAMED_ENTITIES[name.toLowerCase()];
    return value === undefined ? match : value;
  });
}

function stripHtml(input) {
  if (typeof input !== "string") return "";
  let text = input.replace(/\r\n?/g, "\n");

  // Bỏ hẳn nội dung script/style/comment
  text = text.replace(/<(script|style)[^>]*>[\s\S]*?<\/\1>/gi, " ");
  text = text.replace(/<!--[\s\S]*?-->/g, " ");

  // Thẻ kết thúc đoạn -> xuống dòng; <li> -> gạch đầu dòng
  text = text.replace(/<br\s*\/?>/gi, "\n");
  text = text.replace(/<\/(p|div|li|ul|ol|h[1-6]|tr|table|section)>/gi, "\n");
  text = text.replace(/<li[^>]*>/gi, "- ");

  // Bỏ các thẻ còn lại (chỉ thẻ thật: bắt đầu bằng chữ cái hoặc /)
  text = text.replace(/<\/?[a-z][^>]*>/gi, "");

  text = decodeEntities(text);

  // Gộp khoảng trắng, giữ xuống dòng giữa các đoạn
  text = text
    .split("\n")
    .map((line) => line.replace(/[ \t ]+/g, " ").trim())
    .join("\n");
  return text.replace(/\n{3,}/g, "\n\n").trim();
}

module.exports = { stripHtml, decodeEntities };
