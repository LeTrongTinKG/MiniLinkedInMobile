// Gom số liệu cảm xúc thành dạng {total, counts, top, myReaction} để trả cho app.
const reactionRepo = require("../../repositories/social/reaction.repository");

const TYPES = ["LIKE", "LOVE", "HAHA", "WOW", "SAD", "ANGRY"];

function buildSummary(countRows, myReaction) {
  const counts = {};
  TYPES.forEach((t) => (counts[t] = 0));
  countRows.forEach((r) => (counts[r.type] = r.count));

  const total = TYPES.reduce((sum, t) => sum + counts[t], 0);
  // "top" = tối đa 3 loại cảm xúc nhiều nhất (để app hiện icon)
  const top = TYPES.filter((t) => counts[t] > 0)
    .sort((a, b) => counts[b] - counts[a])
    .slice(0, 3);

  return { total, counts, top, myReaction: myReaction || null };
}

// Lấy tóm tắt cho nhiều bài/bình luận một lượt. Trả về Map: id -> danh sách dòng đếm
async function loadCountRows(kind, ids) {
  const rows = await reactionRepo.countByTargets(kind, ids);
  const byId = new Map();
  rows.forEach((r) => {
    if (!byId.has(r.targetId)) byId.set(r.targetId, []);
    byId.get(r.targetId).push(r);
  });
  return byId;
}

// Tóm tắt của đúng 1 đối tượng (dùng sau khi thả / bỏ cảm xúc)
async function loadOneSummary(kind, id, userId) {
  const byId = await loadCountRows(kind, [id]);
  const mine = await reactionRepo.findMyReactions(kind, [id], userId);
  return buildSummary(byId.get(id) || [], mine[0]?.type);
}

module.exports = { buildSummary, loadCountRows, loadOneSummary, TYPES };
