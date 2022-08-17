class EventContext {
  Object? _sender;
  InputEvent? _inputEvent;
  Object? _value;
  Object? _dataValue;
  String? _data;
  bool _isStopped;
  bool _defaultPrevented;
  int _touchCapture;
  int _type;

  EventContext()
      : _sender = null,
        _data = null,
        _inputEvent = null,
        _isStopped = false,
        _defaultPrevented = false,
        _touchCapture = 0,
        _type = 0;

  int get type => _type;

  Object? get sender => _sender;

  InputEvent? get input => _inputEvent;

  void stopPropagation() => _isStopped = true;

  void preventDefault() => _defaultPrevented = true;

  bool get isDefaultPrevented => _defaultPrevented;

  void captureTouch() => _touchCapture = 1;

  void uncaptureTouch() => _touchCapture = 2;
}
