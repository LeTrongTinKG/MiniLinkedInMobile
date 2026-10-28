// Độ giống giữa 2 tập từ: số từ chung / tổng số từ khác nhau (0 đến 1)
function jaccard(setA, setB) {
  if (setA.size === 0 && setB.size === 0) return 0;
  let common = 0;
  for (const word of setA) {
    if (setB.has(word)) common++;
  }
  const union = setA.size + setB.size - common;
  return common / union;
}

module.exports = { jaccard };
