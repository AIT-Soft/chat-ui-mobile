import 'package:flutter/material.dart';

/// Token màu theo tài liệu thiết kế (mục 2). Sáng/tối.
class ChatColors {
  const ChatColors({
    required this.surface,
    required this.text,
    required this.textSub,
    required this.bubbleIn,
    required this.bubbleInText,
    required this.bubbleOut,
    required this.bubbleOutText,
    required this.dayPill,
    required this.dayPillText,
    required this.appBar,
    required this.reactionOtherBg,
    required this.reactionOtherText,
    required this.reactionOtherBorder,
    required this.reactionMineBg,
    required this.reactionMineText,
    required this.reactionMineBorder,
    required this.reactionBarBg,
    required this.reactionBarBorder,
  });

  final Color surface;
  final Color text;
  final Color textSub;
  final Color bubbleIn;
  final Color bubbleInText;
  final Color bubbleOut;
  final Color bubbleOutText;
  final Color dayPill;
  final Color dayPillText;
  final Color appBar;

  /// Token reaction (design-reaction.md mục 4).
  final Color reactionOtherBg;
  final Color reactionOtherText;
  final Color reactionOtherBorder;
  final Color reactionMineBg;
  final Color reactionMineText;
  final Color reactionMineBorder;
  final Color reactionBarBg;
  final Color reactionBarBorder;

  static const light = ChatColors(
    surface: Color(0xFFFFFFFF),
    text: Color(0xFF1B1F24),
    textSub: Color(0xFF4B5563),
    bubbleIn: Color(0xFFEBEEF2),
    bubbleInText: Color(0xFF1B1F24),
    bubbleOut: Color(0xFF1A5FB4),
    bubbleOutText: Color(0xFFFFFFFF),
    dayPill: Color(0xFFE3E7ED),
    dayPillText: Color(0xFF374151),
    appBar: Color(0xFFF7F8FA),
    reactionOtherBg: Color(0xFFEBEEF2),
    reactionOtherText: Color(0xFF1B1F24),
    reactionOtherBorder: Color(0xFF4B5563),
    reactionMineBg: Color(0xFF174F96),
    reactionMineText: Color(0xFFFFFFFF),
    reactionMineBorder: Color(0xFF1A5FB4),
    reactionBarBg: Color(0xFFFFFFFF),
    reactionBarBorder: Color(0xFF4B5563),
  );

  static const dark = ChatColors(
    surface: Color(0xFF101317),
    text: Color(0xFFE6E9EE),
    textSub: Color(0xFFA6AFBC),
    bubbleIn: Color(0xFF262C35),
    bubbleInText: Color(0xFFE6E9EE),
    bubbleOut: Color(0xFF2F6FCB),
    bubbleOutText: Color(0xFFFFFFFF),
    dayPill: Color(0xFF2A303A),
    dayPillText: Color(0xFFC9D0DA),
    appBar: Color(0xFF171B21),
    reactionOtherBg: Color(0xFF262C35),
    reactionOtherText: Color(0xFFE6E9EE),
    reactionOtherBorder: Color(0xFFA6AFBC),
    reactionMineBg: Color(0xFF24589F),
    reactionMineText: Color(0xFFFFFFFF),
    reactionMineBorder: Color(0xFF7DB2F5),
    reactionBarBg: Color(0xFF1C2128),
    reactionBarBorder: Color(0xFFA6AFBC),
  );

  static ChatColors of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}

/// Tỉ lệ tương phản WCAG 2.1.
double contrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}
