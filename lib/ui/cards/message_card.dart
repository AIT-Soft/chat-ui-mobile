import 'package:flutter/widgets.dart';

import '../../models/message.dart';
import 'file_card.dart';
import 'image_card.dart';
import 'link_card.dart';

/// Chọn thẻ theo loại tin; trả null nếu tin là văn bản.
Widget? buildMessageCard(Message m) {
  final mine = m.from == Sender.me;
  switch (m.type) {
    case MessageType.file:
      return m.file == null ? null : FileCard(file: m.file!, mine: mine);
    case MessageType.image:
      return m.image == null ? null : ImageCard(image: m.image!, mine: mine);
    case MessageType.link:
      return m.link == null ? null : LinkCard(link: m.link!, mine: mine);
    case MessageType.text:
      return null;
  }
}
