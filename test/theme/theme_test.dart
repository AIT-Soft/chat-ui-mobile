import 'dart:io';

import 'package:chat_ui_mobile/data/chat_loader.dart';
import 'package:chat_ui_mobile/theme/app_theme.dart';
import 'package:chat_ui_mobile/theme/chat_colors.dart';
import 'package:chat_ui_mobile/ui/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final _data = parseChatData(File('assets/chat-sample.json').readAsStringSync());

Future<void> _pump(WidgetTester t, double w, Brightness b, double scale) async {
  t.view.physicalSize = Size(w, 640);
  t.view.devicePixelRatio = 1.0;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: b == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
      child: child!,
    ),
    home: ChatScreen(data: _data, now: DateTime(2026, 10, 10, 14, 30)),
  ));
  await t.pump();
}

void main() {
  for (final b in Brightness.values) {
    testWidgets('dựng ${b.name} không ngoại lệ, dùng token', (t) async {
      await _pump(t, 360, b, 1.0);
      expect(t.takeException(), isNull);
      final c = b == Brightness.dark ? ChatColors.dark : ChatColors.light;
      expect(Theme.of(t.element(find.byType(ChatScreen))).scaffoldBackgroundColor,
          c.surface);
    });
    for (final w in [360.0, 412.0]) {
      testWidgets('chữ 200% ở ${w.toInt()} dp (${b.name}) không overflow', (t) async {
        await _pump(t, w, b, 2.0);
        expect(t.takeException(), isNull);
        // cuộn qua danh sách để dựng các tin khác
        for (var i = 0; i < 6; i++) {
          await t.drag(find.byType(ListView).first, const Offset(0, 400));
          await t.pump();
          expect(t.takeException(), isNull);
        }
      });
    }
  }

  test('avatar người peer: chữ trắng/nền >= 4,5:1 (NFR-02)', () {
    final bg = Color(_data.peer.avatarColor);
    expect(contrastRatio(const Color(0xFFFFFFFF), bg), greaterThanOrEqualTo(4.5));
  });

  test('tương phản chữ/nền >= 4,5:1 (sáng và tối)', () {
    for (final c in [ChatColors.light, ChatColors.dark]) {
      final pairs = {
        'text/surface': [c.text, c.surface],
        'textSub/surface': [c.textSub, c.surface],
        'bubbleInText/bubbleIn': [c.bubbleInText, c.bubbleIn],
        'bubbleOutText/bubbleOut': [c.bubbleOutText, c.bubbleOut],
        'dayPillText/dayPill': [c.dayPillText, c.dayPill],
        'text/appBar': [c.text, c.appBar],
        'textSub/appBar': [c.textSub, c.appBar],
        'textSub/bubbleIn': [c.textSub, c.bubbleIn],
      };
      pairs.forEach((name, p) {
        expect(contrastRatio(p[0], p[1]), greaterThanOrEqualTo(4.5), reason: name);
      });
    }
  });
}
