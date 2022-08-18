import 'dart:html';

import 'package:flame/input.dart';
import 'package:flutter/services.dart';

class InputEvent {
  // GObject _target;
  // TapDownInfo _touch;
  Vector2 _pos;
  int _touchId;
  int _clickCount;
  int _mouseWheelDelta;
  int _mouseButton;
  LogicalKeyboardKey _keyCode;
  int _keyModifiers;
  // InputProcessor _inputProcessor;

  InputEvent()
      : _pos = Vector2.zero(),
        _touchId = -1,
        _clickCount = 0,
        _mouseWheelDelta = 0,
        _mouseButton = 0,
        _keyCode = LogicalKeyboardKey(0),
        _keyModifiers = 0;

  int get x => _pos.x.floor();
  int get y => _pos.y.floor();
  Vector2 get position => _pos;
  int get touchId => _touchId;
  bool get isDoubleClick => _clickCount == 2;
  int get mouseWheelDelta => _mouseWheelDelta;
}
