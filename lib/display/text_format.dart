import 'package:flutter/material.dart';

class TextFormat {
  static const int outline = 1;
  static const int shadow = 2;
  static const int glow = 4;

  bool _hasColor;

  String? face;
  double fontSize;
  Color color;
  bool bold;
  bool italics;
  bool underline;
  int lineSpacing;
  int letterSpacing;
  TextAlign align;
  TextAlignVertical verticalAlign;

  int effect;
  Color? outlineColor;
  int outlineSize;
  Color? shadowColor;
  Size? shadowOffset;
  int shadowBlurRadius;
  Color? glowColor;

  TextFormat()
      : fontSize = 12,
        color = Colors.black,
        bold = false,
        italics = false,
        underline = false,
        lineSpacing = 3,
        letterSpacing = 0,
        align = TextAlign.left,
        verticalAlign = TextAlignVertical.top,
        effect = 0,
        outlineSize = 1,
        shadowBlurRadius = 0,
        _hasColor = false;

  void enableEffect(int effectFlag) => effect |= effectFlag;

  void disableEffect(int effectFlag) => effect &= ~effectFlag;

  bool hasEffect(int effectFlag) => (effect & effectFlag) != 0;
}
