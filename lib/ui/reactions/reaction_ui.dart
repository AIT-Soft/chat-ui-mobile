import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../../state/reactions.dart';
import '../../theme/chat_colors.dart';

/// Tên tiếng Việt của từng emoji cho Semantics (design-reaction.md mục 7).
const Map<String, String> reactionNames = {
  '👍': 'thích',
  '❤️': 'yêu thích',
  '😂': 'cười',
  '😮': 'ngạc nhiên',
  '😢': 'buồn',
  '🙏': 'cảm ơn',
};

String reactionName(String emoji) => reactionNames[emoji] ?? 'cảm xúc';

/// Cỡ ô chạm tối thiểu (NFR-01).
const double reactionTarget = 48;

/// Mở thanh 6 emoji gần bong bóng [anchor] (toạ độ toàn cục) của tin [messageId].
Future<void> showReactionBar({
  required BuildContext context,
  required ReactionStore store,
  required int messageId,
  required Rect anchor,
  required bool mine,
}) {
  final noAnim = MediaQuery.disableAnimationsOf(context);
  HapticFeedback.selectionClick();
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Đóng thanh cảm xúc',
    barrierColor: const Color(0x66000000),
    transitionDuration: noAnim ? Duration.zero : const Duration(milliseconds: 120),
    transitionBuilder: (ctx, anim, _, child) =>
        noAnim ? child : FadeTransition(opacity: anim, child: child),
    pageBuilder: (ctx, _, _) {
      final mq = MediaQuery.of(ctx);
      return CustomSingleChildLayout(
        delegate: _BarLayout(
            anchor: anchor,
            mine: mine,
            safe: mq.padding,
            bottomInset: mq.viewInsets.bottom),
        child: MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.3,
          child: ReactionBar(
            selected: store.reactionOf(messageId, reactionMeId),
            onPick: (emoji) {
              final had = store.reactionOf(messageId, reactionMeId) == emoji;
              store.toggle(messageId, reactionMeId, emoji);
              Navigator.of(ctx).pop();
              _announce(ctx,
                  '${had ? 'Đã bỏ' : 'Đã thả'} cảm xúc ${reactionName(emoji)}');
            },
          ),
        ),
      );
    },
  );
}

void _announce(BuildContext context, String message) {
  // ignore: deprecated_member_use
  SemanticsService.announce(message, TextDirection.ltr);
}

class _BarLayout extends SingleChildLayoutDelegate {
  _BarLayout(
      {required this.anchor,
      required this.mine,
      required this.safe,
      required this.bottomInset});
  final Rect anchor;
  final bool mine;
  final EdgeInsets safe;
  final double bottomInset;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints c) =>
      BoxConstraints.loose(Size(math.max(0, c.maxWidth - 24), c.maxHeight));

  @override
  Offset getPositionForChild(Size size, Size child) {
    var x = mine ? anchor.right - child.width : anchor.left;
    x = x.clamp(12.0, math.max(12.0, size.width - 12 - child.width));
    final minY = safe.top + 56; // dưới thanh tiêu đề
    var y = anchor.top - 8 - child.height;
    if (y < minY) y = anchor.bottom + 8;
    final maxY = size.height - math.max(safe.bottom, bottomInset) - child.height;
    y = y.clamp(safe.top, math.max(safe.top, maxY));
    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_BarLayout old) =>
      old.anchor != anchor || old.mine != mine || old.safe != safe;
}

/// Thanh chọn 6 emoji; hẹp hoặc chữ lớn thì `Wrap` xuống nhiều hàng.
class ReactionBar extends StatelessWidget {
  const ReactionBar({super.key, required this.selected, required this.onPick});
  final String? selected;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    final c = ChatColors.of(context);
    final noAnim = MediaQuery.disableAnimationsOf(context);
    final bar = Semantics(
      container: true,
      liveRegion: true,
      label: 'Chọn cảm xúc',
      child: Material(
        key: const Key('reaction-bar'),
        color: c.reactionBarBg,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: c.reactionBarBorder),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              for (final e in reactionEmojis)
                _BarCell(
                    emoji: e, selected: e == selected, onTap: () => onPick(e)),
            ],
          ),
        ),
      ),
    );
    if (noAnim) return bar;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      builder: (_, t, child) => Opacity(
          opacity: t,
          child: Transform.scale(scale: 0.9 + 0.1 * t, child: child)),
      child: bar,
    );
  }
}

class _BarCell extends StatelessWidget {
  const _BarCell(
      {required this.emoji, required this.selected, required this.onTap});
  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = ChatColors.of(context);
    return Semantics(
      button: true,
      selected: selected,
      label: 'Thả cảm xúc ${reactionName(emoji)}${selected ? ', đã chọn' : ''}',
      onTap: onTap,
      excludeSemantics: true,
      child: InkWell(
        key: Key('react-opt-$emoji'),
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: reactionTarget,
          height: reactionTarget,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: selected ? c.reactionMineBg : null,
            border: selected
                ? Border.all(color: c.reactionMineBorder, width: 2)
                : null,
          ),
          child: Text(emoji, style: const TextStyle(fontSize: 28)),
        ),
      ),
    );
  }
}

