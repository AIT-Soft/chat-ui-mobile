import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../models/message.dart';
import '../models/participant.dart';
import '../state/reactions.dart';
import '../theme/chat_colors.dart';
import 'cards/message_card.dart';
import 'reactions/reaction_ui.dart';
import 'status_indicator.dart';

/// Nội dung đọc của tin (thẻ mô tả theo loại).
String messageContentLabel(Message m) {
  switch (m.type) {
    case MessageType.text:
      return m.text ?? '';
    case MessageType.file:
      final f = m.file;
      return f == null ? '' : 'Tệp ${f.name}, ${f.typeLabel}, ${f.sizeLabel}';
    case MessageType.image:
      final i = m.image;
      if (i == null) return '';
      return 'Ảnh ${i.name}, ${i.caption ?? i.typeLabel}, ${i.sizeLabel}';
    case MessageType.link:
      final l = m.link;
      return l == null ? '' : 'Liên kết ${l.title}, ${l.domain}';
  }
}

/// Nhãn đọc: `Người gửi, nội dung, giờ, trạng thái` (NFR-03).
String messageSemanticsLabel(Message m, Participant sender) {
  final parts = <String>[
    sender.name,
    messageContentLabel(m),
    m.time,
    if (m.from == Sender.me && m.status != null) statusLabel(m.status!),
  ];
  return parts.join(', ');
}

/// Tỉ lệ chiều rộng tối đa của bong bóng (FR-02).
const double bubbleMaxWidthFactor = 0.75;
const double avatarSize = 32;

String _plainText(Message m) {
  switch (m.type) {
    case MessageType.text:
      return m.text ?? '';
    case MessageType.file:
      return m.file?.name ?? '';
    case MessageType.image:
      return m.image?.caption ?? m.image?.name ?? '';
    case MessageType.link:
      return m.link?.title ?? '';
  }
}

/// Một tin: bong bóng căn trái/phải, avatar + giờ ở tin cuối nhóm.
/// Thẻ đính kèm sẽ thay phần nội dung ở S2 (hiện hiện chữ tối thiểu).
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.sender,
    required this.isFirstInGroup,
    required this.isLastInGroup,
    this.reactions,
  });

  final Message message;
  final Participant sender;
  final bool isFirstInGroup;
  final bool isLastInGroup;

  /// Null thì tắt reaction (giữ hành vi cũ).
  final ReactionStore? reactions;

  void _openBar(BuildContext? ctx, ReactionStore store) {
    if (ctx == null || !ctx.mounted) return;
    final box = ctx.findRenderObject();
    if (box is! RenderBox || !box.attached) return;
    final anchor = box.localToGlobal(Offset.zero) & box.size;
    showReactionBar(
      context: ctx,
      store: store,
      messageId: message.id,
      anchor: anchor,
      mine: message.from == Sender.me,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = ChatColors.of(context);
    final mine = message.from == Sender.me;
    final maxW = MediaQuery.sizeOf(context).width * bubbleMaxWidthFactor;
    final bg = mine ? c.bubbleOut : c.bubbleIn;
    final fg = mine ? c.bubbleOutText : c.bubbleInText;
    const r = Radius.circular(16);
    const tail = Radius.circular(4);
    final radius = BorderRadius.only(
      topLeft: r,
      topRight: r,
      bottomLeft: (!mine && isLastInGroup) ? tail : r,
      bottomRight: (mine && isLastInGroup) ? tail : r,
    );

    final card = buildMessageCard(message);
    final bubbleBox = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxW),
      child: card != null
          ? KeyedSubtree(key: Key('card-${message.id}'), child: card)
          : DecoratedBox(
              key: Key('bubble-${message.id}'),
              decoration: BoxDecoration(color: bg, borderRadius: radius),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Text(
                  _plainText(message),
                  key: Key('bubble-text-${message.id}'),
                  style: TextStyle(color: fg, fontSize: 16),
                ),
              ),
            ),
    );

    final store = reactions;
    // Context của box bong bóng: long-press và action TalkBack dùng chung anchor.
    BuildContext? bubbleCtx;
    final bubble = store == null
        ? bubbleBox
        : Builder(
            builder: (ctx) {
              bubbleCtx = ctx;
              return GestureDetector(
                onLongPress: () => _openBar(ctx, store),
                child: bubbleBox,
              );
            },
          );

    final column = Column(
      crossAxisAlignment: mine
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(child: bubble),
        if (store != null)
          ListenableBuilder(
            listenable: store,
            builder: (context, _) {
              if (store.counts(message.id).isEmpty) {
                return const SizedBox.shrink();
              }
              return ReactionChips(
                messageId: message.id,
                store: store,
                mine: mine,
                maxWidth: maxW,
                // Chừa chỗ cho vùng chạm chip mở rộng ra ngoài layout (F2).
                padding: const EdgeInsets.only(bottom: reactionHitSlackY),
              );
            },
          ),
        if (isLastInGroup)
          ExcludeSemantics(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                children: [
                  Text(
                    message.time,
                    key: Key('time-${message.id}'),
                    style: TextStyle(color: c.textSub, fontSize: 12),
                  ),
                  if (mine && message.status != null)
                    KeyedSubtree(
                      key: Key('status-${message.id}'),
                      child: StatusIndicator(status: message.status!),
                    ),
                ],
              ),
            ),
          ),
      ],
    );

    final main = Semantics(
      label: messageSemanticsLabel(message, sender),
      customSemanticsActions: store == null
          ? null
          : {
              const CustomSemanticsAction(label: 'Thả cảm xúc'): () =>
                  _openBar(bubbleCtx, store),
            },
      child: Padding(
        padding: EdgeInsets.fromLTRB(12, isFirstInGroup ? 12 : 4, 12, 0),
        child: Row(
          mainAxisAlignment: mine
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!mine) ...[
              if (isLastInGroup)
                ExcludeSemantics(child: _Avatar(participant: sender))
              else
                const SizedBox(width: avatarSize),
              const SizedBox(width: 8),
            ],
            Flexible(child: column),
          ],
        ),
      ),
    );
    return main;
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.participant});
  final Participant participant;

  @override
  Widget build(BuildContext context) {
    final bg = Color(participant.avatarColor);
    const white = Color(0xFFFFFFFF);
    const dark = Color(0xFF1B1F24);
    final fg = contrastRatio(white, bg) >= 4.5 ? white : dark;
    return ExcludeSemantics(
      child: Container(
        width: avatarSize,
        height: avatarSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Text(
          participant.initials,
          style: TextStyle(
            color: fg,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
