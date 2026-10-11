import 'package:chat_ui_mobile/theme/app_theme.dart';
import 'package:chat_ui_mobile/theme/chat_colors.dart';
import 'package:chat_ui_mobile/ui/cards/card_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// NFR-02: tương phản >= 4,5:1 cho thẻ, trạng thái, ô nhập, nút gửi.
void main() {
  for (final b in Brightness.values) {
    testWidgets('thẻ/trạng thái/ô nhập đạt 4,5:1 (${b.name})', (t) async {
      late BuildContext ctx;
      await t.pumpWidget(MaterialApp(
        theme: b == Brightness.dark ? AppTheme.dark : AppTheme.light,
        home: Builder(builder: (c) {
          ctx = c;
          return const SizedBox();
        }),
      ));
      final c = ChatColors.of(ctx);
      final scheme = Theme.of(ctx).colorScheme;
      final pairs = <String, List<Color>>{};
      for (final mine in [true, false]) {
        final s = CardStyle.of(ctx, mine: mine);
        final k = mine ? 'đi' : 'đến';
        pairs['thẻ $k title/bg'] = [s.title, s.bg];
        pairs['thẻ $k sub/bg'] = [s.sub, s.bg];
        pairs['thẻ $k biểu tượng liên kết/bg'] = [
          Color.alphaBlend(s.title.withValues(alpha: 0.85), s.bg),
          s.bg
        ];
      }
      // ô vuông biểu tượng tệp: chữ trắng
      pairs['PDF'] = [Colors.white, const Color(0xFFB3261E)];
      pairs['XLS'] = [Colors.white, const Color(0xFF1E7B45)];
      // trạng thái: chữ/biểu tượng textSub trên nền thanh/bề mặt/bong bóng
      pairs['trạng thái/surface'] = [c.textSub, c.surface];
      pairs['trạng thái/bubbleIn'] = [c.textSub, c.bubbleIn];
      // ô nhập
      pairs['nhập text/fill'] = [c.text, c.surface];
      pairs['gợi ý/fill'] = [c.textSub, c.surface];
      // nút gửi (màu mặc định IconButton = onSurfaceVariant) trên thanh nhập
      pairs['nút gửi/appBar'] = [scheme.onSurfaceVariant, c.appBar];
      pairs.forEach((name, p) {
        expect(contrastRatio(p[0], p[1]), greaterThanOrEqualTo(4.5),
            reason: '$name (${b.name})');
      });
    });
  }
}
