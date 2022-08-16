import 'package:flutter/material.dart';
import 'dart:io' as io;

class ToolSet {
  static Color hexToColor(String str) {
    int len = str.length;
    if (len < 7 || str[0] != '#') return Colors.black;

    if (len == 9) {
      return Color.fromARGB(
          int.parse(str.substring(1, 3)),
          int.parse(str.substring(3, 5)),
          int.parse(str.substring(5, 7)),
          int.parse(str.substring(7)));
    } else {
      return Color.fromARGB(255, int.parse(str.substring(1, 3)),
          int.parse(str.substring(3, 5)), int.parse(str.substring(5)));
    }
  }

  static Color intToColor(int rgb) {
    return Color(0xFF000000 + rgb);
  }

  int colorToInt(Color color) {
    return (color.red << 16) + (color.green << 8) + color.blue;
  }

  Rect intersection(final Rect rect1, final Rect rect2) {
    if (rect1.size.width == 0 ||
        rect1.size.height == 0 ||
        rect2.size.width == 0 ||
        rect2.size.height == 0) {
      return Rect.zero;
    }

    double left = rect1.left > rect2.left ? rect1.left : rect2.left;
    double right = rect1.right < rect2.right ? rect1.right : rect2.right;
    double top = rect1.top < rect2.top ? rect1.top : rect2.top;
    double bottom = rect1.bottom > rect2.bottom ? rect1.bottom : rect2.bottom;

    if (left > right || top > bottom) {
      return Rect.zero;
    } else {
      return Rect.fromLTRB(left, top, right, bottom);
    }
  }

  int findInStringArray(final List<String> arr, final String str) =>
      arr.indexOf(str);

  bool isFileExist(String fileName) {
    bool res = io.File(fileName).existsSync();
    // TODO Add popup notification logic (using Flame sdk)
    return res;
  }
}
