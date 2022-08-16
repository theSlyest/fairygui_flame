import 'dart:math';

class FastSplitter {
  final String _data;
  final String _delimiter;
  int _start;
  int _end;

  FastSplitter(final String data, final String delimiter)
      : _data = data,
        _delimiter = delimiter,
        _start = 0,
        _end = -1;

  bool next() {
    if (_data.isEmpty || _end == _data.length) {
      _start == _data.length;
      return false;
    }

    _start = _end + 1;
    _end = _data.indexOf(_delimiter, _start);
    if (_end == -1) _end = _data.length;

    return true;
  }

  String? getText() =>
      _start < _data.length ? _data.substring(_start, _end) : null;

  get textLength => _end - _start;
}
