import 'package:flutter/material.dart';

import 'chat_colors.dart';

/// ThemeData sáng/tối dựng từ token màu của designer (FR-09).
class AppTheme {
  static ThemeData get light => _build(ChatColors.light, Brightness.light);
  static ThemeData get dark => _build(ChatColors.dark, Brightness.dark);

  static ThemeData _build(ChatColors c, Brightness b) {
    final scheme = ColorScheme.fromSeed(
      seedColor: c.bubbleOut,
      brightness: b,
    ).copyWith(
      surface: c.surface,
      onSurface: c.text,
      onSurfaceVariant: c.textSub,
      primary: c.bubbleOut,
      onPrimary: c.bubbleOutText,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: c.appBar,
        foregroundColor: c.text,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
