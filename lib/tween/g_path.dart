import 'dart:math';

import 'package:fairygui_flame/tween/g_path_point.dart';
import 'package:flame/extensions.dart';
import 'vector3_extension.dart';

class Segment {
  CurveType? type;
  double? length;
  int? ptStart;
  int? ptCount;
}

class GPath {
  static List<Vector3> _splinePoints = List.empty(growable: true);
  List<Segment> _segments;
  List<Vector3> _points;
  double _fullLength;

  GPath()
      : _fullLength = 0,
        _segments = List.empty(growable: true),
        _points = List.empty(growable: true);

  void create(List<GPathPoint> points) {
    _segments.clear();
    _points.clear();
    _splinePoints.clear();
    _fullLength = 0;

    if (points.isEmpty) return;

    GPathPoint prev = points[0];
    if (prev.curveType == CurveType.crSpline) _splinePoints.add(prev.pos);

    for (int i = 1; i < points.length; ++i) {
      GPathPoint current = points[i];

      if (prev.curveType != CurveType.crSpline) {
        Segment seg = Segment()
          ..type = prev.curveType
          ..ptStart = _points.length;
        if (prev.curveType == CurveType.straight) {
          seg.ptCount = 2;
          _points
            ..add(prev.pos)
            ..add(current.pos);
        } else if (prev.curveType == CurveType.bezier) {
          seg.ptCount = 3;
          _points
            ..add(prev.pos)
            ..add(current.pos)
            ..add(prev.control1);
        } else if (prev.curveType == CurveType.cubicBezier) {
          seg.ptCount = 4;
          _points
            ..add(prev.pos)
            ..add(current.pos)
            ..add(prev.control1)
            ..add(prev.control2);
        }
        seg.length = prev.pos.distanceTo(current.pos);
        _fullLength += seg.length!;
        _segments.add(seg);
      }

      if (current.curveType != CurveType.crSpline) {
        if (_splinePoints.isNotEmpty) {
          _splinePoints.add(current.pos);
          _createSplineSegment();
        }
      } else {
        _splinePoints.add(current.pos);
      }
      prev = current;
    }

    if (_splinePoints.length > 1) _createSplineSegment();
  }

  void _createSplineSegment() {
    int cnt = _splinePoints.length;
    _splinePoints.insert(0, _splinePoints[0]);
    _splinePoints.add(_splinePoints[cnt]);
    _splinePoints.add(_splinePoints[cnt]);
    cnt += 3;

    Segment seg = Segment()
      ..type = CurveType.crSpline
      ..ptStart = _points.length
      ..ptCount = cnt;
    for (Vector3 p in _splinePoints) {
      _points.add(p);
    }

    seg.length = 0;
    for (int i = 1; i < cnt; ++i) {
      seg.length =
          seg.length! + _splinePoints[i - 1].distanceTo(_splinePoints[i]);
    }
    _fullLength += seg.length!;
    _segments.add(seg);
    _splinePoints.clear();
  }

  void clear() {
    _segments.clear();
    _points.clear();
  }

  Vector3 getPointAt(double t) {
    t = t.clamp(0, 1);
    int cnt = _segments.length;
    if (cnt == 0) return Vector3.zero();

    Segment seg;
    if (t == 1) {
      seg = _segments[cnt - 1];

      if (seg.type == CurveType.straight) {
        return _points[seg.ptStart!].lerp(_points[seg.ptStart! + 1], t);
      } else if (seg.type == CurveType.bezier ||
          seg.type == CurveType.cubicBezier) {
        return _onBezierCurve(seg.ptStart!, seg.ptCount!, t);
      } else {
        return _onCRSplineCurve(seg.ptStart!, seg.ptCount!, t);
      }
    }

    double len = t * _fullLength;
    Vector3? pt;
    for (Segment seg in _segments) {
      len -= seg.length!;
      if (len < 0) {
        t = 1 + len / seg.length!;

        if (seg.type == CurveType.straight) {
          pt = _points[seg.ptStart!].lerp(_points[seg.ptStart! + 1], t);
        } else if (seg.type == CurveType.bezier ||
            seg.type == CurveType.cubicBezier) {
          pt = _onBezierCurve(seg.ptStart!, seg.ptCount!, t);
        } else {
          pt = _onCRSplineCurve(seg.ptStart!, seg.ptCount!, t);
        }

        break;
      }
    }

    return pt!;
  }

