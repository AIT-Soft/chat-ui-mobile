import 'dart:io';

import 'package:chat_ui_mobile/data/chat_loader.dart';
import 'package:chat_ui_mobile/ui/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final _data = parseChatData(File('assets/chat-sample.json').readAsStringSync());

Future<void> _open(WidgetTester t) async {
  t.view.physicalSize = const Size(360, 640);
  t.view.devicePixelRatio = 1.0;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(
      home: ChatScreen(data: _data, now: DateTime(2026, 10, 10, 14, 30))));
  await t.pump();
}

final _field = find.byKey(const Key('input-field'));
final _btn = find.byKey(const Key('send-button'));

bool _enabled(WidgetTester t) => t.widget<IconButton>(_btn).onPressed != null;

Future<void> _send(WidgetTester t, String s) async {
  await t.enterText(_field, s);
  await t.pump();
  await t.tap(_btn);
  await t.pump();
}

void main() {
  testWidgets('gửi "xin chào": 1 bong bóng phải, ô rỗng, nút vô hiệu', (t) async {
    await _open(t);
    expect(_enabled(t), isFalse);
    await t.enterText(_field, 'xin chào');
    await t.pump();
    expect(_enabled(t), isTrue);
    await t.tap(_btn);
    await t.pump();
    final bubble = find.text('xin chào');
    expect(bubble, findsOneWidget);
    expect(t.getTopRight(bubble).dx, greaterThan(180)); // bên phải
    expect(t.widget<TextField>(_field).controller!.text, isEmpty);
    expect(_enabled(t), isFalse);
  });

  testWidgets('chỉ khoảng trắng thì nút gửi vô hiệu', (t) async {
    await _open(t);
    await t.enterText(_field, '   \n ');
    await t.pump();
    expect(_enabled(t), isFalse);
  });

  testWidgets('hai tin cách < 5 phút gom nhóm, trạng thái chỉ ở tin cuối', (t) async {
    await _open(t);
    await _send(t, 'một');
    await _send(t, 'hai');
    expect(find.text('một'), findsOneWidget);
    expect(find.text('hai'), findsOneWidget);
    expect(find.byKey(const Key('status-1000')), findsNothing);
    expect(find.byKey(const Key('status-1001')), findsOneWidget);
    expect(
        find.descendant(
            of: find.byKey(const Key('status-1001')),
            matching: find.text('Đã gửi')),
        findsOneWidget);
  });

  testWidgets('nút gửi và ô nhập >= 48 dp, tối đa 5 dòng', (t) async {
    await _open(t);
    expect(t.getSize(_btn).width, greaterThanOrEqualTo(48));
    expect(t.getSize(_btn).height, greaterThanOrEqualTo(48));
    expect(t.getSize(_field).height, greaterThanOrEqualTo(48));
    await t.enterText(_field, List.filled(12, 'a').join('\n'));
    await t.pump();
    expect(t.widget<TextField>(_field).maxLines, 5);
    expect(t.getSize(_field).height, lessThan(5 * 24 + 40));
  });

  testWidgets('tin gửi không lưu: dựng lại màn hình thì mất', (t) async {
    await _open(t);
    await _send(t, 'xin chào');
    await t.pumpWidget(const SizedBox());
    await _open(t);
    expect(find.text('xin chào'), findsNothing);
  });
}
