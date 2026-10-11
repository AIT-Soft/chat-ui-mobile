import 'package:flutter/material.dart';

import '../logic/day_label.dart';
import '../logic/message_grouping.dart';
import '../models/chat_data.dart';
import '../models/message.dart';
import '../theme/chat_colors.dart';
import '../state/outbox.dart';
import '../state/reactions.dart';
import 'disclaimer_banner.dart';
import 'input_bar.dart';
import 'message_bubble.dart';

sealed class _Entry {}

class _DayEntry extends _Entry {
  _DayEntry(this.label);
  final String label;
}

class _MsgEntry extends _Entry {
  _MsgEntry(this.message, this.first, this.last);
  final Message message;
  final bool first;
  final bool last;
}

/// Màn hình chat: thanh tiêu đề, danh sách tin (FR-01, 02, 04, 05).
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.data, this.now, this.reactions});

  final ChatData data;

  /// Đồng hồ tiêm vào để tính nhãn ngày; mặc định giờ hiện tại.
  final DateTime? now;

  /// Kho reaction tiêm vào (test); mặc định tạo kho mới với seed.
  final ReactionStore? reactions;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _outbox = Outbox();
  late final ReactionStore _reactions = widget.reactions ?? ReactionStore();
  final _scroll = ScrollController();

  ChatData get data => widget.data;

  @override
  void dispose() {
    _outbox.dispose();
    if (widget.reactions == null) _reactions.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _onSend(String text) {
    setState(() => _outbox.send(text, widget.now ?? DateTime.now()));
    // reverse: vị trí 0 là cuối danh sách.
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  List<_Entry> _entries(DateTime clock) {
    final out = <_Entry>[];
    int? lastDay;
    for (final g in groupMessages([...data.messages, ..._outbox.sent])) {
      final day = g.first.dayOffset;
      if (day != lastDay) {
        out.add(_DayEntry(dayLabel(day, clock)));
        lastDay = day;
      }
      for (var i = 0; i < g.length; i++) {
        out.add(_MsgEntry(g[i], i == 0, i == g.length - 1));
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final c = ChatColors.of(context);
    final entries = _entries(widget.now ?? DateTime.now());
    final peer = data.peer;
    return Scaffold(
      backgroundColor: c.surface,
      appBar: AppBar(
        backgroundColor: c.appBar,
        foregroundColor: c.text,
        toolbarHeight: 56,
        title: Row(
          children: [
            ExcludeSemantics(
              child: Container(
                key: const Key('appbar-avatar'),
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Color(peer.avatarColor), shape: BoxShape.circle),
                child: Text(
                  peer.initials,
                  style: TextStyle(
                      color: contrastRatio(
                                  const Color(0xFFFFFFFF), Color(peer.avatarColor)) >=
                              4.5
                          ? const Color(0xFFFFFFFF)
                          : const Color(0xFF1B1F24),
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    peer.name,
                    style: TextStyle(
                        color: c.text, fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  if (peer.status != null)
                    Text(
                      peer.status!,
                      style: TextStyle(
                          color: c.textSub,
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            DisclaimerBanner(text: data.disclaimer),
            Expanded(
              child: ListView.builder(
                // reverse: mở ra là đã ở cuối danh sách (tin mới nhất).
                reverse: true,
                controller: _scroll,
                padding: const EdgeInsets.only(bottom: 12),
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final e = entries[entries.length - 1 - index];
                  return switch (e) {
                    _DayEntry() => _DayPill(label: e.label, colors: c),
                    _MsgEntry() => MessageBubble(
                        message: e.message,
                        sender:
                            e.message.from == Sender.me ? data.me : data.peer,
                        isFirstInGroup: e.first,
                        isLastInGroup: e.last,
                        reactions: _reactions,
                      ),
                  };
                },
              ),
            ),
            InputBar(onSend: _onSend),
          ],
        ),
      ),
    );
  }
}

class _DayPill extends StatelessWidget {
  const _DayPill({required this.label, required this.colors});
  final String label;
  final ChatColors colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Semantics(
        header: true,
        label: label,
        excludeSemantics: true,
        child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.dayPill,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(
              label,
              key: const Key('day-label'),
              style: TextStyle(
                  color: colors.dayPillText,
                  fontSize: 13,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
      ),
    );
  }
}
