import 'package:flutter/material.dart';

import '../theme/chat_colors.dart';

/// Dải chú thích mẫu cố định dưới thanh tiêu đề (FR-11).
class DisclaimerBanner extends StatelessWidget {
  const DisclaimerBanner({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = ChatColors.of(context);
    return Semantics(
      container: true,
      label: text,
      excludeSemantics: true,
      child: Container(
        key: const Key('disclaimer-banner'),
        width: double.infinity,
        color: c.dayPill,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Text(
          text,
          key: const Key('disclaimer-text'),
          textAlign: TextAlign.center,
          style: TextStyle(
              color: c.dayPillText, fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
