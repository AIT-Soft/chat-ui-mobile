import 'package:chat_ui_mobile/state/reactions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('thêm, đổi, bỏ reaction', () {
    final s = ReactionStore(seed: const {});
    s.set(1, 'me', '👍');
    expect(s.reactionOf(1, 'me'), '👍');
    expect(s.counts(1), {'👍': 1});
    s.set(1, 'me', '❤️');
    expect(s.counts(1), {'❤️': 1});
    s.remove(1, 'me');
    expect(s.reactionOf(1, 'me'), isNull);
    expect(s.counts(1), isEmpty);
  });

  test('mỗi người một reaction mỗi tin, đếm theo emoji', () {
    final s = ReactionStore(seed: const {});
    s.set(1, 'me', '👍');
    s.set(1, 'peer', '👍');
    s.set(1, 'me', '😂');
    expect(s.counts(1), {'👍': 1, '😂': 1});
    s.set(1, 'peer', '😂');
    expect(s.counts(1), {'😂': 2});
  });

  test('toggle: cùng emoji thì bỏ, khác thì đổi', () {
    final s = ReactionStore(seed: const {});
    s.toggle(2, 'me', '🙏');
    expect(s.reactionOf(2, 'me'), '🙏');
    s.toggle(2, 'me', '😮');
    expect(s.reactionOf(2, 'me'), '😮');
    s.toggle(2, 'me', '😮');
    expect(s.reactionOf(2, 'me'), isNull);
  });

  test('thông báo thay đổi đúng lúc', () {
    final s = ReactionStore(seed: const {});
    var n = 0;
    s.addListener(() => n++);
    s.set(1, 'me', '👍');
    s.set(1, 'me', '👍');
    s.remove(1, 'peer');
    s.remove(1, 'me');
    expect(n, 2);
  });

  test('seed có >= 3 tin mang reaction của người khác, không chứa me', () {
    final s = ReactionStore();
    final ids = seedReactions.keys.where((id) => s.counts(id).isNotEmpty);
    expect(ids.length, greaterThanOrEqualTo(3));
    for (final id in ids) {
      expect(s.reactionOf(id, reactionMeId), isNull);
      expect(s.reactionOf(id, 'peer'), isNotNull);
    }
  });

  test('seed: tin 3 có >= 4 emoji khác nhau, không chứa me', () {
    final s = ReactionStore();
    expect(s.counts(3).length, greaterThanOrEqualTo(4));
    expect(s.reactionOf(3, reactionMeId), isNull);
  });

  test('hai store độc lập, không dùng chung seed', () {
    final a = ReactionStore();
    final b = ReactionStore();
    a.set(3, 'me', '🙏');
    expect(b.reactionOf(3, 'me'), isNull);
    expect(seedReactions[3]!.containsKey('me'), isFalse);
  });
}
