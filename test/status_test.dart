import 'dart:io';

import 'package:chat_ui_mobile/data/chat_loader.dart';
import 'package:chat_ui_mobile/models/message.dart';
import 'package:chat_ui_mobile/ui/chat_screen.dart';
import 'package:chat_ui_mobile/ui/status_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final _data = parseChatData(File('assets/chat-sample.json').readAsStringSync());

Future<void> _open(WidgetTester t) async {
  t.view.physicalSize = const Size(360, 640);
  t.view.devicePixelRatio = 1.0;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(
      home: ChatScreen(data: _data, now: DateTime(2026, 10, 10))));
  await t.pump();
}

Finder _in(int id, String text) => find.descendant(
    of: find.byKey(Key('status-$id')), matching: find.text(text));

void main() {
  testWidgets('FR-06: id 30 Đã nhận, id 32 Đã gửi, id 29/31 không có', (t) async {
    await _open(t);
    expect(_in(30, 'Đã nhận'), findsOneWidget);
    expect(_in(32, 'Đã gửi'), findsOneWidget);
    expect(find.byKey(const Key('status-29')), findsNothing);
    expect(find.byKey(const Key('status-31')), findsNothing);
  });

  testWidgets('FR-06: id 13 Đã xem (cuộn lên)', (t) async {
    await _open(t);
    await t.dragUntilVisible(find.byKey(const Key('status-13')),
        find.byType(ListView), const Offset(0, 300));
    expect(_in(13, 'Đã xem'), findsOneWidget);
  });

  test('3 trạng thái khác nhau cả biểu tượng lẫn nhãn', () {
    final icons = MessageStatus.values.map(statusIcon).toSet();
    final labels = MessageStatus.values.map(statusLabel).toSet();
    expect(icons.length, 3);
    expect(labels.length, 3);
  });
}
