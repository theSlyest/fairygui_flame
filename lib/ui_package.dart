import 'dart:developer';
import 'dart:typed_data';

import 'package:fairygui_flame/event/pixel_hit_test_data.dart';
import 'package:fairygui_flame/field_types.dart';
import 'package:fairygui_flame/ui_object_factory.dart';
import 'package:fairygui_flame/utils/byte_buffer.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flutter/services.dart';

import 'package_item.dart';

class AtlasSprite {
  late PackageItem atlas;
  Rect rect = Rect.zero;
  Size originalSize = Size.zero;
  Vector2 offset = Vector2.zero();
  bool rotated = false;
}

class UIPackage {
  static final Map<String, UIPackage> _packageInstById = {};
  static final Map<String, UIPackage> _packageInstByName = {};
  static final List<UIPackage> _packageList = [];
  static final Map<String, String> _vars = {};
  static String _branch = '';

  static Image? _emptyTexture;
  static const String _emptyTextureData =
      "iVBORw0KGgoAAAANSUhEUgAAAAIAAAACEAYAAAAiJtFnAAABg2lDQ1BJQ0MgcHJvZmlsZQAAKJF1kT1Iw1AUhU//aIcWO4ioOGSoThakirhahSJUCbVCFZfkpbaFJg0vKV0cBdeCg+ji3+LopIuDg6uToAjiKO6ii5Z4XyK2SPMguV8O9568dx4QvKgz3QpPAbph80IuK5XWN6ToK2IYQQIRhBVmmfOynIfv+nxAQNT7tPDy7+u7ElrZYkBAIl5hJreJTeLZlm0KPiceZFVFI74mnuS0QeI3oasefwuuuBxMCubFwgJxijhZ6WG1h1mV68QzxClNN8g/WPJYE7xNnNHrTfa7T3HCeNlYWxU6PWPIYQnLkCFBRRM11GEjTdUgJe/WMhRw+rJQoO4sZdzfb9T1k8lFJZcaGM0sogGd5oUPxJ38z9rams54TnFyjrw4zvs4EN0DOm3H+TpxnM4pEHoGbozufOMYmPsgvd3VUkfAwA5wedvV1H3gahcYfjIVrvzdFv3by41WSLzOHoEiZZW/Aw4OgYkKeW36nDPWm5tPz5Db45PfD8aHc/1o+p7vAAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAC4jAAAuIwF4pT92AAAAB3RJTUUH5ggZDQYn6iCAVQAAABl0RVh0Q29tbWVudABDcmVhdGVkIHdpdGggR0lNUFeBDhcAAAAXSURBVAjXY2RgYGBgYPj/nwEKmBjQAAA1MQIChEFtIwAAAABJRU5ErkJggg==";

  static int constructing = 0;
  static const String urlPrefix = "ui://";

  late String _id;
  late String _name;
  late String _assetPath;

  final List<PackageItem> _items;
  final Map<String, PackageItem> _itemsById;
  final Map<String, PackageItem> _itemsByName;
  final Map<String, AtlasSprite> _sprites;
  final List<String> _stringTable;
  final List<Map<String, String>> _dependencies;
  List<String> _branches;
  int _branchIndex;

  UIPackage()
      : _branchIndex = -1,
        _items = [],
        _itemsById = {},
        _itemsByName = {},
        _sprites = {},
        _stringTable = [],
        _dependencies = [],
        _branches = [];

  static UIPackage? getById(String id) =>
      _packageInstById.containsKey(id) ? _packageInstById[id] : null;

  static UIPackage? getByName(final String name) =>
      _packageInstByName.containsKey(name) ? _packageInstByName[name] : null;

  static Future<UIPackage?> addPackage(final String assetPath) async {
    if (_packageInstById.containsKey(assetPath)) {
      return _packageInstById[assetPath]!;
    }

    _emptyTexture ??=
        await Flame.images.fromBase64("emptyImage", _emptyTextureData);

    final Uint8List data;
    try {
      data = await rootBundle
          .load('$assetPath.fui')
          .then((value) => value.buffer.asUint8List());
    } catch (e) {
      log("FairyGUI: cannot load package from '$assetPath'");
      return null;
    }

    ByteBuffer buffer = ByteBuffer(data, 0);

    final UIPackage pkg = UIPackage();
    pkg._assetPath = assetPath;
    if (!pkg._loadPackage(buffer)) {
      return null;
    }

    _packageInstById[pkg.id] = pkg;
    _packageInstByName[pkg.name] = pkg;
    _packageInstById[assetPath] = pkg;
    _packageList.add(pkg);

    return pkg;
  }

