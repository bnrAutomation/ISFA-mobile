import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Utility class for managing BLoC lifecycle and preventing memory leaks
class BlocLifecycleManager {
  static final Map<String, BlocBase> _activeBlocs = {};
  static final Map<String, DateTime> _blocCreationTime = {};

  /// Register a BLoC for lifecycle management
  static void registerBloc(String key, BlocBase bloc) {
    _activeBlocs[key] = bloc;
    _blocCreationTime[key] = DateTime.now();
  }

  /// Unregister a BLoC from lifecycle management
  static void unregisterBloc(String key) {
    _activeBlocs.remove(key);
    _blocCreationTime.remove(key);
  }

  /// Get a registered BLoC
  static T? getBloc<T extends BlocBase>(String key) {
    return _activeBlocs[key] as T?;
  }

  /// Check if a BLoC is registered
  static bool isBlocRegistered(String key) {
    return _activeBlocs.containsKey(key);
  }

  /// Close a specific BLoC
  static Future<void> closeBloc(String key) async {
    final bloc = _activeBlocs[key];
    if (bloc != null && !bloc.isClosed) {
      await bloc.close();
      unregisterBloc(key);
    }
  }

  /// Close all registered BLoCs
  static Future<void> closeAllBlocs() async {
    final futures = <Future<void>>[];
    
    for (final entry in _activeBlocs.entries) {
      if (!entry.value.isClosed) {
        futures.add(entry.value.close());
      }
    }
    
    await Future.wait(futures);
    _activeBlocs.clear();
    _blocCreationTime.clear();
  }

  /// Get memory usage statistics
  static Map<String, dynamic> getMemoryStats() {
    final now = DateTime.now();
    final stats = <String, dynamic>{
      'total_blocs': _activeBlocs.length,
      'bloc_details': <String, dynamic>{},
    };

    for (final entry in _activeBlocs.entries) {
      final creationTime = _blocCreationTime[entry.key];
      final age = creationTime != null 
          ? now.difference(creationTime).inMinutes 
          : 0;
      
      stats['bloc_details'][entry.key] = {
        'type': entry.value.runtimeType.toString(),
        'is_closed': entry.value.isClosed,
        'age_minutes': age,
      };
    }

    return stats;
  }

  /// Clean up old BLoCs (older than specified minutes)
  static Future<void> cleanupOldBlocs({int maxAgeMinutes = 30}) async {
    final now = DateTime.now();
    final keysToRemove = <String>[];

    for (final entry in _blocCreationTime.entries) {
      final age = now.difference(entry.value).inMinutes;
      if (age > maxAgeMinutes) {
        keysToRemove.add(entry.key);
      }
    }

    for (final key in keysToRemove) {
      await closeBloc(key);
    }
  }

  /// Debug method to print BLoC status
  static void printBlocStatus() {
    if (!kDebugMode) return;
    final stats = getMemoryStats();
    debugPrint('=== BLoC Lifecycle Status ===');
    debugPrint('Total BLoCs: ${stats['total_blocs']}');

    for (final entry in stats['bloc_details'].entries) {
      final details = entry.value as Map<String, dynamic>;
      debugPrint(
          '${entry.key}: ${details['type']} (Age: ${details['age_minutes']}min, Closed: ${details['is_closed']})');
    }
    debugPrint('=============================');
  }
}

/// Extension on BuildContext for easy BLoC lifecycle management
extension BlocLifecycleExtension on BuildContext {
  /// Safely read a BLoC with lifecycle management
  T readBloc<T extends BlocBase>(String key) {
    final bloc = BlocLifecycleManager.getBloc<T>(key);
    if (bloc == null) {
      throw Exception('BLoC with key "$key" is not registered');
    }
    return bloc;
  }

  /// Safely watch a BLoC with lifecycle management
  T watchBloc<T extends BlocBase>(String key) {
    return readBloc<T>(key);
  }

  /// Register a BLoC for lifecycle management
  void registerBloc<T extends BlocBase>(String key, T bloc) {
    BlocLifecycleManager.registerBloc(key, bloc);
  }

  /// Unregister a BLoC from lifecycle management
  void unregisterBloc(String key) {
    BlocLifecycleManager.unregisterBloc(key);
  }
}

/// Mixin for widgets that need to manage BLoC lifecycle
mixin BlocLifecycleMixin<T extends StatefulWidget> on State<T> {
  final Set<String> _registeredBlocs = {};

  /// Register a BLoC for automatic cleanup
  void registerBlocForCleanup(String key, BlocBase bloc) {
    BlocLifecycleManager.registerBloc(key, bloc);
    _registeredBlocs.add(key);
  }

  /// Unregister a BLoC from cleanup
  void unregisterBlocFromCleanup(String key) {
    BlocLifecycleManager.unregisterBloc(key);
    _registeredBlocs.remove(key);
  }

  @override
  void dispose() {
    // Clean up all registered BLoCs
    for (final key in _registeredBlocs) {
      BlocLifecycleManager.closeBloc(key);
    }
    _registeredBlocs.clear();
    super.dispose();
  }
}

/// Custom BlocProvider that automatically manages lifecycle
class LifecycleManagedBlocProvider<T extends BlocBase> extends StatelessWidget {
  final String blocKey;
  final T Function() create;
  final Widget child;
  final bool lazy;

  const LifecycleManagedBlocProvider({
    super.key,
    required this.blocKey,
    required this.create,
    required this.child,
    this.lazy = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<T>(
      create: (context) {
        final bloc = create();
        BlocLifecycleManager.registerBloc(blocKey, bloc);
        return bloc;
      },
      lazy: lazy,
      child: child,
    );
  }
}

/// Custom MultiBlocProvider that automatically manages lifecycle
class LifecycleManagedMultiBlocProvider extends StatelessWidget {
  final List<BlocProvider> providers;
  final Widget child;

  const LifecycleManagedMultiBlocProvider({
    super.key,
    required this.providers,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: providers,
      child: child,
    );
  }
}
