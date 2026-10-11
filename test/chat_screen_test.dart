import 'dart:io';

import 'package:chat_ui_mobile/data/chat_loader.dart';
import 'package:chat_ui_mobile/theme/chat_colors.dart';
import 'package:chat_ui_mobile/ui/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

final _data = parseChatData(File('assets/chat-sample.json').readAsStringSync());
final _now = DateTime(2026, 10, 10);

Future<void> _open(WidgetTester t, Size size) async {
  t.view.physicalSize = size;
  t.view.devicePixelRatio = 1.0;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(home: ChatScreen(data: _data, now: _now)));
  await t.pump();
}

void main() {
  testWidgets('thanh tiêu đề có tên và trạng thái', (t) async {
    await _open(t, const Size(360, 640));
    expect(find.text('Mai An'), findsOneWidget);
    expect(find.text('Đang hoạt động'), findsOneWidget);
  });

  testWidgets('AC-01.2: avatar tiêu đề tròn 40dp, MA, nền #7A5C8E', (t) async {
    await _open(t, const Size(360, 640));
    final f = find.byKey(const Key('appbar-avatar'));
    expect(f, findsOneWidget);
    expect(t.getSize(f), const Size(40, 40));
    final box = t.widget<Container>(f).decoration as BoxDecoration;
    expect(box.shape, BoxShape.circle);
    expect(box.color, const Color(0xFF7A5C8E));
    expect(find.descendant(of: f, matching: find.text('MA')), findsOneWidget);
  });

  testWidgets('AC-04.3: nhãn ngày là header, đọc nguyên văn', (t) async {
    final h = t.ensureSemantics();
    await _open(t, const Size(360, 6000));
    final n = t.getSemantics(find.byKey(const Key('day-label')).last);
    expect(n.label, anyOf('Thứ Tư, 07/10', 'Hôm qua', 'Hôm nay'));
    expect(n.flagsCollection.isHeader, isTrue);
    h.dispose();
  });

  testWidgets('AC-02.3: tin id 24 xuống dòng, không cắt', (t) async {
    await _open(t, const Size(360, 6000));
    final f = find.byKey(const Key('bubble-text-24'));
    final w = t.widget<Text>(f);
    expect(w.overflow, isNull);
    expect(w.maxLines, isNull);
    final ro = t.renderObject<RenderParagraph>(f);
    expect(ro.didExceedMaxLines, isFalse);
    expect(ro.size.height, greaterThan(16 * 1.2 * 1.5)); // >= 2 dòng
  });

  testWidgets('AC-05.1: giờ 09:13 và 08:31 hiện trên UI', (t) async {
    await _open(t, const Size(360, 6000));
    expect(t.widget<Text>(find.byKey(const Key('time-2'))).data, '09:13');
    expect(t.widget<Text>(find.byKey(const Key('time-16'))).data, '08:31');
  });

  testWidgets('tin 32 thấy khi mở ở 360x640', (t) async {
    await _open(t, const Size(360, 640));
    final r = t.getRect(find.byKey(const Key('bubble-32')));
    expect(r.bottom <= 640 && r.top >= 0, isTrue);
  });

  testWidgets('3 nhãn ngày đúng thứ tự', (t) async {
    // Màn cao để ListView dựng đủ mọi mục.
    await _open(t, const Size(360, 6000));
    final finder = find.byKey(const Key('day-label'));
    final ordered = finder.evaluate().map((e) => e.widget as Text).toList()
      ..sort((a, b) => t
          .getTopLeft(find.byWidget(a))
          .dy
          .compareTo(t.getTopLeft(find.byWidget(b)).dy));
    final labels = ordered.map((w) => w.data).toList();
    expect(labels, ['Thứ Tư, 07/10', 'Hôm qua', 'Hôm nay']);
  });

  for (final w in [360.0, 412.0]) {
    testWidgets('bong bóng ≤ 75% rộng ở ${w}dp', (t) async {
      await _open(t, Size(w, 6000));
      final bubbles = find.byWidgetPredicate(
          (x) => x.key is ValueKey<String> && (x.key as ValueKey<String>).value.startsWith('bubble-') && !(x.key as ValueKey<String>).value.startsWith('bubble-text'));
      expect(bubbles, findsWidgets);
      for (final e in bubbles.evaluate()) {
        expect(t.getSize(find.byWidget(e.widget)).width <= w * 0.75 + 0.01, isTrue);
      }
    });
  }

  testWidgets('tin id 9 hiển thị 2 dòng', (t) async {
    await _open(t, const Size(360, 6000));
    final ro = t.renderObject<RenderParagraph>(find.byKey(const Key('bubble-text-9')));
    final boxes = ro.getBoxesForSelection(
        const TextSelection(baseOffset: 0, extentOffset: 200));
    // "2 dòng" = 2 đoạn ngăn bởi xuống dòng (có thể tự ngắt thêm khi hẹp).
    final text = t.widget<Text>(find.byKey(const Key('bubble-text-9'))).data!;
    expect(text.split('\n').length, 2);
    expect(boxes.map((b) => b.top.round()).toSet().length, greaterThanOrEqualTo(2));
  });

  test('tương phản bong bóng ≥ 4,5 (sáng/tối)', () {
    for (final c in [ChatColors.light, ChatColors.dark]) {
      expect(contrastRatio(c.bubbleInText, c.bubbleIn), greaterThanOrEqualTo(4.5));
      expect(contrastRatio(c.bubbleOutText, c.bubbleOut), greaterThanOrEqualTo(4.5));
      expect(contrastRatio(c.dayPillText, c.dayPill), greaterThanOrEqualTo(4.5));
    }
  });
}
