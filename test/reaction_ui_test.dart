import 'dart:io';
import 'dart:math' as math;

import 'package:chat_ui_mobile/data/chat_loader.dart';
import 'package:chat_ui_mobile/state/reactions.dart';
import 'package:chat_ui_mobile/theme/app_theme.dart';
import 'package:chat_ui_mobile/theme/chat_colors.dart';
import 'package:chat_ui_mobile/ui/chat_screen.dart';
import 'package:chat_ui_mobile/ui/reactions/reaction_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

final _data = parseChatData(File('assets/chat-sample.json').readAsStringSync());

Future<ReactionStore> _open(WidgetTester t,
    {Size size = const Size(360, 640),
    double scale = 1.0,
    ThemeMode mode = ThemeMode.light,
    bool noAnim = false,
    ReactionStore? store}) async {
  final s = store ?? ReactionStore();
  t.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
  if (noAnim) {
    t.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(t.platformDispatcher.clearAccessibilityFeaturesTestValue);
  }
  t.view.physicalSize = size;
  t.view.devicePixelRatio = 1.0;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: mode,
      home: ChatScreen(
          data: _data, now: DateTime(2026, 10, 10, 14, 30), reactions: s)));
  await t.pump();
  return s;
}

Future<void> _longPress32(WidgetTester t) async {
  await t.longPress(find.byKey(const Key('bubble-32')));
  await t.pumpAndSettle();
}

