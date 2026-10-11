import 'package:flutter/material.dart';

import '../../models/message.dart';
import 'card_style.dart';

/// Thẻ tệp (FR-07): ô biểu tượng pdf/xlsx + tên (≤2 dòng) + loại · dung lượng.
class FileCard extends StatelessWidget {
  const FileCard({super.key, required this.file, required this.mine});

  final FileInfo file;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final s = CardStyle.of(context, mine: mine);
    final isPdf = file.kind == FileKind.pdf;
    final label = isPdf ? 'PDF' : 'XLS';
    final tileColor =
        isPdf ? const Color(0xFFB3261E) : const Color(0xFF1E7B45);
    return Semantics(
      container: true,
      label: '${isPdf ? 'Tệp PDF' : 'Tệp Excel'}, ${file.name}, ${file.sizeLabel}',
      child: ExcludeSemantics(
        child: CardFrame(
          style: s,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                key: const Key('file-icon'),
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: tileColor,
                  borderRadius: BorderRadius.circular(
                      isPdf ? 4 : 8), // trang vs lưới: khác hình
                ),
                child: Text(label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(file.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: s.title,
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                    Text('${file.typeLabel} · ${file.sizeLabel}',
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
