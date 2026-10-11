import 'dart:io';

import 'package:chat_ui_mobile/data/chat_loader.dart';
import 'package:chat_ui_mobile/ui/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final _data = parseChatData(File('assets/chat-sample.json').readAsStringSync());
const _text = 'Bản thiết kế mẫu – nội dung hư cấu';

Future<void> _open(WidgetTester t, double scale) async {
  t.view.physicalSize = const Size(360, 640);
  t.view.devicePixelRatio = 1.0;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(
    builder: (c, child) => MediaQuery(
      data: MediaQuery.of(c).copyWith(textScaler: TextScaler.linear(scale)),
      child: child!,
    ),
    home: ChatScreen(data: _data, now: DateTime(2026, 10, 10)),
  ));
  await t.pump();
}

void main() {
  for (final scale in [1.0, 2.0]) {
    testWidgets('dòng chú thích hiện sau khi cuộn ở chữ ${scale * 100}%',
        (t) async {
      await _open(t, scale);
      final top = t.getTopLeft(find.byKey(const Key('disclaimer-banner')));
      expect(find.text(_text), findsOneWidget);
      await t.drag(find.byType(ListView), const Offset(0, 3000));
      await t.pump();
      expect(find.text(_text), findsOneWidget);
      expect(t.getTopLeft(find.byKey(const Key('disclaimer-banner'))), top);
      final r = t.getRect(find.byKey(const Key('disclaimer-banner')));
      expect(r.bottom <= 640, isTrue);
      expect(t.takeException(), isNull);
    });
  }

  testWidgets('dải nằm ngoài danh sách và có Semantics', (t) async {
    await _open(t, 1.0);
    expect(
        find.descendant(
            of: find.byType(ListView),
            matching: find.byKey(const Key('disclaimer-banner'))),
        findsNothing);
    expect(find.bySemanticsLabel(_text), findsOneWidget);
  });
}
