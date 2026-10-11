const _weekdays = [
  'Thứ Hai',
  'Thứ Ba',
  'Thứ Tư',
  'Thứ Năm',
  'Thứ Sáu',
  'Thứ Bảy',
  'Chủ nhật',
];

String _two(int n) => n.toString().padLeft(2, '0');

/// Nhãn ngày (FR-04). [now] là đồng hồ tiêm vào; dayOffset <= 0.
String dayLabel(int dayOffset, DateTime now) {
  if (dayOffset == 0) return 'Hôm nay';
  if (dayOffset == -1) return 'Hôm qua';
  // Dựng theo ngày dương lịch (UTC) để không lệch do giờ mùa hè.
  final d = DateTime.utc(now.year, now.month, now.day - dayOffset.abs());
  final base = '${_weekdays[d.weekday - 1]}, ${_two(d.day)}/${_two(d.month)}';
  return d.year == now.year ? base : '$base/${d.year}';
}