  double getSegmentLength(int segmentIndex) => _segments[segmentIndex].length!;

  List<Vector3> getPointsInSegment(int segmentIndex, double t0, double t1,
      List<double>? ts, double pointDensity) {
    List<Vector3> points = List.empty(growable: true);
    ts?.add(t0);
    Segment seg = _segments[segmentIndex];

    if (seg.type == CurveType.straight) {
      points.add(_points[seg.ptStart!].lerp(_points[seg.ptStart! + 1], t0));
      points.add(_points[seg.ptStart!].lerp(_points[seg.ptStart! + 1], t1));
    } else if (seg.type == CurveType.bezier ||
        seg.type == CurveType.cubicBezier) {
      points.add(_onBezierCurve(seg.ptStart!, seg.ptCount!, t0));
      int smoothAmount = min(seg.length! * pointDensity, 50.0).floor();

      for (int j = 0; j <= smoothAmount; ++j) {
        double t = j / smoothAmount;
        if (t > t0 && t < t1) {
          points.add(_onBezierCurve(seg.ptStart!, seg.ptCount!, t));
          ts?.add(t);
        }
      }

      points.add(_onBezierCurve(seg.ptStart!, seg.ptCount!, t1));
    } else {
      points.add(_onCRSplineCurve(seg.ptStart!, seg.ptCount!, t0));
      int smoothAmount = min(seg.length! * pointDensity, 50.0).floor();

      for (int j = 0; j <= smoothAmount; ++j) {
        double t = j / smoothAmount;
        if (t > t0 && t < t1) {
          points.add(_onCRSplineCurve(seg.ptStart!, seg.ptCount!, t));
          ts?.add(t);
        }
      }

      points.add(_onCRSplineCurve(seg.ptStart!, seg.ptCount!, t1));
    }

    ts?.add(t1);

    return points;
  }

  List<Vector3> getAllPoints(double pointDensity) {
    List<Vector3> points = List.empty(growable: true);
    int cnt = _segments.length;
    for (int i = 0; i < cnt; ++i) {
      points.addAll(getPointsInSegment(i, 0, 1, null, pointDensity));
    }
    return points;
  }

  static double _repeat(double t, double length) =>
      t - (t / length).floor() * length;

  Vector3 _onCRSplineCurve(int ptStart, int ptCount, double t) {
    int adjustedIndex = (t * (ptCount - 4)).floor() + ptStart;

    Vector3 p0 = _points[adjustedIndex];
    Vector3 p1 = _points[adjustedIndex + 1];
    Vector3 p2 = _points[adjustedIndex + 2];
    Vector3 p3 = _points[adjustedIndex + 3];

    double adjustedT = t == 1.0 ? 1.0 : _repeat(t * (ptCount - 4), 1.0);

    double t0 = ((-adjustedT + 2.0) * adjustedT - 1.0) * adjustedT * 0.5;
    double t1 = ((3.0 * adjustedT - 5.0) * adjustedT * adjustedT + 2.0) * 0.5;
    double t2 = ((-3.0 * adjustedT + 4.0) * adjustedT + 1.0) * adjustedT * 0.5;
    double t3 = (adjustedT - 1.0) * adjustedT * adjustedT * 0.5;

    return Vector3(
        p0.x * t0 + p1.x * t1 + p2.x * t2 + p3.x * t3,
        p0.y * t0 + p1.y * t1 + p2.y * t2 + p3.y * t3,
        p0.z * t0 + p1.z * t1 + p2.z * t2 + p3.z * t3);
  }

  Vector3 _onBezierCurve(int ptStart, int ptCount, double t) {
    double t2 = 1.0 - t;
    Vector3 p0 = _points[ptStart];
    Vector3 p1 = _points[ptStart + 1];
    Vector3 cp0 = _points[ptStart + 2];

    if (ptCount == 4) {
      Vector3 cp1 = _points[ptStart + 3];
      return p0 * (t2 * t2 * t2) +
          cp0 * (3.0 * t2 * t2 * t) +
          cp1 * (3.0 * t2 * t * t) +
          p1 * (t * t * t);
    } else {
      return p0 * (t2 * t2) + cp0 * (2.0 * t2 * t) + p1 * (t * t);
    }
  }
}
