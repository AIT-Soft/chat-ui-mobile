import 'package:flutter/material.dart';

import '../../models/message.dart';
import 'card_style.dart';

/// Thẻ liên kết (FR-07): dải dọc 4 dp, tiêu đề, mô tả, domain. Không mở được.
class LinkCard extends StatelessWidget {
  const LinkCard({super.key, required this.link, required this.mine});

  final LinkInfo link;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final s = CardStyle.of(context, mine: mine);
    return Semantics(
      container: true,
      label: 'Liên kết, ${link.title}, ${link.domain}',
      child: ExcludeSemantics(
        child: CardFrame(
          style: s,
          padding: EdgeInsets.zero,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                    key: const Key('link-strip'),
                    width: 4,
                    color: s.title.withValues(alpha: 0.85)),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(link.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: s.title,
                                fontSize: 15,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(link.description,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: s.sub, fontSize: 12)),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.link, size: 16, color: s.sub),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(link.domain,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: s.sub, fontSize: 12)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
