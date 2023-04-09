import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_densfa/module/beatplan_stores_module/beat_plan_model.dart';
import 'package:i_densfa/module/beatplan_stores_module/beatplan_stores_repository.dart';

part 'beatplan_stores_event.dart';
part 'beatplan_stores_state.dart';

class BeatplanStoresBloc
    extends Bloc<BeatplanStoresEvent, BeatplanStoresState> {
  final BeatPlanStoresRepository repo;

  var selectedDate = DateTime.now();
  List<BeatPlanModel> beatPlans = [];
  BeatplanStoresBloc(this.repo) : super(BeatPlanStoresLoadingState()) {
    on((BeatPlanStoresUpdateData event, emit) async {
      emit(BeatPlanStoresLoadingState());
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

  void onNextDateSelect() {
    final newDate = selectedDate.add(const Duration(days: 1));
    add(BeatPlanStoresDateChangeEvent(newDate));
  }
}
