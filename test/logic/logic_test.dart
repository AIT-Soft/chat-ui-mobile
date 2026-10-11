import 'dart:io';

import 'package:chat_ui_mobile/data/chat_loader.dart';
import 'package:chat_ui_mobile/logic/day_label.dart';
import 'package:chat_ui_mobile/logic/message_grouping.dart';
import 'package:chat_ui_mobile/models/message.dart';
import 'package:flutter_test/flutter_test.dart';

Message _m(int id, String time,
        {Sender from = Sender.peer, int day = 0}) =>
    Message(
        id: id, from: from, dayOffset: day, time: time, type: MessageType.text);

void main() {
  group('gom nhóm', () {
    final msgs = parseChatData(
            File('assets/chat-sample.json').readAsStringSync())
        .messages;
    final ids = groupMessages(msgs)
        .map((g) => g.map((m) => m.id).toList())
        .toList();
    bool together(int a, int b) =>
        ids.any((g) => g.contains(a) && g.contains(b));

    test('dữ liệu mẫu: các bộ cùng nhóm', () {
      for (final g in [
        [1, 2], [4, 5], [12, 13], [14, 15, 16], [20, 21, 22], [29, 30],
      ]) {
        expect(ids.any((x) => x.toString() == g.toString()), isTrue,
            reason: 'nhóm $g');
      }
    });

    test('dữ liệu mẫu: các cặp không gộp', () {
      expect(together(6, 7), isFalse);
      expect(together(11, 12), isFalse);
      expect(together(23, 24), isFalse);
    });

    test('4 phút gom, 5 phút không gom, khác ngày/người không gom', () {
      expect(inSameGroup(_m(1, '10:00'), _m(2, '10:04')), isTrue);
      expect(inSameGroup(_m(1, '10:00'), _m(2, '10:05')), isFalse);
      expect(inSameGroup(_m(1, '23:59', day: -1), _m(2, '00:01')), isFalse);
      expect(
          inSameGroup(_m(1, '10:00'), _m(2, '10:01', from: Sender.me)), isFalse);
    });

    test('AC-03.3: cách 2 phút nhưng khác ngày thì không gom', () {
      expect(inSameGroup(_m(1, '10:00', day: -1), _m(2, '10:02')), isFalse);
    });

    test('danh sách rỗng', () => expect(groupMessages([]), isEmpty));
  });

  group('nhãn ngày', () {
    final now = DateTime(2026, 10, 10); // Thứ Bảy
    test('hôm nay/hôm qua', () {
      expect(dayLabel(0, now), 'Hôm nay');
      expect(dayLabel(-1, now), 'Hôm qua');
    });
    test('-3 là Thứ Tư, 07/10', () {
      expect(dayLabel(-3, now), 'Thứ Tư, 07/10');
    });
    test('đủ 7 thứ', () {
      expect(dayLabel(-2, now), 'Thứ Năm, 08/10');
      expect(dayLabel(-4, now), 'Thứ Ba, 06/10');
      expect(dayLabel(-5, now), 'Thứ Hai, 05/10');
      expect(dayLabel(-6, now), 'Chủ nhật, 04/10');
      expect(dayLabel(-7, now), 'Thứ Bảy, 03/10');
      expect(dayLabel(-8, now), 'Thứ Sáu, 02/10');
    });
    test('khác năm thêm /yyyy', () {
      expect(dayLabel(-3, DateTime(2026, 1, 2)), 'Thứ Ba, 30/12/2025');
    });
  });
}
