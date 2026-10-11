import 'package:flutter/material.dart';

import '../../models/message.dart' as m;
import 'card_style.dart';

/// Thẻ ảnh (FR-07): khung gradient đúng `aspect`, chú thích, tên · dung lượng.
class ImageCard extends StatelessWidget {
  const ImageCard({super.key, required this.image, required this.mine});

  final m.ImageInfo image;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final s = CardStyle.of(context, mine: mine);
    final caption = image.caption;
    return Semantics(
      container: true,
      label: 'Ảnh, ${image.name}${caption != null ? ', $caption' : ''}',
      child: ExcludeSemantics(
        child: CardFrame(
          style: s,
          padding: EdgeInsets.zero,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                key: const Key('image-aspect'),
                aspectRatio: image.aspect,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(image.gradient[0]), Color(image.gradient[1])],
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.landscape_outlined,
                        size: 40, color: Colors.white),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (caption != null)
                      Text(caption,
                          style: TextStyle(
                              color: s.title,
                              fontSize: 15,
                              fontWeight: FontWeight.w600)),
                    Text('${image.name} · ${image.sizeLabel}',
                        style: TextStyle(color: s.sub, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
