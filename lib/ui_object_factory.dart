import 'dart:developer';
import 'dart:ffi';

import 'package:fairygui_flame/field_types.dart';
import 'package:fairygui_flame/package_item.dart';
import 'package:fairygui_flame/ui_package.dart';

typedef GComponentCreator = GComponent Function();
typedef GLoaderCreator = GLoader Function();

class UIObjectFactory {
  static Map<String, GComponentCreator> _packageItemExtensions = {};
  static GLoaderCreator? _loaderCreator;

  static void _resolvePackageItemExtension(PackageItem pi) {
    GComponentCreator? ec =
        _packageItemExtensions['${UIPackage.urlPrefix}${pi.owner.id}${pi.id}'];
    if (ec != null) {
      pi.extensionCreator = ec;
      return;
    }

    ec = _packageItemExtensions[
        '${UIPackage.urlPrefix}${pi.owner.name}/${pi.name}'];
    if (ec != null) {
      pi.extensionCreator = ec;
      return;
    }
    pi.extensionCreator = null;
  }

  static void setPackageItemExtension(
      final String url, GComponentCreator creator) {
    if (url.isEmpty) {
      log('Invalid url: $url');
      return;
    }
    PackageItem? pi = UIPackage.getItemByURL(url);
    if (pi != null) pi.extensionCreator = creator;

    _packageItemExtensions[url] = creator;
  }

  static set loaderExtension(GLoaderCreator creator) =>
      _loaderCreator = creator;

  static GObject newObject(PackageItem pi) {
    GObject? obj;
    if (pi.extensionCreator != null) {
      obj = pi.extensionCreator!();
    } else {
      obj = newObjectFromType(pi.objectType);
    }

    if (obj != null) obj._packageItem = pi;

    return obj;
  }

  static GObject? newObjectFromType(ObjectType type) {
    switch (type) {
      case ObjectType.image:
        return GImage.create();

      case ObjectType.movieClip:
        return GMovieClip.create();

      case ObjectType.component:
        return GComponent.create();

      case ObjectType.text:
        return GBasicTextField.create();

      case ObjectType.richText:
        return GRichTextField.create();

      case ObjectType.inputText:
        return GTextInput.create();

      case ObjectType.group:
        return GGroup.create();

      case ObjectType.list:
        return GList.create();

      case ObjectType.graph:
        return GGraph.create();

      case ObjectType.loader:
        if (_loaderCreator != null) {
          return _loaderCreator!();
        } else {
          return GLoader.create();
        }
      case ObjectType.button:
        return GButton.create();

      case ObjectType.label:
        return GLabel.create();

      case ObjectType.progressBar:
        return GProgressBar.create();

      case ObjectType.slider:
        return GSlider.create();

      case ObjectType.scrollBar:
        return GScrollBar.create();

      case ObjectType.comboBox:
        return GComboBox.create();

      case ObjectType.tree:
        return GTree.create();

//    case ObjectType.loader3d:
//        return GLoader3D.create();

      default:
        return null;
    }
  }
}
