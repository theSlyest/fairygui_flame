import 'package:flutter_test/flutter_test.dart';
import 'package:fariygui_flame/utils/tool_set.dart';
import 'package:flutter/material.dart';

void main() {
  test('Convert hex String to Color', () {
    expect(
        ToolSet.hexToColor("#800000FF"), const Color.fromARGB(128, 0, 0, 255));
    expect(ToolSet.hexToColor("#008000"), const Color.fromARGB(255, 0, 128, 0));
  });

  test('Convert RGB int to Color', () {
    expect(ToolSet.intToColor(int.parse("800040", radix: 16)),
        const Color.fromARGB(255, 128, 0, 64));
  });

  test('Convert Color to RGB int', () {
    expect(ToolSet.colorToInt(const Color.fromARGB(255, 128, 0, 64)),
        int.parse("800040", radix: 16));
  });

  test('Return intersection of 2 Rects', () {
    expect(
        ToolSet.intersection(const Rect.fromLTRB(0, 0, 10, 10),
            const Rect.fromLTRB(5, 5, 15, 15)),
        const Rect.fromLTRB(5, 5, 10, 10));
  });
}
