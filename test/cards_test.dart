import 'dart:io';

import 'package:chat_ui_mobile/data/chat_loader.dart';
import 'package:chat_ui_mobile/ui/cards/file_card.dart';
import 'package:chat_ui_mobile/ui/cards/image_card.dart';
import 'package:chat_ui_mobile/ui/cards/link_card.dart';
import 'package:chat_ui_mobile/ui/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final _data = parseChatData(File('assets/chat-sample.json').readAsStringSync());
final _now = DateTime(2026, 5, 20, 12);

Future<void> _pump(WidgetTester t) async {
  t.view.physicalSize = const Size(360, 8000);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(home: ChatScreen(data: _data, now: _now)));
}

void main() {
  testWidgets('đúng 5 thẻ: id 5, 10, 16, 22, 30', (t) async {
    await _pump(t);
    final ids = [
      for (final id in List.generate(32, (i) => i + 1))
        if (find.byKey(Key('card-$id')).evaluate().isNotEmpty) id
    ];
    expect(ids, [5, 10, 16, 22, 30]);
    expect(find.byType(FileCard), findsNWidgets(3));
    expect(find.byType(ImageCard), findsOneWidget);
    expect(find.byType(LinkCard), findsOneWidget);
  });

  testWidgets('thẻ ảnh id 16 có tỉ lệ 1,5 ± 0,02', (t) async {
    await _pump(t);
    final size = t.getSize(
        find.descendant(of: find.byKey(const Key('card-16')), matching: find.byKey(const Key('image-aspect'))));
    expect(size.width / size.height, closeTo(1.5, 0.02));
  });

  testWidgets('bấm vào thẻ không mở gì, không lỗi', (t) async {
    await _pump(t);
    for (final id in [5, 10, 16, 22, 30]) {
      await t.tap(find.byKey(Key('card-$id')));
      await t.pump();
    }
    expect(t.takeException(), isNull);
    expect(find.byType(ChatScreen), findsOneWidget);
    // Nút gửi của thanh nhập (T-015) có InkWell; thẻ thì không.
    expect(
        find.descendant(
            of: find.byType(ListView), matching: find.byType(InkWell)),
        findsNothing);
  });

  testWidgets('thẻ không tràn ở chữ 200%, sáng và tối', (t) async {
    for (final b in [Brightness.light, Brightness.dark]) {
      t.view.physicalSize = const Size(360, 8000);
      t.view.devicePixelRatio = 1;
      await t.pumpWidget(MaterialApp(
        theme: ThemeData(brightness: b),
        builder: (c, w) => MediaQuery(
            data: MediaQuery.of(c).copyWith(textScaler: const TextScaler.linear(2)),
            child: w!),
        home: ChatScreen(data: _data, now: _now),
      ));
      expect(t.takeException(), isNull);
    }
    addTearDown(t.view.reset);
  });
}
