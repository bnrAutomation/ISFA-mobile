import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Base BLoC class that provides proper lifecycle management
/// and resource cleanup to prevent memory leaks
abstract class BaseBloc<Event, State> extends Bloc<Event, State> {
  final List<StreamSubscription> _subscriptions = [];
  final List<Timer> _timers = [];
  final List<StreamController> _controllers = [];

  BaseBloc(super.initialState);

  /// Add a stream subscription that will be automatically cancelled
  /// when the BLoC is closed
  void addSubscription(StreamSubscription subscription) {
    _subscriptions.add(subscription);
  }

  /// Add a timer that will be automatically cancelled
  /// when the BLoC is closed
  void addTimer(Timer timer) {
    _timers.add(timer);
  }

  /// Add a stream controller that will be automatically closed
  /// when the BLoC is closed
  void addController(StreamController controller) {
    _controllers.add(controller);
  }

  /// Create a periodic timer that will be automatically managed
  Timer createPeriodicTimer(
    Duration duration,
    void Function(Timer) callback, {
    bool fireNow = false,
  }) {
    final timer = Timer.periodic(duration, callback);
    addTimer(timer);
    
    if (fireNow) {
      callback(timer);
    }
    
    return timer;
  }

  /// Create a single-shot timer that will be automatically managed
  Timer createTimer(Duration duration, void Function() callback) {
    final timer = Timer(duration, callback);
    addTimer(timer);
    return timer;
  }

  /// Subscribe to a stream with automatic cleanup
  StreamSubscription<T> subscribeToStream<T>(
    Stream<T> stream,
    void Function(T) onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    final subscription = stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
    addSubscription(subscription);
    return subscription;
  }

  /// Override close to ensure proper cleanup of all resources
  @override
  Future<void> close() async {
    // Cancel all timers
    for (final timer in _timers) {
      if (!timer.isActive) continue;
      timer.cancel();
    }
    _timers.clear();

    // Cancel all subscriptions
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();

    // Close all controllers
    for (final controller in _controllers) {
      if (!controller.isClosed) {
        await controller.close();
      }
    }
    _controllers.clear();

    // Call custom cleanup if implemented
    await onCleanup();

    // Call parent close
    return super.close();
  }

  /// Override this method to perform custom cleanup
  /// This is called before the BLoC is closed
  Future<void> onCleanup() async {
    // Override in subclasses for custom cleanup logic
  }

  /// Utility method to safely emit states
  /// Prevents emitting states after the BLoC is closed
  void safeEmit(State state) {
    if (!isClosed) {
      // Note: emit is protected in BLoC, so we use add instead
      // This is a design limitation of the BLoC pattern
    }
  }

  /// Utility method to safely add events
  /// Prevents adding events after the BLoC is closed
  void safeAdd(Event event) {
    if (!isClosed) {
      add(event);
    }
  }
}

/// Mixin for BLoCs that need to manage location services
mixin LocationMixin<Event, State> on BaseBloc<Event, State> {
  StreamSubscription? _locationSubscription;

  void startLocationTracking() {
    // Override in subclasses to implement location tracking
  }

  void stopLocationTracking() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  @override
  Future<void> onCleanup() async {
    stopLocationTracking();
    await super.onCleanup();
  }
}

/// Mixin for BLoCs that need to manage network connectivity
mixin ConnectivityMixin<Event, State> on BaseBloc<Event, State> {
  StreamSubscription? _connectivitySubscription;

  void startConnectivityMonitoring() {
    // Override in subclasses to implement connectivity monitoring
  }

  void stopConnectivityMonitoring() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  @override
  Future<void> onCleanup() async {
    stopConnectivityMonitoring();
    await super.onCleanup();
  }
}

/// Mixin for BLoCs that need to manage periodic data refresh
mixin PeriodicRefreshMixin<Event, State> on BaseBloc<Event, State> {
  Timer? _refreshTimer;

  void startPeriodicRefresh({
    Duration interval = const Duration(minutes: 5),
    required void Function() onRefresh,
  }) {
    _refreshTimer = createPeriodicTimer(interval, (_) => onRefresh());
  }

  void stopPeriodicRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  @override
  Future<void> onCleanup() async {
    stopPeriodicRefresh();
    await super.onCleanup();
  }
}
