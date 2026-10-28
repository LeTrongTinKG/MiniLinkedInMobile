// Các hàm nhỏ biến dữ liệu job thành chữ hiển thị (thuần Dart, dễ test).

/// Nguồn job -> tên hiển thị. Ưu tiên đoán theo host của link, không đoán được thì theo source.
String sourceLabel(String source, String? applyUrl) {
  if (source == 'internal') return 'MiniLinkedIn';
  const hosts = {
    'linkedin.com': 'LinkedIn',
    'topcv.vn': 'TopCV',
    'itviec.com': 'ITviec',
    'vietnamworks.com': 'VietnamWorks',
    'indeed.com': 'Indeed',
    'glassdoor.com': 'Glassdoor',
    'remotive.com': 'Remotive',
  };
  final host = Uri.tryParse(applyUrl ?? '')?.host.toLowerCase() ?? '';
  for (final entry in hosts.entries) {
    if (host == entry.key || host.endsWith('.${entry.key}')) return entry.value;
  }
  switch (source) {
    case 'jsearch':
    case 'serpapi':
      return 'Google Jobs';
    case 'remotive':
      return 'Remotive';
    default:
      return 'Nguồn ngoài';
  }
}

/// Số có dấu phẩy ngăn nghìn: 3000 -> 3,000
String _withCommas(int n) => n
    .toString()
    .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');

/// VND tính theo triệu: 15000000 -> "15", 12500000 -> "12.5"
String _million(int n) {
  final m = n / 1000000;
  return m == m.roundToDouble() ? m.round().toString() : m.toStringAsFixed(1);
}

/// Nhãn lương. VND: "15–25 triệu", USD: "$2,000–3,000". Không có lương: "Thỏa thuận".
/// currency null (job cũ) coi như USD.
String salaryLabel(int? min, int? max, String? currency) {
  if (min == null && max == null) return 'Thỏa thuận';
  final isVnd = currency == 'VND';
  String fmt(int n) => isVnd ? _million(n) : _withCommas(n);
  String wrap(String text) => isVnd ? '$text triệu' : '\$$text';
  if (min != null && max != null) {
    return isVnd ? '${fmt(min)}–${fmt(max)} triệu' : '\$${fmt(min)}–${fmt(max)}';
  }
  if (min != null) return 'Từ ${wrap(fmt(min))}';
  return 'Lên tới ${wrap(fmt(max!))}';
}
