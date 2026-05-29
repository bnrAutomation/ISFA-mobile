import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:i_densfa/module/campaign_module/new_models/campaign.dart';
import 'package:i_densfa/module/campaign_module/new_models/question.dart';
import 'package:i_densfa/module/campaign_module/new_models/question_section.dart';
import 'package:i_densfa/module/campaign_module/new_models/response_model.dart';

class CampaignOfflineService {
  static const String _campaignsBoxName = 'campaigns_cache';
  static const String _sectionsBoxName = 'campaign_sections_cache';
  static const String _questionsBoxName = 'campaign_questions_cache';
  static const String _submissionsQueueBoxName = 'campaign_submissions_queue';
  static const String _filledCampaignsBoxName = 'filled_campaigns_cache';
  static const String _mechanicsBoxName = 'campaign_mechanics_cache';
  static const String _recruitersBoxName = 'campaign_recruiters_cache';
  static const String _productsBoxName = 'campaign_products_cache';
  static const String _storeVisitBoxName = 'campaign_store_visit_cache';
  
  Box? _campaignsBox;
  Box? _sectionsBox;
  Box? _questionsBox;
  Box? _submissionsQueueBox;
  Box? _filledCampaignsBox;
  Box? _mechanicsBox;
  Box? _recruitersBox;
  Box? _productsBox;
  Box? _storeVisitBox;
  
  final Connectivity _connectivity = Connectivity();
  bool _initialized = false;
  
  Future<void> init() async {
    if (_initialized) return;
    
    _campaignsBox = await Hive.openBox(_campaignsBoxName);
    _sectionsBox = await Hive.openBox(_sectionsBoxName);
    _questionsBox = await Hive.openBox(_questionsBoxName);
    _submissionsQueueBox = await Hive.openBox(_submissionsQueueBoxName);
    _filledCampaignsBox = await Hive.openBox(_filledCampaignsBoxName);
    _mechanicsBox = await Hive.openBox(_mechanicsBoxName);
    _recruitersBox = await Hive.openBox(_recruitersBoxName);
    _productsBox = await Hive.openBox(_productsBoxName);
    _storeVisitBox = await Hive.openBox(_storeVisitBoxName);
    _initialized = true;
  }
  
