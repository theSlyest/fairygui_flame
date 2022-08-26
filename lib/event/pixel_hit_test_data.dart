import 'dart:math';

import 'package:fairygui_flame/utils/byte_buffer.dart';

class PixelHitTestData {
  int pixelWidth;
  double scale;
  List<int>? pixels;

  PixelHitTestData()
      : pixelWidth = 0,
        scale = 1;

  void load(ByteBuffer buffer) {
    buffer.skip(4);
    pixelWidth = buffer.readInt();
    scale = 1.0 / buffer.readByte();
    int len = buffer.readInt();
    pixels = [];
    pixels!.length = len;
    for (int i = 0; i < len; ++i) {
      pixels![i] = buffer.readByte();
    }
  }
}