  static void removePackage(final String packageIdOrName) {
    final UIPackage? pkg = getByName(packageIdOrName);
    if (pkg == null) {
      log('FairyGUI: invalid package name or id: $packageIdOrName');
    } else {
      if (_packageList.contains(pkg)) _packageList.remove(pkg);
      _packageInstById.remove(pkg.id);
      _packageInstById.remove(pkg._assetPath);
      _packageInstByName.remove(pkg.name);
    }
  }

  static void removeAllPackages() {
    _packageInstById.clear();
    _packageInstByName.clear();
    _packageList.clear();
  }

  static GObject? createObject(final String pkgName, final String resName) {
    final UIPackage? pkg = getByName(pkgName);
    if (pkg == null) {
      log('FairyGUI: package not found - $pkgName');
      return null;
    } else {
      return pkg._createObjectFromName(resName);
    }
  }

  static GObject? createObjectFromURL(final String url) {
    PackageItem? pi = getItemAssetByURL(url);
    if (pi == null) {
      log('FairyGUI: resource not found - $url');
      return null;
    } else {
      return pi.owner._createObject(pi);
    }
  }

  static String? getItemURL(final String pkgName, final String resName) {
    final UIPackage? pkg = getByName(pkgName);
    if (pkg != null) {
      final PackageItem? pi = pkg.itemByName(resName);
      if (pi != null) return '$urlPrefix${pkg.id}${pi.id}';
    }
    return null;
  }

  static PackageItem? getItemByURL(final String url) {
    if (url.isEmpty) return null;

    final int pos1 = url.indexOf('/');
    if (pos1 == -1) return null;

    final int pos2 = url.indexOf('/', pos1 + 2);
    if (pos2 == -1) {
      if (url.length > 13) {
        final String pkgId = url.substring(5, 14);
        final UIPackage? pkg = getById(pkgId);
        if (pkg != null) {
          final String srcId = url.substring(13);
          return pkg.item(srcId);
        }
      }
    } else {
      final String pkgName = url.substring(pos1 + 2, pos2);
      final UIPackage? pkg = getByName(pkgName);
      if (pkg != null) {
        final String srcName = url.substring(pos2 + 1);
        return pkg.itemByName(srcName);
      }
    }

    return null;
  }

  static String? normalizeURL(final String url) {
    if (url.isEmpty) return url;

    int pos1 = url.indexOf('/');
    if (pos1 == -1) return url;

    int pos2 = url.indexOf('/', pos1 + 2);
    if (pos2 == -1) {
      return url;
    } else {
      final String pkgName = url.substring(pos1 + 2, pos2);
      final String srcName = url.substring(pos2 + 1);
      return getItemURL(pkgName, srcName);
    }
  }

  static dynamic getItemAsset(final String pkgName, final String resName,
      [PackageItemType type = PackageItemType.unknown]) {
    UIPackage? pkg = getByName(pkgName);
    if (pkg != null) {
      PackageItem? pi = pkg.itemByName(resName);
      if (pi != null) {
        if (type != PackageItemType.unknown && pi.type != type) {
          return null;
        } else {
          return pkg.itemAsset(pi);
        }
      }
    }

    return null;
  }

  static dynamic getItemAssetByURL(final String url,
      [PackageItemType type = PackageItemType.unknown]) {
    PackageItem? pi = getItemByURL(url);
    if (pi == null) {
      return null;
    } else {
      if (type != PackageItemType.unknown && pi.type != type) {
        return null;
      } else {
        return pi.owner.itemAsset(pi);
      }
    }
  }

  static Image getEmptyTexture() => _emptyTexture!;

  static String get branch => _branch;

  static set branch(final String value) {
    _branch = value;
    for (UIPackage pkg in _packageList) {
      if (pkg._branches.isNotEmpty) {
        pkg._branchIndex = pkg._branches.indexOf(value);
      }
    }
  }

  static String? getVar(final String key) =>
      _vars.containsKey(key) ? _vars[key] : null;

  static void setVar(final String key, final String value) =>
      _vars[key] = value;

  AtlasSprite? sprite(String spriteId) =>
      _sprites.containsKey(spriteId) ? _sprites[spriteId] : null;

