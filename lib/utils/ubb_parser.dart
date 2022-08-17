import 'package:flutter/foundation.dart';

class UBBParser {
  static UBBParser? _inst;

  int defaultImgWidth;
  int defaultImgHeight;
  String? lastColor;
  String? lastFontSize;

  @protected
  late Map<String, String Function(String tagName, bool end, String attr)>
      handlers;

  @protected
  late String pString;

  @protected
  int readPos;

  UBBParser? get instance {
    _inst ??= UBBParser();
    return _inst;
  }

  UBBParser()
      : defaultImgWidth = 0,
        defaultImgHeight = 0,
        readPos = 0,
        handlers = {} {
    handlers["urls"] = onTagUrl;
    handlers["img"] = onTagImg;
    handlers["b"] = onTagSimple;
    handlers["i"] = onTagSimple;
    handlers["u"] = onTagSimple;
    handlers["sup"] = onTagSimple;
    handlers["sub"] = onTagSimple;
    handlers["color"] = onTagColor;
    handlers["font"] = onTagFont;
    handlers["size"] = onTagSize;
    handlers["align"] = onTagAlign;
  }

  String parse(String text, [bool remove = false]) {
    readPos = 0;
    lastColor = '';
    lastFontSize = '';
    bool end;
    int pos, start = 0;
    String tag = '', attr = '', repl = '', out = '';
    while (start < text.length) {
      pos = text.indexOf('[', start);
      if (pos == -1) {
        out += text.substring(start);
        break;
      }

      if (pos > 0 && text[pos - 1] == '\\') {
        out += '${text.substring(start, pos - 1)}[';
        start = pos + 1;
        continue;
      }

      out += text.substring(start, pos);
      start = pos;

      pos = text.indexOf(']', start);
      if (pos == -1) {
        out += text.substring(start);
        break;
      }

      if (pos == 1) {
        out += text.substring(start, start + 2);
        start += 2;
        continue;
      }

      end = text[start + 1] == '/';
      if (end) {
        tag = text.substring(start + 2, pos);
      } else {
        tag = text.substring(start + 1, pos);
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
        out += text.substring(start, readPos);
      }
      start = readPos;
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
