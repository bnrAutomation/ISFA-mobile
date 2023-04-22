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
  Position? userLocation;

  BeatplanStoresBloc(this.repo) : super(BeatPlanStoresLoadingState()) {
    on((BeatPlanStoresUpdateData event, emit) async {
      emit(BeatPlanStoresLoadingState());
      userLocation = await Device().userPosition();
      beatPlans = await repo.getBeatPlans(selectedDate).catchError((onError) {
        emit(BeatPlanSnackBarMessage(onError.toString()));
        return <BeatPlanModel>[];
      });
      emit(BeatPlanStoreLoaded());
    });

    on((BeatPlanStoresDateChangeEvent event, emit) {
      selectedDate = event.date;
      add(BeatPlanStoresUpdateData());
    });
  }

  void onPreviousDateSelect() {
    final newDate = selectedDate.subtract(const Duration(days: 1));
    add(BeatPlanStoresDateChangeEvent(newDate));
  }

  double distanceFromStore(BeatPlanModel details) {
    if (userLocation != null) {
      return Geolocator.distanceBetween(
          details.latitude ?? 0,
          details.longitude ?? 0,
          userLocation!.latitude,
          userLocation!.longitude);
    } else {
      return 10000;
    }
  }

  void onNextDateSelect() {
    final newDate = selectedDate.add(const Duration(days: 1));
    add(BeatPlanStoresDateChangeEvent(newDate));
  }
}