  Future<bool> isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }
  
  // ========== CACHE METHODS ==========
  
  Future<void> cacheCampaignsForStore(String storeId, List<AllCampaignModel> campaigns) async {
    if (!_initialized) await init();
    final key = 'campaigns_$storeId';
    final jsonList = campaigns.map((c) => c.toJson()).toList();
    await _campaignsBox!.put(key, jsonEncode(jsonList));
    await _campaignsBox!.put('${key}_timestamp', DateTime.now().toIso8601String());
  }
  
  Future<List<AllCampaignModel>?> getCachedCampaignsForStore(String storeId) async {
    if (!_initialized) await init();
    final key = 'campaigns_$storeId';
    final cached = _campaignsBox!.get(key);
    if (cached == null) return null;
    
    final timestampStr = _campaignsBox!.get('${key}_timestamp');
    if (timestampStr != null) {
      final timestamp = DateTime.parse(timestampStr);
      // Cache valid for 24 hours
      if (DateTime.now().difference(timestamp).inHours > 24) {
        await _campaignsBox!.delete(key);
        await _campaignsBox!.delete('${key}_timestamp');
        return null;
      }
    }
    
    final List<dynamic> jsonList = jsonDecode(cached);
    return jsonList.map((e) => AllCampaignModel.fromJson(e)).toList();
  }
  
  Future<void> cacheSections(String campaignUuid, List<CampaignQuestionSectionModel> sections) async {
    if (!_initialized) await init();
    final key = 'sections_$campaignUuid';
    final jsonList = sections.map((s) => s.toJson()).toList();
    await _sectionsBox!.put(key, jsonEncode(jsonList));
  }
  
  Future<List<CampaignQuestionSectionModel>?> getCachedSections(String campaignUuid) async {
    if (!_initialized) await init();
    final key = 'sections_$campaignUuid';
    final cached = _sectionsBox!.get(key);
    if (cached == null) return null;
    
    final List<dynamic> jsonList = jsonDecode(cached);
    return jsonList.map((e) => CampaignQuestionSectionModel.fromJson(e)).toList();
  }
  
  Future<void> cacheQuestions(String campaignUuid, String sectionUuid, List<CampaignQuestionModel> questions) async {
    if (!_initialized) await init();
    final key = 'questions_${campaignUuid}_$sectionUuid';
    final jsonList = questions.map((q) => q.toJson()).toList();
    await _questionsBox!.put(key, jsonEncode(jsonList));
  }
  
  Future<List<CampaignQuestionModel>?> getCachedQuestions(String campaignUuid, String sectionUuid) async {
    if (!_initialized) await init();
    final key = 'questions_${campaignUuid}_$sectionUuid';
    final cached = _questionsBox!.get(key);
    if (cached == null) return null;
    
    final List<dynamic> jsonList = jsonDecode(cached);
    return jsonList.map((e) => CampaignQuestionModel.fromJson(e)).toList();
  }
  
  Future<void> cacheFilledCampaigns(String storeId, List<String> filledCampaigns) async {
    if (!_initialized) await init();
    final key = 'filled_$storeId';
    await _filledCampaignsBox!.put(key, filledCampaigns);
  }
  
  Future<List<String>?> getCachedFilledCampaigns(String storeId) async {
    if (!_initialized) await init();
    final key = 'filled_$storeId';
    final cached = _filledCampaignsBox!.get(key);
    return cached != null ? List<String>.from(cached) : null;
  }
  
  // Mechanics cache (global for user – not per store)
  Future<void> cacheMechanics(List<MechanicModel> mechanics) async {
    if (!_initialized) await init();
    final jsonList = mechanics.map((m) => m.toJson()).toList();
    await _mechanicsBox!.put('mechanics', jsonEncode(jsonList));
  }

  Future<List<MechanicModel>?> getCachedMechanics() async {
    if (!_initialized) await init();
    final cached = _mechanicsBox!.get('mechanics');
    if (cached == null) return null;
    final List<dynamic> jsonList = jsonDecode(cached);
    return jsonList.map((e) => MechanicModel.fromJson(e)).toList();
  }

  // Recruiters cache (global for user)
  Future<void> cacheRecruiters(List<RecruiterModel> recruiters) async {
    if (!_initialized) await init();
    final jsonList = recruiters.map((r) => r.toJson()).toList();
    await _recruitersBox!.put('recruiters', jsonEncode(jsonList));
  }

  Future<List<RecruiterModel>?> getCachedRecruiters() async {
    if (!_initialized) await init();
    final cached = _recruitersBox!.get('recruiters');
    if (cached == null) return null;
    final List<dynamic> jsonList = jsonDecode(cached);
    return jsonList.map((e) => RecruiterModel.fromJson(e)).toList();
  }

  // Product list cache per sub-segment type
  Future<void> cacheProducts(String type, List<ProductInfo> products) async {
    if (!_initialized) await init();
    final jsonList = products.map((p) => p.toJson()).toList();
    await _productsBox!.put('products_$type', jsonEncode(jsonList));
  }

  Future<List<ProductInfo>?> getCachedProductInfos(String type) async {
    if (!_initialized) await init();
    final cached = _productsBox!.get('products_$type');
    if (cached == null) return null;

    // Backward compatibility: older app versions stored List<String> directly.
    if (cached is List) return null;

    if (cached is String) {
      try {
        final decoded = jsonDecode(cached);
        if (decoded is List) {
          return decoded
              .map((e) => ProductInfo.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      } catch (_) {
        return null;
      }
    }

    if (cached is Map) {
      // Defensive: handle unexpected single-object storage
      try {
        return [ProductInfo.fromJson(Map<String, dynamic>.from(cached))];
      } catch (_) {
        return null;
      }
    }

    return null;
  }

  Future<List<ProductInfo>?> getCachedProducts(String type) async {
    if (!_initialized) await init();
    final cached = _productsBox!.get('products_$type');
    if (cached == null) return null;

    // Backward compatibility: older app versions stored List<String> directly.
    if (cached is List) {
      return List<ProductInfo>.from(cached);
    }

    // New format: List<ProductInfo> stored as JSON string.
    if (cached is String) {
      try {
        final decoded = jsonDecode(cached);
        if (decoded is! List) return null;
        final infos = decoded
            .map((e) => ProductInfo.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        // For existing usage (product name options), return productSeries list.
        return infos;
           
      } catch (_) {
        return null;
      }
    }

    // Defensive: if a Map was stored, try decoding it.
    if (cached is Map) {
      try {
        final info = ProductInfo.fromJson(Map<String, dynamic>.from(cached));
      //  final series = (info.productSeries ?? '').trim();
        return  <ProductInfo>[info];
      } catch (_) {
        return null;
      }
    }

    return null;
  }
  
  // ========== OFFLINE QUEUE METHODS ==========
  
  // Store visit status cache (per store per day)
  Future<void> cacheStoreVisitStatus(int storeId, DateTime date, bool visited) async {
    if (!_initialized) await init();
    final key = _storeVisitKey(storeId, date);
    await _storeVisitBox!.put(key, visited);
  }

  Future<bool?> getCachedStoreVisitStatus(int storeId, DateTime date) async {
    if (!_initialized) await init();
    final key = _storeVisitKey(storeId, date);
    final value = _storeVisitBox!.get(key);
    if (value == null) return null;
    return value as bool;
  }

  String _storeVisitKey(int storeId, DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '${storeId}_$y-$m-$d';
  }

  // ========== OFFLINE QUEUE METHODS ==========
  
  Future<String> queueSubmission({
    required Map<String, dynamic> requestBody,
    required String campaignUuid,
    required int storeId,
    Map<String, dynamic>? masterData,
    Map<String, dynamic>? mechanicData,
    Map<String, dynamic>? retailerVisitData,
    List<dynamic>? segmentData,
  }) async {
    if (!_initialized) await init();
    final submissionId = DateTime.now().millisecondsSinceEpoch.toString();
    
    final submission = {
      'id': submissionId,
      'campaignUuid': campaignUuid,
      'storeId': storeId,
      'requestBody': requestBody,
      'masterData': masterData,
      'mechanicData': mechanicData,
      'retailerVisitData': retailerVisitData,
      'segmentData': segmentData,
      'createdAt': DateTime.now().toIso8601String(),
      'status': 'pending',
      'retryCount': 0,
    };
    
    await _submissionsQueueBox!.put(submissionId, jsonEncode(submission));
    return submissionId;
  }
  
  Future<List<Map<String, dynamic>>> getPendingSubmissions() async {
    if (!_initialized) await init();
    final allKeys = _submissionsQueueBox!.keys;
    final List<Map<String, dynamic>> pending = [];
    
    for (var key in allKeys) {
      final submissionJson = _submissionsQueueBox!.get(key);
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
  
  Future<void> updateSubmissionStatus(String submissionId, String status, {String? error}) async {
    if (!_initialized) await init();
    final submissionJson = _submissionsQueueBox!.get(submissionId);
    if (submissionJson != null) {
      final submission = jsonDecode(submissionJson) as Map<String, dynamic>;
      submission['status'] = status;
      if (error != null) {
        submission['error'] = error;
      }
      if (status == 'processing') {
        submission['retryCount'] = (submission['retryCount'] ?? 0) + 1;
      }
      await _submissionsQueueBox!.put(submissionId, jsonEncode(submission));
    }
  }
  
  Future<void> removeSubmission(String submissionId) async {
    if (!_initialized) await init();
    await _submissionsQueueBox!.delete(submissionId);
  }
  
  Future<void> updateSubmission({
    required String submissionId,
    Map<String, dynamic>? masterData,
    Map<String, dynamic>? mechanicData,
    Map<String, dynamic>? retailerVisitData,
    List<dynamic>? segmentData,
  }) async {
    if (!_initialized) await init();
    final submissionJson = _submissionsQueueBox!.get(submissionId);
    if (submissionJson != null) {
      final submission = jsonDecode(submissionJson) as Map<String, dynamic>;
      if (masterData != null) submission['masterData'] = masterData;
      if (mechanicData != null) submission['mechanicData'] = mechanicData;
      if (retailerVisitData != null) submission['retailerVisitData'] = retailerVisitData;
      if (segmentData != null) submission['segmentData'] = segmentData;
      await _submissionsQueueBox!.put(submissionId, jsonEncode(submission));
    }
  }
  
  int getPendingSubmissionCount() {
    if (!_initialized) return 0;
    final allKeys = _submissionsQueueBox!.keys;
    int count = 0;
    for (var key in allKeys) {
      final submissionJson = _submissionsQueueBox!.get(key);
      if (submissionJson != null) {
        final submission = jsonDecode(submissionJson);
        if (submission['status'] == 'pending' || submission['status'] == 'failed') {
          count++;
        }
      }
    }
    return count;
  }
  
  Future<void> clearCache() async {
    if (!_initialized) await init();
    await _campaignsBox!.clear();
    await _sectionsBox!.clear();
    await _questionsBox!.clear();
    await _filledCampaignsBox!.clear();
    await _mechanicsBox!.clear();
    await _recruitersBox!.clear();
    await _productsBox!.clear();
    await _storeVisitBox!.clear();
  }
  
  Future<void> clearSubmissionQueue() async {
    if (!_initialized) await init();
    await _submissionsQueueBox!.clear();
  }
}