  Sprite _createSpriteTexture(AtlasSprite spr) {
    itemAsset(spr.atlas);
    Sprite spriteFrame = Sprite(spr.atlas.texture!,
        srcPosition: spr.offset, srcSize: spr.originalSize.toVector2());
    return spriteFrame;
  }

  bool _loadPackage(ByteBuffer buffer) {
    if (buffer.readUInt() != 0x46475549) {
      log("FairyGUI: old package format found in '$_assetPath'");
      return false;
    }

    buffer.version = buffer.readInt();
    bool ver2 = buffer.version >= 2;
    buffer.readBool();
    _id = buffer.readString();
    _name = buffer.readString();
    buffer.skip(20);
    int indexTablePos = buffer.position;
    int cnt;

    buffer.seek(indexTablePos, 4);

    cnt = buffer.readInt();
    _stringTable.length = cnt;
    for (int i = 0; i < cnt; ++i) {
      _stringTable[i] = buffer.readString();
    }
    buffer.stringTable = _stringTable;

    buffer.seek(indexTablePos, 0);
    cnt = buffer.readShort();
    for (int i = 0; i < cnt; ++i) {
      Map<String, String> info = {};
      info['id'] = buffer.readS();
      info['name'] = buffer.readS();
      _dependencies.add(info);
    }

    bool branchIncluded = false;
    if (ver2) {
      cnt = buffer.readShort();
      if (cnt > 0) {
        _branches = buffer.readSArray(cnt);
        if (_branch.isNotEmpty) _branchIndex = _branches.indexOf(_branch);
      }
      branchIncluded = cnt > 0;
    }

    buffer.seek(indexTablePos, 1);

    PackageItem pi;
    String path = _assetPath;
    int pos = path.indexOf('/');
    String shortPath = pos == -1 ? '' : path.substring(0, pos + 1);
    path += '_';

    cnt = buffer.readShort();
    for (int i = 0; i < cnt; ++i) {
      int nextPos = buffer.readInt();
      nextPos += buffer.position;

      pi = PackageItem()
        ..owner = this
        ..type = PackageItemType.values[buffer.readByte()]
        ..id = buffer.readS()
        ..name = buffer.readS();
      buffer.skip(2); // path
      pi.file = buffer.readS();
      buffer.readBool(); // exported
      pi.width = buffer.readInt();
      pi.height = buffer.readInt();

      switch (pi.type) {
        case PackageItemType.image:
          {
            pi.objectType = ObjectType.image;
            int scaleOption = buffer.readByte();
            if (scaleOption == 1) {
              double left = buffer.readInt().toDouble();
              double top = buffer.readInt().toDouble();
              double width = buffer.readInt().toDouble();
              double height = buffer.readInt().toDouble();
              pi.scale9Grid = Rect.fromLTWH(left, top, width, height);
              pi.tileGridIndice = buffer.readInt();
            } else if (scaleOption == 2) {
              pi.scaleByTile = true;
            }
            buffer.readBool(); // smoothing
            break;
          }
        case PackageItemType.movieClip:
          {
            buffer.readBool(); // smoothing
            pi.objectType = ObjectType.movieClip;
            pi.rawData = buffer.readBuffer();
            break;
          }
        case PackageItemType.font:
          {
            pi.rawData = buffer.readBuffer();
            break;
          }
        case PackageItemType.component:
          {
            int extension = buffer.readByte();
            if (extension > 0) {
              pi.objectType = ObjectType.values[extension];
            } else {
              pi.objectType = ObjectType.component;
            }
            pi.rawData = buffer.readBuffer();
            UIObjectFactory.resolvePackageItemExtension(pi);
            break;
          }
        case PackageItemType.atlas:
        case PackageItemType.sound:
        case PackageItemType.misc:
          {
            pi.file = path + pi.file;
            break;
          }

        case PackageItemType.spine:
        case PackageItemType.dragonBones:
          {
            pi.file = shortPath + pi.file;
            pi.skeletonAnchor = Vector2.zero();
            pi.skeletonAnchor.x = buffer.readFloat();
            pi.skeletonAnchor.y = buffer.readFloat();
            break;
          }
        default:
          break;
      }

      if (ver2) {
        String str = buffer.readS();
        if (str.isNotEmpty) pi.name = '$str/${pi.name}';

        int branchCnt = buffer.readUByte();
        if (branchCnt > 0) {
          if (branchIncluded) {
            pi.branches = buffer.readSArray(branchCnt);
          } else {
            _itemsById[buffer.readS()] = pi;
          }
        }

        int highResCnt = buffer.readUByte();
        if (highResCnt > 0) {
          pi.highResolution = buffer.readSArray(highResCnt);
        }
      }

      _items.add(pi);
      _itemsById[pi.id] = pi;
      if (pi.name.isNotEmpty) _itemsByName[pi.name] = pi;

      buffer.position = nextPos;
    }

    buffer.seek(indexTablePos, 2);

    cnt = buffer.readShort();
    for (int i = 0; i < cnt; ++i) {
      int nextPos = buffer.readShort();
      nextPos += buffer.position;

      final String itemId = buffer.readS();
      pi = _itemsById[buffer.readS()]!;

      AtlasSprite sprite = AtlasSprite();
      sprite.atlas = pi;
      // TODO Multiply by scale factor?
      final double left = buffer.readInt().toDouble();
      final double top = buffer.readInt().toDouble();
      final double width = buffer.readInt().toDouble();
      final double height = buffer.readInt().toDouble();
      sprite.rect = Rect.fromLTWH(left, top, width, height);
      sprite.rotated = buffer.readBool();

      if (ver2 && buffer.readBool()) {
        double x = buffer.readInt().toDouble();
        double y = buffer.readInt().toDouble();
        sprite.offset = Vector2(x, y);
        x = buffer.readInt().toDouble();
        y = buffer.readInt().toDouble();
        sprite.originalSize = Size(x, y);
      } else {
        sprite.offset.setZero();
        sprite.originalSize = sprite.rect.size;
      }
      _sprites[itemId] = sprite;

      buffer.position = nextPos;
    }

    if (buffer.seek(indexTablePos, 3)) {
      cnt = buffer.readShort();
      for (int i = 0; i < cnt; ++i) {
        int nextPos = buffer.readInt();
        nextPos += buffer.position;

        PackageItem? pi = _itemsById[buffer.readS()];
        if (pi != null) {
          if (pi.type == PackageItemType.image) {
            pi.pixelHitTestData = PixelHitTestData();
            pi.pixelHitTestData.load(buffer);
          }
        }

        buffer.position = nextPos;
      }
    }

    return true;
  }

