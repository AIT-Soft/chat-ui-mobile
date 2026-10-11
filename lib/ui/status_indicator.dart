import 'package:flutter/material.dart';

import '../models/message.dart';
import '../theme/chat_colors.dart';

/// Nhãn tiếng Việt của trạng thái tin đi (FR-06).
String statusLabel(MessageStatus s) {
  switch (s) {
    case MessageStatus.sent:
      return 'Đã gửi';
    case MessageStatus.delivered:
      return 'Đã nhận';
    case MessageStatus.seen:
      return 'Đã xem';
  }
}

/// Biểu tượng khác nhau cho từng trạng thái.
IconData statusIcon(MessageStatus s) {
  switch (s) {
    case MessageStatus.sent:
      return Icons.check;
    case MessageStatus.delivered:
      return Icons.done_all;
    case MessageStatus.seen:
      return Icons.visibility_outlined;
  }
}

/// Biểu tượng + nhãn trạng thái, đặt cạnh giờ ở tin đi cuối nhóm.
class StatusIndicator extends StatelessWidget {
  const StatusIndicator({super.key, required this.status});

  final MessageStatus status;

  @override
  Widget build(BuildContext context) {
    final c = ChatColors.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(
          child: Icon(statusIcon(status), size: 14, color: c.textSub),
        ),
        const SizedBox(width: 2),
        Text(
          statusLabel(status),
          style: TextStyle(color: c.textSub, fontSize: 12),
        ),
      ],
    );
  }
}
