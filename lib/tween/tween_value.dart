import 'package:flame/extensions.dart';

class TweenValue {
  double x;
  double y;
  double z;
  double w;
  double d;

  TweenValue()
      : x = 0,
        y = 0,
        z = 0,
        w = 0,
        d = 0;

  Vector2 get vector2 => Vector2(x, y);
  set vector2(Vector2 value) {
    x = value.x;
    y = value.y;
  }

  Vector3 get vector3 => Vector3(x, y, z);
  set vector3(Vector3 value) {
    x = value.x;
    y = value.y;
    z = value.z;
  }

  Vector4 get vector4 => Vector4(x, y, z, w);
  set vector4(Vector4 value) {
    x = value.x;
    y = value.y;
    z = value.z;
    w = value.w;
  }

  Color get color => Color.fromARGB(w.floor(), x.floor(), y.floor(), z.floor());
  set color(Color value) {
    x = value.red.toDouble();
    y = value.green.toDouble();
    z = value.blue.toDouble();
    w = value.alpha.toDouble();
  }

  /// Access the component of the vector at the index [i].
  double operator [](int index) {
    switch (index) {
      case 0:
        return x;
      case 1:
        return y;
      case 2:
        return z;
      case 3:
        return w;
      default:
        throw IndexError(index, this);
    }
  }

  void setZero() => x = y = z = w = d = 0;
}