/// Hàng chip dưới bong bóng; `Wrap` nên xuống dòng, không overflow.
class ReactionChips extends StatelessWidget {
  const ReactionChips({
    super.key,
    required this.messageId,
    required this.store,
    required this.mine,
    this.maxWidth = double.infinity,
    this.padding = EdgeInsets.zero,
  });
  final int messageId;
  final ReactionStore store;
  final bool mine;
  final double maxWidth;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final counts = store.counts(messageId);
    if (counts.isEmpty) return const SizedBox.shrink();
    final mineEmoji = store.reactionOf(messageId, reactionMeId);
    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value)); // sort ổn định: giữ thứ tự thanh
    return _ChipsHitArea(
      child: Padding(
        padding: padding,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Wrap(
      alignment: mine ? WrapAlignment.end : WrapAlignment.start,
      spacing: 4,
      runSpacing: 4,
      children: [
        for (final e in entries)
          _Chip(
            key: Key('chip-$messageId-${e.key}'),
            emoji: e.key,
            count: e.value,
            isMine: e.key == mineEmoji,
            onTap: () {
              final isMine = e.key == mineEmoji;
              if (isMine) {
                store.remove(messageId, reactionMeId);
              } else {
                store.set(messageId, reactionMeId, e.key);
              }
              _announce(
                  context,
                  '${isMine ? 'Đã bỏ' : 'Đã thả'} cảm xúc ${reactionName(e.key)}');
            },
          ),
      ],
    ))));
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    super.key,
    required this.emoji,
    required this.count,
    required this.isMine,
    required this.onTap,
  });
  final String emoji;
  final int count;
  final bool isMine;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = ChatColors.of(context);
    final bg = isMine ? c.reactionMineBg : c.reactionOtherBg;
    final fg = isMine ? c.reactionMineText : c.reactionOtherText;
    final border = isMine ? c.reactionMineBorder : c.reactionOtherBorder;
    final shown = count >= 100 ? '99+' : '$count';
    Widget visual = DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: isMine ? 2 : 1),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 28),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: Text.rich(
            TextSpan(children: [
              TextSpan(text: emoji, style: const TextStyle(fontSize: 16)),
              const TextSpan(text: ' '),
              TextSpan(
                text: shown,
                style: TextStyle(
                    fontSize: 14,
                    color: fg,
                    fontWeight: isMine ? FontWeight.w800 : FontWeight.w500),
              ),
            ]),
          ),
        ),
      ),
    );
    if (!MediaQuery.disableAnimationsOf(context)) {
      // Nảy ngắn khi số đổi (key theo số lượng).
      visual = TweenAnimationBuilder<double>(
        key: ValueKey(count),
        tween: Tween(begin: 1.15, end: 1),
        duration: const Duration(milliseconds: 180),
        builder: (_, s, child) => Transform.scale(scale: s, child: child),
        child: visual,
      );
    }
    final who = count == 1 ? '1 người' : '$count người';
    return Semantics(
      button: true,
      label:
          '${reactionName(emoji)}, $who, ${isMine ? 'bạn đã chọn' : 'bạn chưa chọn'}',
      hint: isMine ? 'Chạm đúp để bỏ cảm xúc' : 'Chạm đúp để thả cảm xúc này',
      onTap: onTap,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: visual,
      ),
    );
  }
}

/// Phần vùng chạm mở rộng ra ngoài khung chip 28 dp (mỗi phía theo chiều dọc).
const double reactionHitSlackY = (reactionTarget - 28) / 2;

/// Bọc `Wrap` chip: layout chỉ tính chip 28 dp (khoảng 4 dp), còn vùng chạm
/// mỗi chip mở rộng tới 48x48 dp ngoài layout. Phần chồng nhau thuộc chip có
/// mép gần nhất; cách đều thì chip đứng trước (hàng trên/bên trái). Xem
/// design-reaction.md mục 2.4.
class _ChipsHitArea extends SingleChildRenderObjectWidget {
  const _ChipsHitArea({required Widget child}) : super(child: child);

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderChipsHitArea();
}

class _RenderChipsHitArea extends RenderProxyBox {
  Rect _expanded(Rect r) => r.inflate(0).expandToInclude(Rect.fromLTRB(
        r.center.dx - (r.width < reactionTarget ? reactionTarget / 2 : r.width / 2),
        r.top - reactionHitSlackY,
        r.center.dx + (r.width < reactionTarget ? reactionTarget / 2 : r.width / 2),
        r.bottom + reactionHitSlackY,
      ));

  double _dist(Rect r, Offset p) {
    final dx = p.dx < r.left ? r.left - p.dx : (p.dx > r.right ? p.dx - r.right : 0.0);
    final dy = p.dy < r.top ? r.top - p.dy : (p.dy > r.bottom ? p.dy - r.bottom : 0.0);
    return dx > dy ? dx : dy;
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    RenderBox? best;
    Rect? bestRect;
    var bestDist = double.infinity;
    RenderWrap? wrap;
    void find(RenderObject o) {
      if (o is RenderWrap) {
        wrap = o;
        return;
      }
      o.visitChildren(find);
    }

    visitChildren(find);
    final w = wrap;
    if (w == null) return false;
    // Toạ độ chip trong hệ của đối tượng này.
    final wrapOff = w.localToGlobal(Offset.zero, ancestor: this);
    w.visitChildren((c) {
      final chip = c as RenderBox;
      final rect = ((chip.parentData! as WrapParentData).offset + wrapOff) & chip.size;
      if (!_expanded(rect).contains(position)) return;
      final d = _dist(rect, position);
      if (d < bestDist) {
        bestDist = d;
        best = chip;
        bestRect = rect;
      }
    });
    final chip = best;
    final rect = bestRect;
    if (chip == null || rect == null) return false;
    final inside = Offset(
      position.dx.clamp(rect.left, rect.right - 0.01),
      position.dy.clamp(rect.top, rect.bottom - 0.01),
    );
    return result.addWithPaintOffset(
      offset: rect.topLeft,
      position: inside,
      hitTest: (r, p) => chip.hitTest(r, position: p),
    );
  }
}
