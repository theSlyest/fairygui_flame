import 'package:flame/extensions.dart';

class TouchInfo {
  Object? touch;
  Vector2 pos;
  int touchId;
  int clickCount;
  int mouseWheelData;
  int mouseButton;
  Vector2 downPos;
  bool began;
  bool clickCancelled;
  int lastClickTime;
  WeakReference? lastRollOver;
  List<WeakReference> downTargets;
  List<WeakReference> touchMonitors;

  TouchInfo()
      : touch = null,
        touchId = -1,
        clickCount = 0,
        mouseWheelData = 0,
        mouseButton = 0,
        began = false,
        lastClickTime = 0,
        clickCancelled = false,
        pos = Vector2.zero(),
        downPos = Vector2.zero(),
        downTargets = List.empty(growable: true),
        touchMonitors = List.empty(growable: true);

  void reset() {}
}
