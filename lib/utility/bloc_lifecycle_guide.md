# BLoC Lifecycle Management Guide

This guide explains how to use the improved BLoC lifecycle management system to prevent memory leaks and improve app performance.

## Overview

The BLoC lifecycle management system consists of:

1. **BaseBloc**: A base class that provides automatic resource cleanup
2. **BlocLifecycleManager**: A utility for managing BLoC instances
3. **Mixins**: Specialized mixins for common use cases

## BaseBloc Class

### Features

- **Automatic Timer Management**: All timers are automatically cancelled when the BLoC is closed
- **Stream Subscription Cleanup**: All stream subscriptions are automatically cancelled
- **Stream Controller Management**: All stream controllers are automatically closed
- **Custom Cleanup**: Override `onCleanup()` for custom cleanup logic

### Usage

```dart
class MyBloc extends BaseBloc<MyEvent, MyState> {
  MyBloc() : super(MyInitialState()) {
    // Register event handlers
    on<MyEvent>(_onMyEvent);
  }

  void _onMyEvent(MyEvent event, Emitter<MyState> emit) {
    // Create a timer that will be automatically managed
    createPeriodicTimer(
      Duration(seconds: 1),
      (timer) {
        // Timer logic here
        safeAdd(UpdateEvent());
      },
    );

    // Subscribe to a stream that will be automatically managed
    subscribeToStream(
      someStream,
      (data) {
        // Handle stream data
        safeEmit(NewState(data));
      },
    );
  }

  @override
  Future<void> onCleanup() async {
    // Custom cleanup logic here
    await super.onCleanup();
  }
}
```

## Mixins

### LocationMixin

For BLoCs that need to manage location services:

```dart
class LocationBloc extends BaseBloc<LocationEvent, LocationState> 
    with LocationMixin {
  
  @override
  void startLocationTracking() {
    _locationSubscription = subscribeToStream(
      locationStream,
      (location) {
        safeEmit(LocationUpdatedState(location));
      },
    );
  }
}
```

### ConnectivityMixin

For BLoCs that need to monitor network connectivity:

```dart
class NetworkBloc extends BaseBloc<NetworkEvent, NetworkState> 
    with ConnectivityMixin {
  
  @override
  void startConnectivityMonitoring() {
    _connectivitySubscription = subscribeToStream(
      connectivityStream,
      (connectivity) {
        safeEmit(ConnectivityChangedState(connectivity));
      },
    );
  }
}
```

### PeriodicRefreshMixin

For BLoCs that need periodic data refresh:

```dart
class DataBloc extends BaseBloc<DataEvent, DataState> 
    with PeriodicRefreshMixin {
  
  void startDataRefresh() {
    startPeriodicRefresh(
      interval: Duration(minutes: 5),
      onRefresh: () {
        safeAdd(RefreshDataEvent());
      },
    );
  }
}
```

## BlocLifecycleManager

### Features

- **BLoC Registration**: Register BLoCs for lifecycle management
- **Automatic Cleanup**: Clean up old BLoCs automatically
- **Memory Statistics**: Get memory usage statistics
- **Debug Tools**: Print BLoC status for debugging

### Usage

```dart
// Register a BLoC
BlocLifecycleManager.registerBloc('my_bloc', myBloc);

// Get a registered BLoC
final bloc = BlocLifecycleManager.getBloc<MyBloc>('my_bloc');

// Close a specific BLoC
await BlocLifecycleManager.closeBloc('my_bloc');

// Close all BLoCs
await BlocLifecycleManager.closeAllBlocs();

// Get memory statistics
final stats = BlocLifecycleManager.getMemoryStats();

// Print BLoC status (for debugging)
BlocLifecycleManager.printBlocStatus();
```

## LifecycleManagedBlocProvider

A custom BlocProvider that automatically manages BLoC lifecycle:

```dart
LifecycleManagedBlocProvider<MyBloc>(
  blocKey: 'my_bloc',
  create: () => MyBloc(),
  child: MyWidget(),
)
```

## BlocLifecycleMixin

For widgets that need to manage BLoC lifecycle:

```dart
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> with BlocLifecycleMixin {
  @override
  void initState() {
    super.initState();
    
    // Register a BLoC for automatic cleanup
    final bloc = MyBloc();
    registerBlocForCleanup('my_bloc', bloc);
  }
}
```

## Migration Guide

### Before (Old BLoC)

```dart
class OldBloc extends Bloc<Event, State> {
  Timer? _timer;
  StreamSubscription? _subscription;

  OldBloc() : super(InitialState()) {
    on<Event>(_onEvent);
  }

  void _onEvent(Event event, Emitter<State> emit) {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      // Timer logic
    });
    
    _subscription = someStream.listen((data) {
      // Stream logic
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _subscription?.cancel();
    return super.close();
  }
}
```

### After (New BLoC)

```dart
class NewBloc extends BaseBloc<Event, State> {
  NewBloc() : super(InitialState()) {
    on<Event>(_onEvent);
  }

  void _onEvent(Event event, Emitter<State> emit) {
    // Timer is automatically managed
    createPeriodicTimer(Duration(seconds: 1), (timer) {
      // Timer logic
    });
    
    // Subscription is automatically managed
    subscribeToStream(someStream, (data) {
      // Stream logic
    });
  }
  
  // No need to override close() - it's handled automatically!
}
```

## Best Practices

1. **Always use BaseBloc**: Extend BaseBloc instead of Bloc directly
2. **Use Mixins**: Use appropriate mixins for common functionality
3. **Register BLoCs**: Use BlocLifecycleManager for complex scenarios
4. **Override onCleanup()**: For custom cleanup logic only
5. **Use safeAdd() and safeEmit()**: To prevent operations on closed BLoCs
6. **Monitor Memory**: Use BlocLifecycleManager.getMemoryStats() in debug builds

## Performance Benefits

- **Memory Leak Prevention**: Automatic cleanup prevents memory leaks
- **Resource Management**: Proper disposal of timers, streams, and controllers
- **Better Performance**: Reduced memory usage and improved app stability
- **Debug Tools**: Easy monitoring and debugging of BLoC lifecycle

## Debugging

Use these tools to debug BLoC lifecycle issues:

```dart
// Print current BLoC status
BlocLifecycleManager.printBlocStatus();

// Get detailed memory statistics
final stats = BlocLifecycleManager.getMemoryStats();
print('Active BLoCs: ${stats['total_blocs']}');

// Clean up old BLoCs
await BlocLifecycleManager.cleanupOldBlocs(maxAgeMinutes: 30);
```
