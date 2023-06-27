import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:i_densfa/module/beatplan_stores_module/beat_plan_model.dart';
import 'package:i_densfa/module/beatplan_stores_module/beatplan_stores_repository.dart';
import 'package:i_densfa/module/beatplan_stores_module/store_list_model.dart';
import 'package:i_densfa/utility/device_helper.dart';
import 'package:i_densfa/utility/extensions.dart';

part 'beatplan_stores_event.dart';
part 'beatplan_stores_state.dart';

class BeatplanStoresBloc
    extends Bloc<BeatplanStoresEvent, BeatplanStoresState> {
  final BeatPlanStoresRepository repo;
  var isAccending = false;
  var selectedDate = DateTime.now();
  List<BeatPlanModel> beatPlans = [];
  List<BeatPlanModel> allPlans = [];
  Position? userLocation;
  List<StoreItemModel> storesList = [];
  StoreItemModel? selectedStore;
  String storeAddRemark = '';
  DateTime? storeAddDate;

  BeatplanStoresBloc(this.repo) : super(BeatPlanStoresLoadingState()) {
    on((BeatPlanStoresUpdateData event, emit) async {
      emit(BeatPlanStoresLoadingState());
      updateUserLocation();
      allPlans = await repo.getBeatPlans(selectedDate).catchError((onError) {
        emit(BeatPlanSnackBarMessage(onError.toString()));
        return <BeatPlanModel>[];
      });
      isAccending = false;
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

    on((SortBeatplanStoresEvent event, emit) {
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
        emit(BeatPlanSnackBarMessage(onError.toString()));
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
        emit(BeatPlanSnackBarMessage('Please select store'));
      } else if (storeAddDate == null) {
        emit(BeatPlanSnackBarMessage('Please provide date'));
      } else if (storeAddRemark.trim().isEmpty) {
        emit(BeatPlanSnackBarMessage('Please provide reason'));
      } else {
        emit(BeatPlanUploadLoadingState());
        final success = await repo
            .beatPlanUpload(
                storeAddDate!, storeAddRemark, selectedStore!.storeId)
            .catchError((onError) {
          emit(BeatPlanSnackBarMessage(onError.toString()));
          return false;
        });
        if (success) {
          if (selectedDate.isSameDate(storeAddDate!)) {
            add(BeatPlanStoresUpdateData());
          }
          selectedStore = null;
          storeAddDate = null;
          emit(BeatPlanSnackBarMessage('Successfully added beat plan'));
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
    add(BeatPlanStoresDateChangeEvent(newDate));
  }

  void onPreviousDateSelect() {
    final newDate = selectedDate.subtract(const Duration(days: 1));
    add(BeatPlanStoresDateChangeEvent(newDate));
  }
}
