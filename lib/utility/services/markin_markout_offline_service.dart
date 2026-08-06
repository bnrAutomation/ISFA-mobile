import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:image_picker/image_picker.dart';

class MarkinMarkoutOfflineService {
  static const String _queueBoxName = 'markin_markout_queue';
  
  Box? _queueBox;
  final Connectivity _connectivity = Connectivity();
  bool _initialized = false;
  
  Future<void> init() async {
    if (_initialized) return;
    _queueBox = await Hive.openBox(_queueBoxName);
    _initialized = true;
  }
  
  Future<bool> isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }
  
  /// Queue markin/markout for offline submission
  Future<String> queueMarkinMarkout({
    required XFile? imageFile,
    required double latitude,
    required double longitude,
    required int storeId,
    required bool isIn,
    required bool isImage,
    required bool geofence,
    required int distance,
    int? pjpId,
    required String imagePath, // Local path to image
    bool bySync = false, // Add bySync parameter
  }) async {
    if (!_initialized) await init();
    
    final submissionId = DateTime.now().millisecondsSinceEpoch.toString();
    
    final submission = {
      'id': submissionId,
      'storeId': storeId,
      'pjpId': pjpId,
      'latitude': latitude,
      'longitude': longitude,
      'isIn': isIn,
      'isImage': isImage,
      'geofence': geofence,
      'distance': distance,
      'imagePath': imagePath, // Store local path
      'bySync': bySync, // Store bySync flag
      'createdAt': DateTime.now().toIso8601String(),
      'status': 'pending',
      'retryCount': 0,
    };
    
    await _queueBox!.put(submissionId, jsonEncode(submission));
    return submissionId;
  }
  
  /// Get pending markin/markout submissions
  Future<List<Map<String, dynamic>>> getPendingSubmissions() async {
    if (!_initialized) await init();
    
    final allKeys = _queueBox!.keys;
    final List<Map<String, dynamic>> pending = [];
    
    for (var key in allKeys) {
      final submissionJson = _queueBox!.get(key);
      if (submissionJson != null) {
        final submission = jsonDecode(submissionJson) as Map<String, dynamic>;
        if (submission['status'] == 'pending' || submission['status'] == 'failed') {
          pending.add(submission);
        }
      }
    }
    
    pending.sort((a, b) {
      final aTime = DateTime.parse(a['createdAt']);
      final bTime = DateTime.parse(b['createdAt']);
      return aTime.compareTo(bTime);
    });
    
    return pending;
  }
  
  /// Update submission status
  Future<void> updateSubmissionStatus(String submissionId, String status, {String? error}) async {
    if (!_initialized) await init();
    
    final submissionJson = _queueBox!.get(submissionId);
    if (submissionJson != null) {
      final submission = jsonDecode(submissionJson) as Map<String, dynamic>;
      submission['status'] = status;
      if (error != null) {
        submission['error'] = error;
      }
      if (status == 'processing') {
        submission['retryCount'] = (submission['retryCount'] ?? 0) + 1;
      }
      await _queueBox!.put(submissionId, jsonEncode(submission));
    }
  }
  
  /// Remove submission after successful sync
  Future<void> removeSubmission(String submissionId) async {
    if (!_initialized) await init();
    await _queueBox!.delete(submissionId);
  }
  
  /// Get pending count
  int getPendingSubmissionCount() {
    if (!_initialized) return 0;
    
    final allKeys = _queueBox!.keys;
    int count = 0;
    
    for (var key in allKeys) {
      final submissionJson = _queueBox!.get(key);
      if (submissionJson != null) {
        final submission = jsonDecode(submissionJson);
        if (submission['status'] == 'pending' || submission['status'] == 'failed') {
          count++;
        }
      }
    }
    return count;
  }
  
  /// Clear queue
  Future<void> clearQueue() async {
    if (!_initialized) await init();
    await _queueBox!.clear();
  }
}

// Custom exception for offline markin/markout
class OfflineMarkinMarkoutException implements Exception {
  final String message;
  final String submissionId;
  
  OfflineMarkinMarkoutException(this.message, {required this.submissionId});
  
  @override
  String toString() => message;
}

