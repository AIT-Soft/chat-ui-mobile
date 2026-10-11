import 'package:flutter/foundation.dart';

import '../models/message.dart';

/// Tin gửi cục bộ, chỉ giữ trong RAM (FR-08); khởi động lại là mất.
class Outbox extends ChangeNotifier {
  final List<Message> _sent = [];
  int _nextId = 1000;

  List<Message> get sent => List.unmodifiable(_sent);

  /// Văn bản hợp lệ để gửi: không rỗng sau khi cắt khoảng trắng.
  static bool canSend(String text) => text.trim().isNotEmpty;

  /// Thêm tin đi vào cuối; trả về false nếu văn bản rỗng/khoảng trắng.
  bool send(String text, DateTime clock) {
    if (!canSend(text)) return false;
    final hh = clock.hour.toString().padLeft(2, '0');
    final mm = clock.minute.toString().padLeft(2, '0');
    _sent.add(Message(
      id: _nextId++,
      from: Sender.me,
      dayOffset: 0,
      time: '$hh:$mm',
      type: MessageType.text,
      status: MessageStatus.sent,
      text: text.trim(),
    ));
    notifyListeners();
    return true;
  }
}