  void _loadAtlas(PackageItem item) {
    Image tex = Flame.images.containsKey(item.file)
        ? Flame.images.fromCache(item.file)
        : _emptyTexture!;
    item.texture = tex;
  }

  void _loadImage(PackageItem item) {
    AtlasSprite? spr = sprite(item.id);
    if (spr == null) {
      item.spriteFrame = Sprite(_emptyTexture!);
    } else {
      item.spriteFrame = _createSpriteTexture(spr);
    }
    if (item.scaleByTile) {
      //   TODO Tiled texture
      //   item.spriteFrame.texture;
    }
  }

  void _loadMovieClip(PackageItem item) {
    // TODO load movie clip
  }

  void _loadFont(PackageItem item) {
    item.bitmapFont = BitmapFont();
    // TODO load font
  }

  GObject _createObjectFromName(String resName) {
    PackageItem? pi = itemByName(resName);
    assert(pi != null, 'FairyGUI: resource not found - $resName in $_name');
    return _createObject(pi!);
  }

  GObject? _createObject(PackageItem item) {
    GObject? g = UIObjectFactory.newObject(item);
    if (g == null) return null;

    constructing++;
    g.constructFromResource();
    constructing--;
    return g;
  }

  String get id => _id;

  String get name => _name;

  PackageItem? item(final String itemId) =>
      _itemsById.containsKey(itemId) ? _itemsById[itemId] : null;

  PackageItem? itemByName(final String itemName) =>
      _itemsByName.containsKey(itemName) ? _itemsByName[itemName] : null;

  dynamic itemAsset(PackageItem item) {
    switch (item.type) {
      case PackageItemType.image:
        {
          if (item.spriteFrame == null) _loadImage(item);
          return item.spriteFrame;
        }
      case PackageItemType.atlas:
        {
          if (item.texture == null) _loadAtlas(item);
          return item.texture;
        }
      case PackageItemType.font:
        {
          if (item.bitmapFont == null) _loadFont(item);
          return item.bitmapFont;
        }
      case PackageItemType.movieClip:
        {
          if (item.animation == null) _loadMovieClip(item);
          return item.animation;
        }
      default:
        return null;
    }
  }
}
