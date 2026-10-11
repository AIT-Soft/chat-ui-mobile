import 'package:flutter/foundation.dart';

/// Bộ 6 emoji reaction (đề xuất Q-05, REACT-01).
const List<String> reactionEmojis = ['👍', '❤️', '😂', '😮', '😢', '🙏'];

/// Mã người dùng hiện tại, khớp participants.me trong JSON 1.0.
const String reactionMeId = 'me';

/// Reaction hư cấu của người khác nằm ở lớp seed (AC-R7), không đổi chat-sample.json.
/// Dạng: id tin -> {mã người -> emoji}.
const Map<int, Map<String, String>> seedReactions = {
  // Tin 3 có 4 emoji khác nhau để kiểm chip xuống dòng ở chữ 200% (MT-R02).
  3: {'peer': '👍', 'peer1': '❤️', 'peer2': '😂', 'peer3': '😮'},
  6: {'peer': '❤️'},
  8: {'peer': '😂'},
};

/// Trạng thái reaction cục bộ trong RAM (AC-R6): không lưu máy, không mạng.
/// Mỗi người tối đa một reaction mỗi tin.
class ReactionStore extends ChangeNotifier {
  ReactionStore({Map<int, Map<String, String>> seed = seedReactions}) {
    seed.forEach((id, byUser) => _byMessage[id] = Map.of(byUser));
  }

  final Map<int, Map<String, String>> _byMessage = {};

  /// Reaction của [userId] trên tin [messageId]; null nếu chưa có.
  String? reactionOf(int messageId, String userId) =>
      _byMessage[messageId]?[userId];

  /// Gắn hoặc đổi reaction (thay reaction cũ nếu có).
  void set(int messageId, String userId, String emoji) {
    assert(reactionEmojis.contains(emoji));
    final m = _byMessage.putIfAbsent(messageId, () => {});
    if (m[userId] == emoji) return;
    m[userId] = emoji;
    notifyListeners();
  }

  /// Bỏ reaction của [userId]; không làm gì nếu chưa có.
  void remove(int messageId, String userId) {
    final m = _byMessage[messageId];
    if (m == null || m.remove(userId) == null) return;
    if (m.isEmpty) _byMessage.remove(messageId);
    notifyListeners();
  }

  /// Chạm chip/emoji: cùng emoji thì bỏ, khác thì đổi, chưa có thì thêm.
  void toggle(int messageId, String userId, String emoji) {
    if (reactionOf(messageId, userId) == emoji) {
      remove(messageId, userId);
    } else {
      set(messageId, userId, emoji);
    }
  }

  /// Đếm theo emoji (thứ tự theo [reactionEmojis]); chỉ gồm emoji có >= 1.
  Map<String, int> counts(int messageId) {
    final m = _byMessage[messageId];
    if (m == null) return const {};
    final out = <String, int>{};
    for (final e in reactionEmojis) {
      final n = m.values.where((v) => v == e).length;
      if (n > 0) out[e] = n;
    }
    return out;
  }
}
