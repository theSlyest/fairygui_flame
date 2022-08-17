import 'package:flame/extensions.dart';

extension Vector3Extension on Vector3 {
  /// Linear interpolation between two vectors A and B by alpha which is in the range [0,1]
  Vector3 lerp(Vector3 target, double alpha) {
    return (this * (1.0 - alpha)) + (target * alpha);
  }
}
