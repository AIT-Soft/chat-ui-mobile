import 'dart:io';

import 'package:chat_ui_mobile/data/chat_loader.dart';
import 'package:chat_ui_mobile/ui/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final _data = parseChatData(File('assets/chat-sample.json').readAsStringSync());

Future<void> _open(WidgetTester t, {double scale = 1.0}) async {
  t.view.physicalSize = const Size(360, 640);
  t.view.devicePixelRatio = 1.0;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(
    builder: (c, child) => MediaQuery(
        data: MediaQuery.of(c).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!),
    home: ChatScreen(data: _data, now: DateTime(2026, 10, 10)),
  ));
  await t.pump();
}

void main() {
  const expected = {
    2: 'Mai An, Bên em đang cần làm một trang giới thiệu sản phẩm, anh có rảnh nhận dự án không ạ?, 09:13',
    16: 'Mai An, Ảnh phoi-canh-phong-cach.png, Gam màu gỗ sáng và xanh lá dịu, 2,4 MB, 08:31',
    22: 'Mai An, Liên kết Phòng họp dự án Tre Xanh, example.com, 09:12',
    30: 'Lê Quân, Tệp checklist-tuan-1.pdf, Tài liệu PDF, 350 KB, 08:14, Đã nhận',
  };

  testWidgets('NFR-03: nhãn Semantics của tin id 2, 16, 22, 30', (t) async {
    final h = t.ensureSemantics();
    await _open(t);
    for (final e in expected.entries.toList().reversed) {
      final key = find.byKey(Key(e.key == 2 ? 'bubble-2' : 'card-${e.key}'));
      await t.scrollUntilVisible(key, 200,
          scrollable: find.byType(Scrollable).first);
      expect(t.getSemantics(key).label, e.value, reason: 'id ${e.key}');
    }
    h.dispose();
  });

  testWidgets('AC-04.3: nhãn ngày là header', (t) async {
    final h = t.ensureSemantics();
    await _open(t);
    final pill = find.text('Hôm nay');
    await t.dragUntilVisible(pill, find.byType(ListView), const Offset(0, 200));
    final node = t.getSemantics(pill);
    expect(node.flagsCollection.isHeader, isTrue);
    h.dispose();
  });

  testWidgets('NFR-01: điều khiển >= 48x48 dp ở chữ 200%', (t) async {
    await _open(t, scale: 2.0);
    await t.enterText(find.byKey(const Key('input-field')), 'xin chào');
    await t.pump();
    for (final k in ['input-field', 'send-button']) {
      final s = t.getSize(find.byKey(Key(k)));
      expect(s.width, greaterThanOrEqualTo(48), reason: k);
      expect(s.height, greaterThanOrEqualTo(48), reason: k);
    }
  });
}
