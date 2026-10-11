import 'message.dart';
import 'participant.dart';

/// Toàn bộ dữ liệu mẫu đã nạp từ chat-sample.json.
class ChatData {
  const ChatData({
    required this.disclaimer,
    required this.me,
    required this.peer,
    required this.messages,
  });

  final String disclaimer;
  final Participant me;
  final Participant peer;
  final List<Message> messages;
}
