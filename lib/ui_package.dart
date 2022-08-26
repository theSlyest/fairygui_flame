import 'dart:developer';

import 'package:fairygui_flame/field_types.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/services.dart';

class AtlasSprite {
  late PackageItem atlas;
  Rect rect = Rect.zero;
  Vector2 originalSize = Vector2.zero();
  Vector2 offset = Vector2.zero();
  bool rotated = false;
}

class UIPackage {
  static final Map<String, UIPackage> _packageInstById = {};
  static final Map<String, UIPackage> _packageInstByName = {};
  static final List<PackageItem> _packageList = <PackageItem>[];
  static final Map<String, String> _vars = {};
  static String _branch = "";

  static Image? _emptyTexture;
  static const String _emptyTextureData =
      "iVBORw0KGgoAAAANSUhEUgAAAAIAAAACEAYAAAAiJtFnAAABg2lDQ1BJQ0MgcHJvZmlsZQAAKJF1kT1Iw1AUhU//aIcWO4ioOGSoThakirhahSJUCbVCFZfkpbaFJg0vKV0cBdeCg+ji3+LopIuDg6uToAjiKO6ii5Z4XyK2SPMguV8O9568dx4QvKgz3QpPAbph80IuK5XWN6ToK2IYQQIRhBVmmfOynIfv+nxAQNT7tPDy7+u7ElrZYkBAIl5hJreJTeLZlm0KPiceZFVFI74mnuS0QeI3oasefwuuuBxMCubFwgJxijhZ6WG1h1mV68QzxClNN8g/WPJYE7xNnNHrTfa7T3HCeNlYWxU6PWPIYQnLkCFBRRM11GEjTdUgJe/WMhRw+rJQoO4sZdzfb9T1k8lFJZcaGM0sogGd5oUPxJ38z9rams54TnFyjrw4zvs4EN0DOm3H+TpxnM4pEHoGbozufOMYmPsgvd3VUkfAwA5wedvV1H3gahcYfjIVrvzdFv3by41WSLzOHoEiZZW/Aw4OgYkKeW36nDPWm5tPz5Db45PfD8aHc/1o+p7vAAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAC4jAAAuIwF4pT92AAAAB3RJTUUH5ggZDQYn6iCAVQAAABl0RVh0Q29tbWVudABDcmVhdGVkIHdpdGggR0lNUFeBDhcAAAAXSURBVAjXY2RgYGBgYPj/nwEKmBjQAAA1MQIChEFtIwAAAABJRU5ErkJggg==";

  static int constructing = 0;
  static const String urlPrefix = "ui://";

  late String _id;
  late String _name;
  String? _assetPath;

  List<PackageItem> _items;
  Map<String, PackageItem> _itemsById;
  Map<String, PackageItem> _itemsByName;
  Map<String, AtlasSprite> _sprites;
  String? _customId;
  List<String> _stringTable;
  Map<String, String> _dependencies;
  int _branchIndex;

  UIPackage()
      : _branchIndex = -1,
        _items = <PackageItem>[],
        _itemsById = {},
        _itemsByName = {},
        _sprites = {},
        _stringTable = <String>[],
        _dependencies = {};

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

    final String data;
    try {
      data = await rootBundle.loadString('$assetPath.fui');
    } catch (e) {
      log("FairyGUI: cannot load package from '$assetPath'");
      return null;
    }

    final UIPackage pkg = UIPackage();
    pkg._assetPath = assetPath;
    if (!pkg._loadPackage(data)) {
      return null;
    }

    _packageInstById[pkg.getId()] = pkg;
    _packageInstByName[pkg.getName()] = pkg;
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
      _packageInstById.remove(pkg.getId());
      _packageInstById.remove(pkg._assetPath);
      _packageInstByName.remove(pkg.getName());
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
      return pkg._createObject(resName);
    }
  }

  static GObject? createObjectFromURL(final String url) {
    PackageItem? pi = getItemAssetByURL(url);
    if (pi == null) {
      log('FairyGUI: resource not found - $url');
      return null;
    } else {
      return pi.owner.createObject(pi);
    }
  }

  static String? getItemURL(final String pkgName, final String resName) {
    final UIPackage? pkg = getByName(pkgName);
    if (pkg != null) {
      final PackageItem? pi = pkg.itemByName(resName);
      if (pi != null) return '$urlPrefix${pkg.getId()}${pi.id}';
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
          return pkg.getItem(srcId);
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

  static Object? getItemAsset(final String pkgName, final String resName,
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

  static Object? getItemAssetByURL(final String url,
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
    for (PackageItem pi in _packageList) {
      if (pi._branches.isNotEmpty) {
        pi._branchIndex = pi._branches.indexOf(value);
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
    Sprite spriteFrame = Sprite(spr.atlas.texture,
        srcPosition: spr.offset, srcSize: spr.originalSize);
    return spriteFrame;
  }

  bool _loadPackage(String buffer) {
    return false;
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

  void _loadMovieClip(PackageItem item) {}

  void _loadFont(PackageItem item) {
    item.bitmapFont = BitmapFont();
  }

  GObject _createObjectFromName(String resName) {
    PackageItem? pi = itemByName(resName);
    assert(pi != null, 'FairyGUI: resource not found - $resName in $_name');
    return _createObject(pi);
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

  Object? itemAsset(PackageItem item) {
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
