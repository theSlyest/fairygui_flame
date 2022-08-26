import 'package:fairygui_flame/event/pixel_hit_test_data.dart';
import 'package:fairygui_flame/ui_package.dart';
import 'package:fairygui_flame/utils/byte_buffer.dart';
import 'package:flame/extensions.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/animation.dart';

import 'field_types.dart';

class PackageItem {
  UIPackage owner;
  PackageItemType type;
  ObjectType objectType;
  String id;
  String name;
  int width;
  int height;
  String file;
  ByteBuffer rawData;
  List<String> branches;
  List<String> highResolution;

  // atlas
  Image? texture;

  // image
  Rect scale9Grid;
  bool scaleByTile;
  int tileGridIndice;
  Sprite? spriteFrame;
  PixelHitTestData pixelHitTestData;

  // movie clip
  Animation animation;
  double delayPoint;
  double repeatDelay;
  bool swing;

  // component
  GComponent Function()? extensionCreator;
  bool translated;

  // font
  // bitmapFont;

  // skeleton
  Vector2 skeletonAnchor;

  PackageItem();
}
