import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:i_densfa/module/beatplan_stores_module/beat_plan_model.dart';
import 'package:i_densfa/module/beatplan_stores_module/beatplan_stores_repository.dart';
import 'package:i_densfa/utility/device_helper.dart';

part 'beatplan_stores_event.dart';
part 'beatplan_stores_state.dart';

class BeatplanStoresBloc
    extends Bloc<BeatplanStoresEvent, BeatplanStoresState> {
  final BeatPlanStoresRepository repo;

  var selectedDate = DateTime.now();
  List<BeatPlanModel> beatPlans = [];
  List<BeatPlanModel> allPlans = [];
  Position? userLocation;

  BeatplanStoresBloc(this.repo) : super(BeatPlanStoresLoadingState()) {
    on((BeatPlanStoresUpdateData event, emit) async {
      emit(BeatPlanStoresLoadingState());
      updateUserLocation();
      allPlans = await repo.getBeatPlans(selectedDate).catchError((onError) {
        emit(BeatPlanSnackBarMessage(onError.toString()));
        return <BeatPlanModel>[];
      });
      beatPlans = allPlans;
      emit(EmptySearchTextBeatplanStoresState());
      emit(BeatPlanStoreLoaded());
    });

    on((BeatPlanStoresDateChangeEvent event, emit) {
      selectedDate = event.date;
      add(BeatPlanStoresUpdateData());
    });

    on((SearchBeatplanStoresEvent event, emit) {
      if (event.searchText.trim().isEmpty) beatPlans = allPlans;
      beatPlans = allPlans
          .where((element) =>
              element.storeName
                  .toLowerCase()
                  .contains(event.searchText.toLowerCase()) ||
              element.storeId.toString().contains(event.searchText))
          .toList();
    });

    on((SortBeatplanStoresEvent event, emit) {
      if (userLocation == null) return;
      beatPlans
          .sort((a, b) => distanceFromStore(a).compareTo(distanceFromStore(b)));
    });
  }

  void updateUserLocation() async {
    try {
      userLocation = await Device().userPosition();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  double distanceFromStore(BeatPlanModel details) {
    if (userLocation == null) {
      return -1;
    } else {
      return Geolocator.distanceBetween(
          details.latitude ?? 0,
          details.longitude ?? 0,
          userLocation!.latitude,
          userLocation!.longitude);
    }
  }

  void onNextDateSelect() {
    final newDate = selectedDate.add(const Duration(days: 1));
    add(BeatPlanStoresDateChangeEvent(newDate));
  }

  void onPreviousDateSelect() {
    final newDate = selectedDate.subtract(const Duration(days: 1));
    add(BeatPlanStoresDateChangeEvent(newDate));
  }
}
