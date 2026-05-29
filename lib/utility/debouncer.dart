import 'dart:async';
import 'dart:ui';

class Debouncer {
  Duration duration;
  Timer? _timer;

  Debouncer({this.duration = const Duration(milliseconds: 500)});

  run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }
}
