import 'package:flutter/foundation.dart';

abstract class TagHandler {
  String call(String tagName, bool end, String attr);
}

class UBBParser {
  static UBBParser? _inst;

  int defaultImgWidth;
  int defaultImgHeight;
  String? lastColor;
  String? lastFontSize;

  @protected
  late Map<String, TagHandler> handlers;

  @protected
  late String pString;

  @protected
  int readPos;

  UBBParser? get instance => _inst;

  UBBParser()
      : defaultImgWidth = 0,
        defaultImgHeight = 0,
        readPos = 0 {
    handlers["urls"] = onTagUrl as TagHandler;
    handlers["img"] = onTagImg as TagHandler;
    handlers["b"] = onTagSimple as TagHandler;
    handlers["i"] = onTagSimple as TagHandler;
    handlers["u"] = onTagSimple as TagHandler;
    handlers["sup"] = onTagSimple as TagHandler;
    handlers["sub"] = onTagSimple as TagHandler;
    handlers["color"] = onTagColor as TagHandler;
    handlers["font"] = onTagFont as TagHandler;
    handlers["size"] = onTagSize as TagHandler;
    handlers["align"] = onTagAlign as TagHandler;
  }

  String parse(String text, [bool remove = false]) {
    pString = text;
    readPos = 0;
    lastColor = '';
    lastFontSize = '';
    int pos;
    bool end;
    String tag = '', attr = '', repl = '', out = '';
    StringBuffer sb = StringBuffer('');
    while (pString.isNotEmpty) {
      int pos = pString.indexOf('[');
      if (pos == -1) {
        out += pString;
        break;
      }

      if (pos > 0 && pString[pos - 1] == '\\') {
        out += '${pString.substring(pos - 1)}[';
        pString.replaceRange(0, pos + 1, '');
        continue;
      }

      out += pString.substring(pos);
      pString = pString.substring(pos);

      pos = pString.indexOf(']');
      if (pos == -1) {
        out += pString;
        break;
      }

      if (pos == 1) {
        out += pString.substring(0, 2);
        pString = pString.substring(2);
        continue;
      }

      end = pString[1] == '/';
      if (end) {
        tag = pString.substring(2, pos - 2);
      } else {
        tag = pString.substring(1, pos - 1);
      }
      readPos = pos + 1;

      attr = '';
      repl = '';
      pos = tag.indexOf('=');
      if (pos != -1) {
        attr = tag.substring(pos + 1);
        tag = tag.substring(0, pos);
      }
      tag = tag.toLowerCase();
      if (handlers.containsKey(tag)) {
        repl = handlers[tag]!(tag, end, attr);
        if (!remove) out += repl;
      } else {
        out += pString.substring(readPos);
      }
      pString = pString.substring(readPos);
    }

    return out;
  }

  @protected
  String getTagText(bool remove) {
    int pos = pString.indexOf('[', readPos);
    if (pos == -1) return '';

    String res = pString.substring(readPos, pos);
    if (remove) readPos = pos;
    return res;
  }

  @protected
  String onTagUrl(final String tagName, bool end, String attr) {
    if (!end) {
      if (attr.isNotEmpty) {
        return '<a href="$attr" target="_blank">';
      } else {
        String href = getTagText(false);
        return '<a href="$href" target="_blank">';
      }
    } else {
      return '</a>';
    }
  }

  @protected
  String onTagImg(final String tagName, bool end, String attr) {
    if (end) {
      return '';
    } else {
      String src = getTagText(true);
      if (src.isEmpty) return '';

      if (defaultImgWidth != 0) {
        return '<img src="$src" width="$defaultImgWidth" height="$defaultImgHeight"/>';
      } else {
        return '<img src=""/>';
      }
    }
  }

  @protected
  String onTagSimple(final String tagName, bool end, String attr) {
    return end ? '</$tagName>' : '<$tagName>';
  }

  @protected
  String onTagColor(final String tagName, bool end, String attr) {
    if (end) {
      return '</font>';
    } else {
      lastColor = attr;
      return '<font color="$attr">';
    }
  }

  @protected
  String onTagFont(final String tagName, bool end, String attr) {
    return end ? '</font>' : '<font face="$attr">';
  }

  @protected
  String onTagSize(final String tagName, bool end, String attr) {
    if (end) {
      return '</font>';
    } else {
      lastFontSize = attr;
      return '<font size="$attr">';
    }
  }

  @protected
  String onTagAlign(final String tagName, bool end, String attr) {
    return end ? '</p>' : '<p align="$attr">';
  }
}
