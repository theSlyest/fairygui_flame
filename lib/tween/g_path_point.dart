import 'package:flame/extensions.dart';

enum CurveType { crSpline, bezier, cubicBezier, straight }

final zero = Vector3.zero();

class GPathPoint {
  Vector3 pos;
  Vector3 control1;
  Vector3 control2;
  CurveType curveType;

  GPathPoint(this.pos, [Vector3? control1, Vector3? control2])
      : control1 = control1 ?? Vector3.zero(),
        control2 = control2 ?? Vector3.zero(),
        curveType = control1 == null
            ? CurveType.crSpline
            : (control2 == null ? CurveType.bezier : CurveType.cubicBezier);

  GPathPoint.fromCurveType(this.pos, this.curveType)
      : control1 = Vector3.zero(),
        control2 = Vector3.zero();
}
