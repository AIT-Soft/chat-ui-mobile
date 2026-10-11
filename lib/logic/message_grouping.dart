import '../models/message.dart';

/// Ngưỡng gom nhóm (phút), nghiêm ngặt: cách < ngưỡng mới gom.
const int groupThresholdMinutes = 5;

/// Số phút trong ngày từ "HH:mm".
int minutesOfDay(String time) {
  final p = time.split(':');
  return int.parse(p[0]) * 60 + int.parse(p[1]);
}

/// Hai tin liền kề cùng nhóm: cùng người, cùng ngày, cách < 5 phút (FR-03).
bool inSameGroup(Message a, Message b) {
  if (a.from != b.from || a.dayOffset != b.dayOffset) return false;
  final gap = (minutesOfDay(b.time) - minutesOfDay(a.time)).abs();
  return gap < groupThresholdMinutes;
}

/// Gom danh sách tin (đã sắp cũ → mới) thành các nhóm liền kề.
List<List<Message>> groupMessages(List<Message> messages) {
  final groups = <List<Message>>[];
  for (final m in messages) {
    if (groups.isNotEmpty && inSameGroup(groups.last.last, m)) {
      groups.last.add(m);
    } else {
      groups.add([m]);
    }
  }
  return groups;
}
