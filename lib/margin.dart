final Margin marginZero = Margin();

class Margin {
  /// Left margin.
  double left;

  /// Top margin.
  double top;

  /// Right margin.
  double right;

  /// Bottom margin.
  double bottom;

  /// Default constructor.
  Margin(
      { this.left = 0.0, this.top = 0.0, this.right = 0.0, this.bottom = 0.0 });

  void setMargin({ double? l, t, r, b }) {
    if (l != null) left = l;
    if (t != null) top = t;
    if (r != null) right = r;
    if (b != null) bottom = b;
  }
}