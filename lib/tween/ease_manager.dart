import 'dart:math';
import 'package:fairygui_flame/tween/ease_type.dart';
import 'bounce.dart';

class EaseManager {
  static const double _piOver2 = pi * 0.5;
  static const double _twoPi = pi * 2.0;

  static double evaluate(EaseType easeType, double time, double duration,
      double overshootOrAmplitude, double period) {
    switch (easeType) {
      case EaseType.linear:
        return time / duration;

      case EaseType.sineIn:
        return -cos(time / duration * _piOver2) + 1.0;

      case EaseType.sineOut:
        return sin(time / duration * _piOver2);

      case EaseType.sineInOut:
        return -0.5 * (cos(pi * time / duration) - 1.0);

      case EaseType.quadIn:
        {
          time /= duration;
          return time * time;
        }
      case EaseType.quadOut:
        {
          time /= duration;
          return -time * (time - 2.0);
        }
      case EaseType.quadInOut:
        {
          time /= duration * 0.5;
          if (time < 1.0) return 0.5 * time * time;
          --time;
          return -0.5 * (time * (time - 2.0) - 1.0);
        }
      case EaseType.cubicIn:
        {
          time /= duration;
          return time * time * time;
        }
      case EaseType.cubicOut:
        {
          time = time / duration - 1.0;
          return time * time * time + 1.0;
        }
      case EaseType.cubicInOut:
        {
          time /= duration * 0.5;
          if (time < 1) return 0.5 * time * time * time;
          time -= 2.0;
          return 0.5 * (time * time * time + 2.0);
        }
      case EaseType.quartIn:
        {
          time /= duration;
          return time * time * time * time;
        }
      case EaseType.quartOut:
        {
          time = time / duration - 1.0;
          return -(time * time * time * time - 1.0);
        }
      case EaseType.quartInOut:
        {
          time /= duration * 0.5;
          if (time < 1) return 0.5 * time * time * time * time;
          time -= 2.0;
          return -0.5 * (time * time * time * time - 2.0);
        }
      case EaseType.quintIn:
        {
          time /= duration;
          return time * time * time * time * time;
        }
      case EaseType.quintOut:
        {
          time = time / duration - 1.0;
          return (time * time * time * time * time + 1.0);
        }
      case EaseType.quintInOut:
        {
          time /= duration * 0.5;
          if (time < 1.0) return 0.5 * time * time * time * time * time;
          time -= 2.0;
          return 0.5 * (time * time * time * time * time + 2.0);
        }
      case EaseType.expoIn:
        return time == 0.0
            ? 0.0
            : pow(2.0, 10.0 * (time / duration - 1.0)).toDouble();
      case EaseType.expoOut:
        {
          if (time == duration) return 1.0;
          return -pow(2.0, -10.0 * time / duration) + 1.0;
        }
      case EaseType.expoInOut:
        {
          if (time == 0.0) return 0.0;
          if (time == duration) return 1.0;
          if ((time /= duration * 0.5) < 1.0) {
            return 0.5 * pow(2.0, 10.0 * (time - 1.0));
          }
          return 0.5 * (-pow(2.0, -10.0 * --time) + 2.0);
        }
      case EaseType.circIn:
        {
          time /= duration;
          return -(sqrt(1.0 - time * time) - 1.0);
        }
      case EaseType.circOut:
        {
          time = time / duration - 1.0;
          return sqrt(1.0 - time * time);
        }
      case EaseType.circInOut:
        {
          time /= duration * 0.5;
          if (time < 1.0) return -0.5 * (sqrt(1.0 - time * time) - 1.0);
          time -= 2.0;
          return 0.5 * (sqrt(1 - time * time) + 1.0);
        }
      case EaseType.elasticIn:
        {
          double s0;
          if (time == 0.0) return 0.0;
          if ((time /= duration) == 1.0) return 1.0;
          if (period == 0.0) period = duration * 0.3;
          if (overshootOrAmplitude < 1.0) {
            overshootOrAmplitude = 1.0;
            s0 = period / 4.0;
          } else {
            s0 = period / _twoPi * asin(1.0 / overshootOrAmplitude);
          }
          time -= 1;
          return -(overshootOrAmplitude *
              pow(2, 10 * time) *
              sin((time * duration - s0) * _twoPi / period));
        }
      case EaseType.elasticOut:
        {
          double s1;
          if (time == 0.0) return 0.0;
          if ((time /= duration) == 1.0) return 1.0;
          if (period == 0) period = duration * 0.3;
          if (overshootOrAmplitude < 1.0) {
            overshootOrAmplitude = 1.0;
            s1 = period / 4.0;
          } else {
            s1 = period / _twoPi * asin(1 / overshootOrAmplitude);
          }
          return (overshootOrAmplitude *
                  pow(2.0, -10.0 * time) *
                  sin((time * duration - s1) * _twoPi / period) +
              1);
        }
      case EaseType.elasticInOut:
        {
          double s;
          if (time == 0.0) return 0.0;
          if ((time /= duration * 0.5) == 2) return 1.0;
          if (period == 0) period = duration * (0.3 * 1.5);
          if (overshootOrAmplitude < 1.0) {
            overshootOrAmplitude = 1.0;
            s = period / 4.0;
          } else {
            s = period / _twoPi * asin(1.0 / overshootOrAmplitude);
          }
          if (time < 1.0) {
            time -= 1.0;
            return -0.5 *
                (overshootOrAmplitude *
                    pow(2.0, 10.0 * time) *
                    sin((time * duration - s) * _twoPi / period));
          }

          time -= 1;
          return overshootOrAmplitude *
                  pow(2.0, -10.0 * time) *
                  sin((time * duration - s) * _twoPi / period) *
                  0.5 +
              1.0;
        }
      case EaseType.backIn:
        {
          time /= duration;
          return time *
              time *
              ((overshootOrAmplitude + 1.0) * time - overshootOrAmplitude);
        }
      case EaseType.backOut:
        {
          time = time / duration - 1.0;
          return (time *
                  time *
                  ((overshootOrAmplitude + 1.0) * time + overshootOrAmplitude) +
              1.0);
        }
      case EaseType.backInOut:
        {
          time /= duration * 0.5;
          overshootOrAmplitude *= (1.525);
          if (time < 1.0) {
            return 0.5 *
                (time *
                    time *
                    ((overshootOrAmplitude + 1.0) * time -
                        overshootOrAmplitude));
          }
          time -= 2.0;
          return 0.5 *
              (time *
                      time *
                      ((overshootOrAmplitude + 1) * time +
                          overshootOrAmplitude) +
                  2.0);
        }
      case EaseType.bounceIn:
        return Bounce.easeIn(time, duration);

      case EaseType.bounceOut:
        return Bounce.easeOut(time, duration);

      case EaseType.bounceInOut:
        return Bounce.easeInOut(time, duration);

      default:
        {
          time /= duration;
          return -time * (time - 2);
        }
    }
  }
}
