import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:i_densfa/module/campaign_module/campaign_repository.dart';
import 'package:i_densfa/module/campaign_module/new_models/question.dart';
import 'package:i_densfa/module/my_schedule_module/beat_plan_model.dart';
import 'package:i_densfa/module/my_schedule_module/mechanic_visit_model.dart';
import 'package:i_densfa/module/my_schedule_module/my_schedule_repository.dart';
import 'package:i_densfa/module/my_schedule_module/store_list_model.dart';
import 'package:i_densfa/utility/app_storage.dart';
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
  List<MechanicVisitModel> mechanicVisits = [];
  List<MechanicVisitModel> allMechanicVisits = [];
  Position? userLocation;
  List<StoreItemModel> storesList = [];
  List<MechanicModel> mechanicList = [];

  StoreItemModel? selectedStore;
  MechanicModel? selectedMechanic;

  static String mechanicLabel(MechanicModel mechanic) =>
      '${mechanic.mechanicName.trim()}-${mechanic.mechanicNumber.trim()}';

  String storeAddRemark = '';
  DateTime? storeAddDate;

  MyScheduleBloc(this.repo) : super(MyScheduleLoadingState()) {
    on((MyScheduleUpdateData event, emit) async {
      emit(MyScheduleLoadingState());
      updateUserLocation();
      final results = await Future.wait([
        repo.getBeatPlans(selectedDate).catchError((_) => <BeatPlanModel>[]),
        repo.getMechanicVisits(selectedDate).catchError((_) => <MechanicVisitModel>[]),
      ]);
      allPlans = results[0] as List<BeatPlanModel>;
      allMechanicVisits = results[1] as List<MechanicVisitModel>;
      mechanicVisits = allMechanicVisits;
      isAccending = false;
      allPlans.unique((element) => element.storeId);
      beatPlans = allPlans;
      emit(EmptySearchTextMyScheduleState());
      emit(BeatPlanStoreLoaded());
      if (allPlans.length <= 8) {
        _runStaggeredPreSync(allPlans);
      }
    });

    on((StateChangeEvent event, emit){
      emit(StateChangeData());
    });

    on((MyScheduleDateChangeEvent event, emit) {
      selectedDate = event.date;
      add(MyScheduleUpdateData());
    });

    on((SearchMyScheduleEvent event, emit) {
      if (event.searchText.trim().isEmpty) beatPlans = allPlans;
      beatPlans = allPlans
          .where((element) =>
              element.storecode
                  .toLowerCase()
                  .contains(event.searchText.toLowerCase()) ||
               element.storeId.toString().contains(event.searchText.toLowerCase()) ||
              element.storeName
                  .toLowerCase()
                  .contains(event.searchText.toLowerCase()) ||
              element.pjpId
                  .toString()
                  .toLowerCase()
                  .contains(event.searchText.toLowerCase())
                  )
          .toList();
      emit(BeatPlanStoreLoaded());
    });

    on((SearchMechanicVisitsEvent event, emit) {
      final q = event.searchText.trim().toLowerCase();
      if (q.isEmpty) {
        mechanicVisits = allMechanicVisits;
      } else {
        mechanicVisits = allMechanicVisits.where((v) {
          return v.mechanicName.toLowerCase().contains(q) ||
              v.mechanicContact.toLowerCase().contains(q) ||
              v.retailerName.toLowerCase().contains(q) ||
              v.storeId.toString().contains(q) ||
              v.segment.toLowerCase().contains(q) ||
              v.location.toLowerCase().contains(q);
        }).toList();
      }
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

    on((GetAllMechancicListEvent event, emit) async {
      mechanicList = await repo.getAllMechanics().catchError((onError) {
        emit(MyScheduleSnackBarMessage(onError.toString()));
        return <MechanicModel>[];
      });
      emit(MechanicListLoadedState());
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


    on((AddMechanicsEvent event, emit) async {
      if (selectedMechanic == null) {
        emit(MyScheduleSnackBarMessage('Please select mechanic'));
      } else if (storeAddDate == null) {
        emit(MyScheduleSnackBarMessage('Please provide date'));
      } else {
        emit(BeatPlanUploadLoadingState());
        final remarks = storeAddRemark.trim();
        final success = await repo
            .saveMechanicVisit(
              mechanicId: selectedMechanic!.id,
              date: storeAddDate!,
              remarks: remarks.isEmpty ? null : remarks,
            )
            .catchError((onError) {
          emit(MyScheduleSnackBarMessage(onError.toString()));
          return false;
        });
        if (success) {
          if (selectedDate.isSameDate(storeAddDate!)) {
            add(MyScheduleUpdateData());
          }
          selectedMechanic = null;
          storeAddRemark = '';
          storeAddDate = null;
          emit(MyScheduleSnackBarMessage(
              'Mechanic visit saved successfully'));
          emit(BeatPlanUploadSuccess());
        }
      }
    });
  }

  /// Runs pre-sync for all unique stores after a random delay, one store at a time,
  /// to avoid server load spikes when many users open My Schedule together.
  void _runStaggeredPreSync(List<BeatPlanModel> plans) {
    final storeIds = <int>{};
    for (final plan in plans) {
      storeIds.add(plan.storeId);
    }
    if (storeIds.isEmpty) return;
    final campaignRepo = CampaignRepository();
    final delaySeconds = 10 + Random().nextInt(51); // 10–60 seconds
    Future.delayed(Duration(seconds: delaySeconds), () async {
      try {
        for (final storeId in storeIds) {
          try {
            await campaignRepo.preSyncCampaignsForStore(storeId.toString());
          } catch (e) {
            if (kDebugMode) {
              debugPrint(
                  'Pre-sync for store $storeId failed: ${e.toString()}');
            }
          }
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint(
              'Failed to start campaign pre-sync from MyScheduleBloc: ${e.toString()}');
        }
      }
    });
  }

  void updateUserLocation() async {
    try {
      userLocation = await Device().userPosition();
    } catch (e) {
      e.toString();
    }
  }

  double distanceFromStore(BeatPlanModel details) {
    if (userLocation == null) {
      return -1;
    } else if (!(AppStorage()
            .userDetail
            ?.configuration
            .requiredGeoFencingForMarkIn ??
        true)) {
      return 0;
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