void main() {
  testWidgets('AC-R1/R2/R4: long-press hiện thanh, chọn hiện chip 1, chạm bỏ',
      (t) async {
    final s = await _open(t);
    expect(find.byKey(const Key('reaction-bar')), findsNothing);
    await _longPress32(t);
    expect(find.byKey(const Key('reaction-bar')), findsOneWidget);
    for (final e in reactionEmojis) {
      final r = t.getRect(find.byKey(Key('react-opt-$e')));
      expect(r.width >= 48 && r.height >= 48, isTrue);
    }
    await t.tap(find.byKey(const Key('react-opt-👍')));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('reaction-bar')), findsNothing);
    final chip = find.byKey(const Key('chip-32-👍'));
    expect(chip, findsOneWidget);
    expect(find.descendant(of: chip, matching: find.textContaining('1')),
        findsOneWidget);
    expect(s.reactionOf(32, reactionMeId), '👍');
    final r = t.getRect(chip);
    expect(r.height, 28); // khung nhìn thấy; vùng chạm 48 dp mở rộng ngoài layout
    // chạm cách mép dưới 10 dp (trong vùng chạm mở rộng) vẫn bỏ reaction (9 dp < 10)
    await t.tapAt(Offset(r.center.dx, r.bottom + 9));
    await t.pumpAndSettle();
    expect(chip, findsNothing);
    expect(s.reactionOf(32, reactionMeId), isNull);
  });

  testWidgets('AC-R3: đổi reaction (chọn emoji khác), mỗi người một reaction',
      (t) async {
    final s = await _open(t);
    await _longPress32(t);
    await t.tap(find.byKey(const Key('react-opt-👍')));
    await t.pumpAndSettle();
    await _longPress32(t);
    await t.tap(find.byKey(const Key('react-opt-❤️')));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('chip-32-👍')), findsNothing);
    expect(find.byKey(const Key('chip-32-❤️')), findsOneWidget);
    expect(s.counts(32), {'❤️': 1});
  });

  testWidgets('hủy: chạm ngoài thanh thì không đổi gì', (t) async {
    final s = await _open(t);
    await _longPress32(t);
    await t.tapAt(const Offset(180, 330));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('reaction-bar')), findsNothing);
    expect(s.counts(32), isEmpty);
  });

  testWidgets('seed: chip của peer ở tin 8, chạm để thả cùng emoji', (t) async {
    final s = await _open(t);
    final chip = find.byKey(const Key('chip-8-😂'));
    await t.dragUntilVisible(chip, find.byType(ListView).first, const Offset(0, 300));
    expect(chip, findsOneWidget);
    await t.tap(chip);
    await t.pumpAndSettle();
    expect(s.counts(8), {'😂': 2});
  });

  testWidgets('T-237 (design 2.2): bong bóng < chip < giờ < trạng thái', (t) async {
    await _open(t);
    await _longPress32(t);
    await t.tap(find.byKey(const Key('react-opt-👍')));
    await t.pumpAndSettle();
    final bubble = t.getRect(find.byKey(const Key('bubble-32')));
    final chip = t.getRect(find.byKey(const Key('chip-32-👍')));
    final time = t.getRect(find.byKey(const Key('time-32')));
    final status = t.getRect(find.byKey(const Key('status-32')));
    expect(chip.top, greaterThanOrEqualTo(bubble.bottom));
    expect(time.top, greaterThanOrEqualTo(chip.bottom));
    expect(status.top, greaterThanOrEqualTo(chip.bottom));
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    for (final w in [360.0, 412.0]) {
      testWidgets('T-203: tin 3 có >= 4 chip, ${w.toInt()} dp, chữ 200%, $mode không overflow',
          (t) async {
        await _open(t, size: Size(w, 640), scale: 2.0, mode: mode);
        final chip = find.byKey(const Key('chip-3-👍'));
        await t.dragUntilVisible(chip, find.byType(ListView).first, const Offset(0, 300));
        for (final e in ['👍', '❤️', '😂', '😮']) {
          expect(find.byKey(Key('chip-3-$e')), findsOneWidget);
        }
        expect(t.takeException(), isNull);
      });
    }
  }

  testWidgets('AC-R12: disableAnimations thì không chạy hoạt ảnh', (t) async {
    await _open(t, noAnim: true);
    await t.longPress(find.byKey(const Key('bubble-32')));
    await t.pump();
    // Hiện ngay, không có hoạt ảnh tween nào.
    expect(find.byKey(const Key('reaction-bar')), findsOneWidget);
    expect(find.byType(TweenAnimationBuilder<double>), findsNothing);
    await t.tap(find.byKey(const Key('react-opt-👍')));
    await t.pump();
    expect(find.byKey(const Key('reaction-bar')), findsNothing);
    expect(find.byKey(const Key('chip-32-👍')), findsOneWidget);
    expect(find.byType(TweenAnimationBuilder<double>), findsNothing);
  });

  testWidgets('bật hoạt ảnh thì có tween (đối chứng)', (t) async {
    await _open(t);
    await t.longPress(find.byKey(const Key('bubble-32')));
    await t.pump(const Duration(milliseconds: 10));
    expect(find.byType(TweenAnimationBuilder<double>), findsWidgets);
    await t.pumpAndSettle();
  });

  testWidgets('AC-R10/R11: Semantics tiếng Việt cho thanh, chip và action',
      (t) async {
    final h = t.ensureSemantics();
    final s = await _open(t, store: ReactionStore(seed: {31: {'peer': '👍'}}));
    // Custom action "Thả cảm xúc" trên bong bóng.
    final node = t.getSemantics(find.bySemanticsLabel(RegExp(r'Đã gửi')).last);
    expect(node.getSemanticsData().customSemanticsActionIds, isNotEmpty);
    // Chip của peer.
    expect(find.bySemanticsLabel(RegExp(r'thích, 1 người, bạn chưa chọn')), findsOneWidget);
    await _longPress32(t);
    for (final n in ['thích', 'yêu thích', 'cười', 'ngạc nhiên', 'buồn', 'cảm ơn']) {
      expect(find.bySemanticsLabel('Thả cảm xúc $n'), findsOneWidget);
    }
    expect(find.bySemanticsLabel('Chọn cảm xúc'), findsOneWidget);
    await t.tap(find.byKey(const Key('react-opt-👍')));
    await t.pumpAndSettle();
    expect(find.bySemanticsLabel(RegExp(r'thích, 1 người, bạn đã chọn')), findsOneWidget);
    expect(s.counts(32), {'👍': 1});
    h.dispose();
  });

  Future<void> longPressBubble(WidgetTester t, int id) async {
    final f = find.byKey(Key('bubble-$id'));
    await t.dragUntilVisible(f, find.byType(ListView).first, const Offset(0, 300));
    await t.longPress(f);
    await t.pumpAndSettle();
  }

  testWidgets('F1: ô đang chọn của mình dùng reactionMineBg', (t) async {
    await _open(t);
    await _longPress32(t);
    await t.tap(find.byKey(const Key('react-opt-👍')));
    await t.pumpAndSettle();
    await _longPress32(t);
    BoxDecoration dec(String e) => t
        .widget<Container>(find.descendant(
            of: find.byKey(Key('react-opt-$e')), matching: find.byType(Container)))
        .decoration! as BoxDecoration;
    expect(dec('👍').color, ChatColors.light.reactionMineBg);
    expect(dec('❤️').color, isNull);
  });

  testWidgets('F2: runSpacing 4 dp nhìn thấy, vùng chạm mở rộng 48 dp', (t) async {
    final s = await _open(t, store: ReactionStore(seed: {
      32: {'a': '👍', 'b': '❤️', 'c': '😂', 'd': '😮', 'e': '😢', 'f': '🙏'}
    }));
    expect(s.counts(32).length, 6);
    final wrap = t.widget<Wrap>(find.descendant(
        of: find.byType(ReactionChips), matching: find.byType(Wrap)));
    expect(wrap.runSpacing, 4);
    expect(wrap.spacing, 4);
    const emojis = ['👍', '❤️', '😂', '😮', '😢', '🙏'];
    final rects = [
      for (final e in emojis) t.getRect(find.byKey(Key('chip-32-$e'))),
    ];
    // (1) Khung nhìn thấy: cao 28 dp, hai hàng cách đúng 4 dp.
    expect(rects.first.height, 28);
    final top = rects.first.top;
    final upper = rects.where((r) => r.top == top).toList();
    final lower = rects.where((r) => r.top != top).toList();
    expect(lower, isNotEmpty, reason: 'cần 2 hàng để đo runSpacing');
    expect(lower.first.top - upper.first.bottom, 4);

    // (2) Vùng chạm mỗi chip >= 48x48 dp: chạm cách mép 10 dp (trên hàng đầu,
    // không có hàng liền kề) vẫn trúng chip; cách 11 dp thì không.
    final first = rects.first;
    expect(s.counts(32)['👍'], 1);
    await t.tapAt(Offset(first.center.dx, first.top - 10));
    await t.pumpAndSettle();
    expect(s.counts(32)['👍'], 2);
  });

  // Chạm trong khe 4 dp: [gap] dp dưới mép chip trên; [upper] = chip trên nhận.
  for (final c in [(1.0, true), (3.0, false), (2.0, true)]) {
    testWidgets('F2: chạm khe 4 dp, cách mép trên ${c.$1} dp', (t) async {
      final s = await _open(t, store: ReactionStore(seed: {
        32: {'a': '👍', 'b': '❤️', 'c': '😂', 'd': '😮', 'e': '😢', 'f': '🙏'}
      }));
      const emojis = ['👍', '❤️', '😂', '😮', '😢', '🙏'];
      final rects = [
        for (final e in emojis) t.getRect(find.byKey(Key('chip-32-$e'))),
      ];
      final top = rects.first.top;
      var upIdx = -1, lowIdx = -1;
      for (var i = 0; i < 6; i++) {
        for (var j = 0; j < 6; j++) {
          if (upIdx < 0 && rects[i].top == top && rects[j].top != top &&
              math.max(rects[i].left, rects[j].left) + 2 <
                  math.min(rects[i].right, rects[j].right)) {
            upIdx = i;
            lowIdx = j;
          }
        }
      }
      expect(upIdx, greaterThanOrEqualTo(0));
      final up = rects[upIdx];
      final x = math.max(up.left, rects[lowIdx].left) + 1;
      await t.tapAt(Offset(x, up.bottom + c.$1));
      await t.pumpAndSettle();
      expect(s.reactionOf(32, reactionMeId), emojis[c.$2 ? upIdx : lowIdx]);
    });
  }

  testWidgets('F3: action TalkBack mở thanh đúng anchor như long-press', (t) async {
    final h = t.ensureSemantics();
    await _open(t);
    await _longPress32(t);
    final viaLong = t.getRect(find.byKey(const Key('reaction-bar')));
    await t.tapAt(const Offset(5, 5));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('reaction-bar')), findsNothing);
    final node = t.getSemantics(find.bySemanticsLabel(RegExp(r'Đã gửi')).last);
    final ids = node.getSemanticsData().customSemanticsActionIds!;
    t.semantics.performAction(find.semantics.byLabel(RegExp(r'Đã gửi')).last,
        SemanticsAction.customAction, args: ids.first);
    await t.pump();
    await t.pumpAndSettle();
    expect(t.getRect(find.byKey(const Key('reaction-bar'))), viaLong);
    h.dispose();
  });

  testWidgets('F8a: peer đã có 😂 ở tin 8, chọn 😂 qua thanh thì n→n+1', (t) async {
    final s = await _open(t);
    await longPressBubble(t, 8);
    expect(s.counts(8), {'😂': 1});
    await t.tap(find.byKey(const Key('react-opt-😂')));
    await t.pumpAndSettle();
    expect(s.counts(8), {'😂': 2});
    expect(s.reactionOf(8, reactionMeId), '😂');
  });

  testWidgets('F8b: đã có reaction của mình, chạm chip peer thì đổi', (t) async {
    final s = await _open(t);
    s.set(8, reactionMeId, '👍');
    await t.pumpAndSettle();
    final chip = find.byKey(const Key('chip-8-😂'));
    await t.dragUntilVisible(chip, find.byType(ListView).first, const Offset(0, 300));
    await t.tap(chip);
    await t.pumpAndSettle();
    expect(s.counts(8), {'😂': 2});
    expect(s.reactionOf(8, reactionMeId), '😂');
  });

  testWidgets('F8c: hoạt ảnh sau khi thả reaction kết thúc <= 200 ms', (t) async {
    await _open(t);
    await _longPress32(t);
    await t.tap(find.byKey(const Key('react-opt-👍')));
    await t.pump(const Duration(milliseconds: 10));
    final tweens = t.widgetList<TweenAnimationBuilder<double>>(
        find.byType(TweenAnimationBuilder<double>));
    expect(tweens, isNotEmpty);
    for (final w in tweens) {
      expect(w.duration, lessThanOrEqualTo(const Duration(milliseconds: 200)));
    }
    await t.pump(const Duration(milliseconds: 200));
    expect(find.byKey(const Key('reaction-bar')), findsNothing);
  });

  testWidgets('F8d: nhãn ngày không đổi khi có chip', (t) async {
    final s = await _open(t);
    List<String> labels() => t
        .widgetList<Text>(find.byKey(const Key('day-label')))
        .map((e) => e.data ?? e.textSpan?.toPlainText() ?? '')
        .toList();
    await t.dragUntilVisible(find.byKey(const Key('day-label')),
        find.byType(ListView).first, const Offset(0, 300));
    final before = labels();
    expect(before, isNotEmpty);
    s.set(32, reactionMeId, '👍');
    s.set(31, reactionMeId, '❤️');
    await t.pumpAndSettle();
    expect(labels(), before);
  });


  test('AC-R8: tương phản token reaction >= 4,5 (chữ) và >= 3 (viền)', () {
    for (final c in [ChatColors.light, ChatColors.dark]) {
      expect(contrastRatio(c.reactionOtherText, c.reactionOtherBg), greaterThanOrEqualTo(4.5));
      expect(contrastRatio(c.reactionMineText, c.reactionMineBg), greaterThanOrEqualTo(4.5));
      expect(contrastRatio(c.reactionOtherBorder, c.surface), greaterThanOrEqualTo(3));
      expect(contrastRatio(c.reactionMineBorder, c.surface), greaterThanOrEqualTo(3));
      expect(contrastRatio(c.reactionBarBorder, c.reactionBarBg), greaterThanOrEqualTo(3));
    }
  });

  for (final size in const [Size(360, 640), Size(412, 915)]) {
    for (final mode in const [ThemeMode.light, ThemeMode.dark]) {
      testWidgets(
          'AC-R9: chữ 200% ${size.width.toInt()} ${mode.name} đủ 6 chip + thanh không overflow',
          (t) async {
        final store =
            await _open(t, size: size, scale: 2.0, mode: mode);
        expect(t.takeException(), isNull);
        await t.longPress(find.byKey(const Key('bubble-32')));
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
        final bar = t.getRect(find.byKey(const Key('reaction-bar')));
        expect(bar.left >= 12 - 0.5 && bar.right <= size.width - 12 + 0.5, isTrue);
        for (final e in reactionEmojis) {
          final r = t.getRect(find.byKey(Key('react-opt-$e')));
          expect(r.width >= 48 && r.height >= 48, isTrue);
        }
        await t.tap(find.byKey(const Key('react-opt-🙏')));
        await t.pumpAndSettle();
        const others = {'a': '👍', 'b': '❤️', 'c': '😂', 'd': '😮', 'e': '😢'};
        others.forEach((u, e) => store.set(32, u, e));
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
        for (final e in reactionEmojis) {
          final f = find.byKey(Key('chip-32-$e'));
          expect(f, findsOneWidget);
          final r = t.getRect(f);
          expect(r.width >= 48 && r.height >= 48, isTrue);
          expect(r.right <= size.width, isTrue);
        }
      });
    }
  }
}
