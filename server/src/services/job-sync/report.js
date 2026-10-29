// Xếp lại từ khóa theo hiệu suất lượt trước (mục 3.4) và dựng/in báo cáo lượt chạy.

const LOW_RATE = 0.1; // tỉ lệ giữ lại dưới mức này (khi đã kéo >= 5 job) coi là ra rác
const MIN_SAMPLE = 5;

// Tỉ lệ giữ lại của từ khóa = job sạch / job kéo về
function keepRate(stat) {
  return stat && stat.fetched > 0 ? stat.kept / stat.fetched : null;
}

function isLowQuality(stat) {
  const rate = keepRate(stat);
  return rate !== null && stat.fetched >= MIN_SAMPLE && rate < LOW_RATE;
}

// Từ khóa ra rác ở lượt trước bị đẩy xuống cuối hàng, còn lại giữ nguyên thứ tự
function orderKeywords(keywords, lastStats = {}) {
  const good = keywords.filter((k) => !isLowQuality(lastStats[k]));
  const bad = keywords.filter((k) => isLowQuality(lastStats[k]));
  return [...good, ...bad];
}

function buildReport({ startedAt, finishedAt, dryRun, collected, dedupe, saved, closed, flaggedKeywords }) {
  const keywords = {};
  for (const [name, stat] of Object.entries(collected.keywordStats)) {
    keywords[name] = { ...stat, keepRate: keepRate(stat) };
  }
  return {
    startedAt: startedAt.toISOString(),
    finishedAt: finishedAt.toISOString(),
    dryRun,
    sources: collected.sources,
    rejected: { ...collected.rejected, duplicate: collected.rejected.duplicate + dedupe.duplicates, remotiveOverCap: dedupe.remotiveOverCap },
    kept: dedupe.finalCount,
    inserted: saved.inserted,
    updated: saved.updated,
    closedStale: closed,
    keywords,
    flaggedKeywords,
  };
}

// In báo cáo gọn ra màn hình (không có secret)
function formatReport(report) {
  const lines = [`=== Báo cáo Job Sync (${report.dryRun ? "CHẠY THỬ - không ghi DB" : "CHẠY THẬT"}) ===`];
  for (const [name, s] of Object.entries(report.sources)) {
    const err = s.error ? ` | LỖI: ${s.error}` : "";
    lines.push(`- ${name}: request ${s.requests} (từ cache ${s.fromCache}), kéo về ${s.fetched}, giữ ${s.kept}${err}`);
  }
  lines.push(`Job bị loại theo lý do: ${JSON.stringify(report.rejected)}`);
  lines.push(`Job giữ lại: ${report.kept} | thêm mới: ${report.inserted} | cập nhật: ${report.updated} | đóng do hết hạn: ${report.closedStale}`);
  lines.push("Tỉ lệ giữ lại theo từ khóa:");
  for (const [name, k] of Object.entries(report.keywords)) {
    lines.push(`  "${name}": ${k.kept}/${k.fetched}`);
  }
  if (report.flaggedKeywords.length > 0) lines.push(`Từ khóa nên xem lại: ${report.flaggedKeywords.join(", ")}`);
  return lines.join("\n");
}

module.exports = { orderKeywords, isLowQuality, buildReport, formatReport, keepRate };
