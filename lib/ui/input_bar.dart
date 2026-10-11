import 'package:flutter/material.dart';

import '../state/outbox.dart';
import '../theme/chat_colors.dart';

/// Thanh nhập nhiều dòng (tối đa 5) và nút gửi (FR-08).
class InputBar extends StatefulWidget {
  const InputBar({super.key, required this.onSend});

  /// Gọi với văn bản đã nhập; thanh tự xóa ô sau khi gọi.
  final void Function(String text) onSend;

  @override
  State<InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<InputBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text;
    if (!Outbox.canSend(text)) return;
    widget.onSend(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final c = ChatColors.of(context);
    return Container(
      color: c.appBar,
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: TextField(
                key: const Key('input-field'),
                controller: _controller,
                minLines: 1,
                maxLines: 5,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                style: TextStyle(color: c.text, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Nhập tin nhắn',
                  hintStyle: TextStyle(color: c.textSub),
                  filled: true,
                  fillColor: c.surface,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, value, _) {
              final enabled = Outbox.canSend(value.text);
              return IconButton(
                key: const Key('send-button'),
                tooltip: 'Gửi',
                constraints:
                    const BoxConstraints(minWidth: 48, minHeight: 48),
                onPressed: enabled ? _send : null,
                icon: const Icon(Icons.send),
              );
            },
          ),
        ],
      ),
    );
  }
}
