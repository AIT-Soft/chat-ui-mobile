/// Người tham gia hội thoại (lược đồ 1.0, mục 7).
class Participant {
  const Participant({
    required this.id,
    required this.name,
    required this.initials,
    required this.avatarColor,
    this.status,
  });

  final String id;
  final String name;
  final String initials;

  /// Màu nền avatar dạng 0xFFRRGGBB.
  final int avatarColor;
  final String? status;
}
