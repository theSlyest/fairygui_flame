class Bounce {
  static double easeIn(double time, double duration) =>
      1.0 - easeOut(duration - time, duration);

  static double easeOut(double time, double duration) {
    time /= duration;
    if (time < (1 / 2.75)) {
      return 7.5625 * time * time;
    }
    if (time < 2 / 2.75) {
      time -= 1.5 / 2.75;
      return 7.5625 * time * time + 0.75;
    }
    if (time < 2.5 / 2.75) {
      time -= 2.25 / 2.75;
      return 7.5625 * time * time + 0.9375;
    }
    time -= 2.625 / 2.75;
    return 7.5625 * time * time + 0.984375;
  }

  static double easeInOut(double time, double duration) {
    if (time < duration * 0.5) {
      return easeIn(time * 2, duration) * 0.5;
    }
    return easeOut(time * 2 - duration, duration) * 0.5 + 0.5;
  }
}
