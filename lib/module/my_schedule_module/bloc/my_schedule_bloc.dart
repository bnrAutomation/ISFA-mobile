import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:i_densfa/module/my_schedule_module/beat_plan_model.dart';
import 'package:i_densfa/module/my_schedule_module/my_schedule_repository.dart';
import 'package:i_densfa/module/my_schedule_module/store_list_model.dart';
import 'package:i_densfa/utility/device_helper.dart';
import 'package:i_densfa/utility/extensions.dart';

part 'my_schedule_event.dart';
part 'my_schedule_state.dart';

class MyScheduleBloc extends Bloc<MyScheduleEvent, MyScheduleState> {
  final MyScheduleRepository repo;
  var isAccending = false;
  var selectedDate = DateTime.now();
  List<BeatPlanModel> beatPlans = [];
  List<BeatPlanModel> allPlans = [];
  Position? userLocation;
  List<StoreItemModel> storesList = [];
  StoreItemModel? selectedStore;
  String storeAddRemark = '';
  DateTime? storeAddDate;

  MyScheduleBloc(this.repo) : super(MyScheduleLoadingState()) {
    on((MyScheduleUpdateData event, emit) async {
      emit(MyScheduleLoadingState());
      updateUserLocation();
      allPlans = await repo.getBeatPlans(selectedDate).catchError((onError) {
        emit(MyScheduleSnackBarMessage(onError.toString()));
        return <BeatPlanModel>[];
      });
      isAccending = false;
      beatPlans = allPlans;
      emit(EmptySearchTextMyScheduleState());
      emit(BeatPlanStoreLoaded());
    });

    on((MyScheduleDateChangeEvent event, emit) {
      selectedDate = event.date;
      add(MyScheduleUpdateData());
    });

    on((SearchMyScheduleEvent event, emit) {
      if (event.searchText.trim().isEmpty) beatPlans = allPlans;
      beatPlans = allPlans
          .where((element) =>
              element.storeId.toString().contains(event.searchText) ||
              element.storeName
                  .toLowerCase()
                  .contains(event.searchText.toLowerCase()) ||
              element.pjpId
                  .toString()
                  .toLowerCase()
                  .contains(event.searchText.toLowerCase()))
          .toList();
      emit(BeatPlanStoreLoaded());
    });

    on((SortMyScheduleEvent event, emit) {
      if (userLocation == null) return;
      if (isAccending) {
        isAccending = false;
        beatPlans.sort(
            (a, b) => distanceFromStore(a).compareTo(distanceFromStore(b)));
      } else {
        isAccending = true;
        beatPlans.sort(
            (a, b) => distanceFromStore(b).compareTo(distanceFromStore(a)));
      }
      emit(BeatPlanStoreLoaded());
    });

    on((GetAllStoresListEvent event, emit) async {
      storesList = await repo.getStores().catchError((onError) {
        emit(MyScheduleSnackBarMessage(onError.toString()));
        return <StoreItemModel>[];
      });
      emit(StoreListLoadedState());
    });

    on((AddBeatPlanDateSelected event, emit) {
      storeAddDate = event.date;
      emit(AddBeatPlanDateSelectedState());
    });

    on((BeatPlanAddEvent event, emit) async {
      if (selectedStore == null) {
        emit(MyScheduleSnackBarMessage('Please select store'));
      } else if (storeAddDate == null) {
        emit(MyScheduleSnackBarMessage('Please provide date'));
      } else if (storeAddRemark.trim().isEmpty) {
        emit(MyScheduleSnackBarMessage('Please provide reason'));
      } else {
        emit(BeatPlanUploadLoadingState());
        final success = await repo
            .beatPlanUpload(
                storeAddDate!, storeAddRemark, selectedStore!.storeId)
            .catchError((onError) {
          emit(MyScheduleSnackBarMessage(onError.toString()));
          return false;
        });
        if (success) {
          if (selectedDate.isSameDate(storeAddDate!)) {
            add(MyScheduleUpdateData());
          }
          selectedStore = null;
          storeAddDate = null;
          emit(MyScheduleSnackBarMessage('Successfully added beat plan'));
          emit(BeatPlanUploadSuccess());
        }
      }
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
    add(MyScheduleDateChangeEvent(newDate));
  }

  void onPreviousDateSelect() {
    final newDate = selectedDate.subtract(const Duration(days: 1));
    add(MyScheduleDateChangeEvent(newDate));
  }
}
