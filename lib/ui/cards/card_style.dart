import 'package:flutter/material.dart';

/// Màu thẻ theo thiết kế mục 2 (đến/đi, sáng/tối).
class CardStyle {
  const CardStyle({
    required this.bg,
    required this.title,
    required this.sub,
    required this.outline,
  });

  final Color bg;
  final Color title;
  final Color sub;
  final Color outline;

  static CardStyle of(BuildContext context, {required bool mine}) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    if (mine) {
      return dark
          ? const CardStyle(
              bg: Color(0xFF24589F),
              title: Color(0xFFFFFFFF),
              sub: Color(0xFFE3ECFA),
              outline: Color(0xFF3A424D))
          : const CardStyle(
              bg: Color(0xFF174F96),
              title: Color(0xFFFFFFFF),
              sub: Color(0xFFE6EEFA),
              outline: Color(0xFFC9D0DA));
    }
    return dark
        ? const CardStyle(
            bg: Color(0xFF1C2128),
            title: Color(0xFFE6E9EE),
            sub: Color(0xFFA6AFBC),
            outline: Color(0xFF3A424D))
        : const CardStyle(
            bg: Color(0xFFF3F5F8),
            title: Color(0xFF1B1F24),
            sub: Color(0xFF4B5563),
            outline: Color(0xFFC9D0DA));
  }
}

/// Khung chung: bo 12 dp, viền 1 dp, không onTap/hiệu ứng nhấn.
class CardFrame extends StatelessWidget {
  const CardFrame({
    super.key,
    required this.style,
    required this.child,
    this.padding = const EdgeInsets.all(12),
  });

  final CardStyle style;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: style.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: style.outline, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
