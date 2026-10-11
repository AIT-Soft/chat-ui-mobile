enum Sender { me, peer }

enum MessageType { text, file, image, link }

enum MessageStatus { sent, delivered, seen }

enum FileKind { pdf, xlsx }

class FileInfo {
  const FileInfo({
    required this.name,
    required this.kind,
    required this.sizeLabel,
    required this.typeLabel,
    this.sizeBytes,
  });

  final String name;
  final FileKind kind;
  final int? sizeBytes;
  final String sizeLabel;
  final String typeLabel;
}

class ImageInfo {
  const ImageInfo({
    required this.name,
    required this.sizeLabel,
    required this.typeLabel,
    required this.gradient,
    required this.aspect,
    this.caption,
  });

  final String name;
  final String sizeLabel;
  final String typeLabel;

  /// Hai màu 0xFFRRGGBB.
  final List<int> gradient;

  /// Rộng / cao, > 0.
  final double aspect;
  final String? caption;
}

class LinkInfo {
  const LinkInfo({
    required this.title,
    required this.url,
    required this.domain,
    required this.description,
  });

  final String title;
  final String url;
  final String domain;
  final String description;
}

class Message {
  const Message({
    required this.id,
    required this.from,
    required this.dayOffset,
    required this.time,
    required this.type,
    this.status,
    this.text,
    this.file,
    this.image,
    this.link,
  });

  final int id;
  final Sender from;

  /// 0 = hôm nay, -1 = hôm qua, ... (<= 0).
  final int dayOffset;

  /// "HH:mm".
  final String time;
  final MessageType type;
  final MessageStatus? status;
  final String? text;
  final FileInfo? file;
  final ImageInfo? image;
  final LinkInfo? link;
}
