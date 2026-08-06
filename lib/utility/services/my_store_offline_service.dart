import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:i_densfa/module/my_schedule_module/beat_plan_model.dart';

class MyStoreOfflineService {
  static const String _beatPlansBoxName = 'beat_plans_cache';

  Box? _beatPlansBox;
  final Connectivity _connectivity = Connectivity();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _beatPlansBox = await Hive.openBox(_beatPlansBoxName);
    _initialized = true;
  }

  Future<bool> isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  /// Cache today's beat plans for offline usage.
  Future<void> cacheBeatPlans(List<BeatPlanModel> plans) async {
    if (!_initialized) await init();
    final jsonList = plans.map((p) => p.toJson()).toList();
    await _beatPlansBox!.put('today', jsonEncode(jsonList));
  }

  /// Get cached beat plans (if any). Returns null if nothing cached.
  Future<List<BeatPlanModel>?> getCachedBeatPlans() async {
    if (!_initialized) await init();
    final cached = _beatPlansBox!.get('today');
    if (cached == null) return null;
    final List<dynamic> jsonList = jsonDecode(cached);
    return jsonList.map((e) => BeatPlanModel.fromJson(e)).toList();
  }
}

