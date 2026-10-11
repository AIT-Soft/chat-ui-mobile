import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import '../models/chat_data.dart';
import '../models/message.dart';
import '../models/participant.dart';

const chatSampleAsset = 'assets/chat-sample.json';
const supportedSchemaVersion = '1.0';

/// Thông báo hiển thị khi dữ liệu mẫu lỗi (AC-12.2).
const chatLoadErrorMessage = 'Không đọc được dữ liệu mẫu';

/// Lỗi có kiểm soát khi nạp/phân tích dữ liệu mẫu.
class ChatDataException implements Exception {
  const ChatDataException(this.detail);
  final String detail;

  @override
  String toString() => 'ChatDataException: $detail';
}

Future<ChatData> loadChatSample([AssetBundle? bundle]) async {
  final String raw;
  try {
    raw = await (bundle ?? rootBundle).loadString(chatSampleAsset);
  } catch (e) {
    throw ChatDataException('không mở được $chatSampleAsset: $e');
  }
  return parseChatData(raw);
}

/// Phân tích chuỗi JSON theo lược đồ 1.0; mọi sai lệch ném [ChatDataException].
ChatData parseChatData(String source) {
  final Object? root;
  try {
    root = jsonDecode(source);
  } on FormatException catch (e) {
    throw ChatDataException('JSON không hợp lệ: ${e.message}');
  }
  final map = _asMap(root, 'gốc');
  final version = map['schemaVersion'];
  if (version != supportedSchemaVersion) {
    throw ChatDataException(
      'schemaVersion không được hỗ trợ: $version (cần $supportedSchemaVersion)',
    );
  }
  final participants = _asMap(map['participants'], 'participants');
  final rawMessages = map['messages'];
  if (rawMessages is! List) {
    throw const ChatDataException('thiếu hoặc sai kiểu "messages"');
  }
  final messages = <Message>[
    for (var i = 0; i < rawMessages.length; i++)
      _parseMessage(_asMap(rawMessages[i], 'messages[$i]'), 'messages[$i]'),
  ];
  return ChatData(
    disclaimer: _str(map, 'disclaimer', 'gốc'),
    me: _parseParticipant(participants['me'], 'participants.me'),
    peer: _parseParticipant(participants['peer'], 'participants.peer'),
    messages: messages,
  );
}

Map<String, dynamic> _asMap(Object? v, String where) {
  if (v is Map<String, dynamic>) return v;
  throw ChatDataException('$where phải là đối tượng');
}

String _str(Map<String, dynamic> m, String key, String where) {
  final v = m[key];
  if (v is String) return v;
  throw ChatDataException('$where: thiếu hoặc sai kiểu "$key"');
}

String? _optStr(Map<String, dynamic> m, String key, String where) {
  if (!m.containsKey(key) || m[key] == null) return null;
  return _str(m, key, where);
}

int _int(Map<String, dynamic> m, String key, String where) {
  final v = m[key];
  if (v is int) return v;
  throw ChatDataException('$where: thiếu hoặc sai kiểu "$key"');
}

int _color(String hex, String where) {
  if (!RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(hex)) {
    throw ChatDataException('$where: màu "$hex" không phải #RRGGBB');
  }
  return 0xFF000000 | int.parse(hex.substring(1), radix: 16);
}

Participant _parseParticipant(Object? v, String where) {
  final m = _asMap(v, where);
  return Participant(
    id: _str(m, 'id', where),
    name: _str(m, 'name', where),
    initials: _str(m, 'initials', where),
    avatarColor: _color(_str(m, 'avatarColor', where), where),
    status: _optStr(m, 'status', where),
  );
}

T _enum<T extends Enum>(List<T> values, String raw, String what, String where) {
  for (final e in values) {
    if (e.name == raw) return e;
  }
  throw ChatDataException('$where: $what lạ "$raw"');
}

Message _parseMessage(Map<String, dynamic> m, String where) {
  final id = _int(m, 'id', where);
  final from = _enum(Sender.values, _str(m, 'from', where), 'from', where);
  final dayOffset = _int(m, 'dayOffset', where);
  if (dayOffset > 0) throw ChatDataException('$where: dayOffset phải <= 0');
  final time = _str(m, 'time', where);
  if (!RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(time)) {
    throw ChatDataException('$where: time "$time" không phải HH:mm');
  }
  final type = _enum(MessageType.values, _str(m, 'type', where), 'type', where);
  final statusRaw = _optStr(m, 'status', where);
  final status = statusRaw == null
      ? null
      : _enum(MessageStatus.values, statusRaw, 'status', where);

  return Message(
    id: id,
    from: from,
    dayOffset: dayOffset,
    time: time,
    type: type,
    status: status,
    text: type == MessageType.text ? _str(m, 'text', where) : null,
    file: type == MessageType.file
        ? _parseFile(_asMap(m['file'], '$where.file'), '$where.file')
        : null,
    image: type == MessageType.image
        ? _parseImage(_asMap(m['image'], '$where.image'), '$where.image')
        : null,
    link: type == MessageType.link
        ? _parseLink(_asMap(m['link'], '$where.link'), '$where.link')
        : null,
  );
}

FileInfo _parseFile(Map<String, dynamic> m, String where) {
  final sizeBytes = m['sizeBytes'];
  if (sizeBytes != null && sizeBytes is! int) {
    throw ChatDataException('$where: sai kiểu "sizeBytes"');
  }
  return FileInfo(
    name: _str(m, 'name', where),
    kind: _enum(FileKind.values, _str(m, 'kind', where), 'kind', where),
    sizeBytes: sizeBytes as int?,
    sizeLabel: _str(m, 'sizeLabel', where),
    typeLabel: _str(m, 'typeLabel', where),
  );
}

ImageInfo _parseImage(Map<String, dynamic> m, String where) {
  final g = m['gradient'];
  if (g is! List || g.length != 2 || g.any((c) => c is! String)) {
    throw ChatDataException('$where: "gradient" phải là mảng 2 màu');
  }
  final aspect = m['aspect'];
  if (aspect is! num || aspect <= 0) {
    throw ChatDataException('$where: "aspect" phải là số > 0');
  }
  return ImageInfo(
    name: _str(m, 'name', where),
    sizeLabel: _str(m, 'sizeLabel', where),
    typeLabel: _str(m, 'typeLabel', where),
    gradient: [for (final c in g) _color(c as String, where)],
    aspect: aspect.toDouble(),
    caption: _optStr(m, 'caption', where),
  );
}

LinkInfo _parseLink(Map<String, dynamic> m, String where) => LinkInfo(
      title: _str(m, 'title', where),
      url: _str(m, 'url', where),
      domain: _str(m, 'domain', where),
      description: _str(m, 'description', where),
    );
