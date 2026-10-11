import 'dart:io';

import 'package:chat_ui_mobile/data/chat_loader.dart';
import 'package:chat_ui_mobile/theme/app_theme.dart';
import 'package:chat_ui_mobile/ui/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final _data = parseChatData(File('assets/chat-sample.json').readAsStringSync());

Future<void> _open(WidgetTester t, Size size,
    {double keyboard = 0, double scale = 1.0, ThemeMode mode = ThemeMode.light}) async {
  t.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
  t.view.physicalSize = size;
  t.view.devicePixelRatio = 1.0;
  t.view.viewInsets = FakeViewPadding(bottom: keyboard);
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: mode,
      home: ChatScreen(data: _data, now: DateTime(2026, 10, 10, 14, 30))));
  await t.pump();
}

void main() {
  for (final size in const [Size(360, 640), Size(412, 915)]) {
    for (final scale in const [1.0, 2.0]) {
      for (final mode in const [ThemeMode.light, ThemeMode.dark]) {
        testWidgets(
            'AC-10.1: ${size.width.toInt()}x${size.height.toInt()} chữ ${(scale * 100).toInt()}% ${mode.name} không overflow',
            (t) async {
          await _open(t, size, scale: scale, mode: mode);
          expect(t.takeException(), isNull);
          expect(find.byKey(const Key('input-field')), findsOneWidget);
          // Cuộn qua toàn bộ danh sách để dựng mọi bong bóng/thẻ.
          for (var i = 0; i < 40; i++) {
            await t.drag(find.byType(ListView).first, const Offset(0, 400));
            await t.pump();
          }
          expect(t.takeException(), isNull);
        });
      }
    }
  }

  testWidgets('AC-10.1: 412x915 dựng được, tin 32 trong tầm nhìn', (t) async {
    await _open(t, const Size(412, 915));
    expect(t.takeException(), isNull);
    final r = t.getRect(find.byKey(const Key('bubble-32')));
    expect(r.top >= 0 && r.bottom <= 915, isTrue);
    expect(find.byKey(const Key('input-field')), findsOneWidget);
  });

  testWidgets('AC-10.3: xoay ngang 640x360 giữ bố cục', (t) async {
    await _open(t, const Size(360, 640));
    t.view.physicalSize = const Size(640, 360);
    await t.pump();
    expect(t.takeException(), isNull);
    final input = t.getRect(find.byKey(const Key('input-field')));
    expect(input.top >= 0 && input.bottom <= 360, isTrue);
    final last = t.getRect(find.byKey(const Key('bubble-32')));
    expect(last.top >= 0, isTrue);
    expect(last.bottom <= input.top + 1, isTrue);
    // Tin 30 là thẻ tệp (card-30), 31 và 32 là bong bóng văn bản.
    for (final k in ['card-30', 'bubble-31', 'bubble-32']) {
      final f = find.byKey(Key(k));
      expect(f, findsOneWidget);
      expect(t.getRect(f).width <= 640 * 0.75 + 0.5, isTrue);
    }
    await t.drag(find.byType(ListView).first, const Offset(0, 300));
    await t.pump();
    expect(t.takeException(), isNull);
    expect(find.byKey(const Key('input-field')), findsOneWidget);
  });

  testWidgets('AC-08.4: bàn phím mở, tin cuối còn trong tầm nhìn', (t) async {
    await _open(t, const Size(360, 640), keyboard: 300);
    await t.pump();
    expect(t.takeException(), isNull);
    final r = t.getRect(find.byKey(const Key('bubble-32')));
    final input = t.getRect(find.byKey(const Key('input-field')));
    expect(r.top >= 0, isTrue);
    expect(r.bottom <= input.top + 1, isTrue);
    expect(input.bottom <= 640 - 300, isTrue);
  });
}
