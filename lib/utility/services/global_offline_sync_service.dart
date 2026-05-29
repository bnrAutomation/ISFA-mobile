import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

enum SyncDataType {
  campaign,
  markinMarkout,
  feedback,
  // Add more types as needed
}

class GlobalOfflineSyncService {
  static GlobalOfflineSyncService? _instance;
  static GlobalOfflineSyncService get instance {
    _instance ??= GlobalOfflineSyncService._internal();
    return _instance!;
  }
  
  GlobalOfflineSyncService._internal();
  
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  bool _isSyncing = false;
  bool _wasOffline = false;
  
  // Callbacks for different sync types - now includes bySync parameter.
  // Support multiple handlers per type so different modules (e.g. promoter & store detail)
  // can both participate in syncing the same data type.
  final Map<SyncDataType, List<Future<void> Function(bool bySync)>> _syncHandlers = {};
  
  /// Initialize the service
  Future<void> init() async {
    _startConnectivityMonitoring();
  }
  
  /// Register a sync handler for a specific data type.
  /// Multiple handlers can be registered for the same type; all will be invoked.
  void registerSyncHandler(SyncDataType type, Future<void> Function(bool bySync) handler) {
    final list = _syncHandlers[type] ?? <Future<void> Function(bool bySync)>[];
    list.add(handler);
    _syncHandlers[type] = list;
  }
  
  /// Start monitoring connectivity for automatic sync
  void _startConnectivityMonitoring() {
    // Check initial connectivity state
    _connectivity.checkConnectivity().then((result) {
      _wasOffline = result == ConnectivityResult.none;
    });
    
    // Listen for connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (ConnectivityResult result) async {
        final isOnline = result != ConnectivityResult.none;
        
        // Auto sync when transitioning from offline to online
        if (_wasOffline && isOnline && !_isSyncing) {
          _wasOffline = false;
          
          // Small delay to ensure network is stable
          await Future.delayed(const Duration(seconds: 2));
          
          // Double-check we're still online
          final stillOnline = await this.isOnline();
          if (stillOnline) {
            // Run sync in background without blocking
            // Fire and forget - runs in background
            syncAllPendingData(bySync: true).catchError((e) {
              if (kDebugMode) {
                debugPrint('❌ Background sync error: $e');
              }
            });
          }
        } else if (!isOnline) {
          _wasOffline = true;
        }
      },
    );
  }
  
  /// Check if device is online
  Future<bool> isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }
  
  /// Sync all pending data (Campaign + Markin/Markout + others)
  /// bySync: true = auto sync, false = manual sync
  Future<void> syncAllPendingData({bool bySync = false}) async {
    if (_isSyncing) {
      if (kDebugMode) {
        debugPrint('⚠️ Sync already in progress');
      }
      return;
    }
    
    final isConnected = await isOnline();
    if (!isConnected) {
      if (!bySync) {
        if (kDebugMode) {
          debugPrint('⚠️ No internet connection. Cannot sync.');
        }
      }
      return;
    }
    
    _isSyncing = true;
    if (kDebugMode) {
      debugPrint('🔄 Starting ${bySync ? "automatic" : "manual"} sync...');
    }
    
    try {
      // Run sync operations without blocking main thread
      // Use unawaited for auto sync to run in background
      if (bySync) {
        // Auto sync - run in background, don't await
        _performSync(bySync).catchError((e) {
          if (kDebugMode) {
            debugPrint('❌ Background sync error: $e');
          }
        });
      } else {
        // Manual sync - await for user feedback
        await _performSync(bySync);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error during ${bySync ? "automatic" : "manual"} sync: $e');
      }
      _isSyncing = false;
    }
  }
  
  /// Perform actual sync operations
  Future<void> _performSync(bool bySync) async {
    try {
      // Sync campaigns - pass bySync flag
      if (_syncHandlers.containsKey(SyncDataType.campaign)) {
        if (kDebugMode) {
          debugPrint('📋 Syncing campaigns...');
        }
        final handlers = _syncHandlers[SyncDataType.campaign]!;
        for (final handler in handlers) {
          await handler(bySync);
        }
      }
      
      // Sync markin/markout - pass bySync flag
      if (_syncHandlers.containsKey(SyncDataType.markinMarkout)) {
        if (kDebugMode) {
          debugPrint('📍 Syncing markin/markout...');
        }
        final handlers = _syncHandlers[SyncDataType.markinMarkout]!;
        for (final handler in handlers) {
          await handler(bySync);
        }
      }
      
      // Add more sync types as needed
      
      if (kDebugMode) {
        debugPrint('✅ ${bySync ? "Automatic" : "Manual"} sync completed successfully');
      }
    } finally {
      _isSyncing = false;
    }
  }
  
  /// Manual sync trigger (bySync = false)
  Future<void> triggerManualSync() async {
    await syncAllPendingData(bySync: false);
  }
  
  /// Cleanup
  void dispose() {
    _connectivitySubscription?.cancel();
  }
}

