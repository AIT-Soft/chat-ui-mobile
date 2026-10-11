import 'dart:convert';
import 'dart:io';

import 'package:chat_ui_mobile/data/chat_loader.dart';
import 'package:chat_ui_mobile/models/message.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _base() => {
      'schemaVersion': '1.0',
      'disclaimer': 'x',
      'participants': {
        'me': {'id': 'me', 'name': 'A', 'initials': 'A', 'avatarColor': '#112233'},
        'peer': {'id': 'peer', 'name': 'B', 'initials': 'B', 'avatarColor': '#445566'},
      },
      'messages': <Object>[
        {'id': 1, 'from': 'me', 'dayOffset': 0, 'time': '09:00', 'type': 'text', 'text': 'hi'},
      ],
    };

void main() {
  final sample = File('assets/chat-sample.json').readAsStringSync();

  test('nạp file mẫu: 32 tin, id 1..32, 13/11/8 theo ngày (AC-12.1)', () {
    final data = parseChatData(sample);
    expect(data.messages.map((m) => m.id), List.generate(32, (i) => i + 1));
    int count(int d) => data.messages.where((m) => m.dayOffset == d).length;
    expect([count(-3), count(-1), count(0)], [13, 11, 8]);
    expect(data.disclaimer, 'Bản thiết kế mẫu – nội dung hư cấu');
    expect(data.peer.status, isNotNull);
    expect(data.me.avatarColor, 0xFF5B7C99);
    final cards = data.messages
        .where((m) => m.type != MessageType.text)
        .map((m) => m.id);
    expect(cards, [5, 10, 16, 22, 30]);
  });

  test('dữ liệu hợp lệ tối thiểu', () {
    expect(parseChatData(jsonEncode(_base())).messages, hasLength(1));
  });

  void expectError(void Function(Map<String, dynamic>) mutate) {
    final m = _base();
    mutate(m);
    expect(() => parseChatData(jsonEncode(m)), throwsA(isA<ChatDataException>()));
  }

  Map<String, dynamic> msg(Map<String, dynamic> m) =>
      (m['messages'] as List).first as Map<String, dynamic>;

  test('lỗi có kiểm soát (AC-12.2)', () {
    expect(() => parseChatData('{không phải json'), throwsA(isA<ChatDataException>()));
    expect(() => parseChatData('[]'), throwsA(isA<ChatDataException>()));
    expectError((m) => m['schemaVersion'] = '0.1-research-draft');
    expectError((m) => m.remove('disclaimer'));
    expectError((m) => m.remove('messages'));
    expectError((m) => msg(m)['type'] = 'video');
    expectError((m) => msg(m).remove('text'));
    expectError((m) => msg(m).remove('time'));
    expectError((m) => msg(m)['time'] = '9h');
    expectError((m) => msg(m)['dayOffset'] = 1);
    expectError((m) => msg(m)['from'] = 'bot');
    expectError((m) => msg(m)['status'] = 'read');
    expectError((m) => m['participants']['me'].remove('name'));
    expectError((m) => m['participants']['me']['avatarColor'] = 'red');
    expectError((m) {
      msg(m)
        ..['type'] = 'file'
        ..remove('text');
    });
  });

  test('trường lạ bị bỏ qua', () {
    final m = _base()..['extra'] = 1;
    msg(m)['zzz'] = true;
    expect(parseChatData(jsonEncode(m)).messages, hasLength(1));
  });
}
