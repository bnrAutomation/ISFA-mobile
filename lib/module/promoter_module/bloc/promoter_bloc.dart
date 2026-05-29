import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:i_densfa/module/campaign_module/campaign_model.dart';

import 'package:i_densfa/module/promoter_module/models/inventory_detail_model.dart';
import 'package:i_densfa/module/promoter_module/models/promoter_store_detail_model.dart';
import 'package:i_densfa/module/promoter_module/promoter_repository.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/continuous_location_service.dart';
import 'package:i_densfa/utility/device_helper.dart';
import 'package:i_densfa/utility/services/global_offline_sync_service.dart';
import 'package:i_densfa/utility/services/markin_markout_offline_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

part 'promoter_event.dart';
part 'promoter_state.dart';

class PromoterBloc extends Bloc<PromoterEvent, PromoterState> {
  final PromoterRepository repo;
  bool isAlreadyMarkin = true;
  InventoryDetailModel? inventoryDetail;
  PromoterStoreDetailModel? storeDetail;
  List<InventoryProductDetailModel> filteredList = [];
  List<CampaignDetailModel> compaigns = [];
  final userDetail = AppStorage().userDetail;
  List<String> filledCampaignList = [];
  PromoterBloc(this.repo) : super(PromoterInitial()) {
    // Initialize offline service
    repo.markinMarkoutOfflineService.init();
    
    // Register sync handler with global service
    GlobalOfflineSyncService.instance.registerSyncHandler(
      SyncDataType.markinMarkout,
      (bool bySync) => _syncMarkinMarkout(bySync: bySync),
    );
    on((GetInventoryDetailEvent event, emit) async =>
        await _getInventoryDetails(emit));
    on((GetStoreDetailEvent event, emit) async => await _getStoreDetails(emit));
    on((SearchByNamePromoterEvent event, emit) =>
        _filterProduct(event.name, emit));

    on((PromoterShowToastMessageEvent event, emit) =>
        emit(PromoterToastMessageState(event.message)));
    on(_checkInStore);
    on(_markOutStore);
    on(_markinWithImage);
    on(_markoutWithImage);
    on(_getFilledCampaign);
    on((GoToMapPromoterEvent event, emit) {
      final lat = storeDetail?.latitude ?? 0;
      final long = storeDetail?.longitude ?? 0;

      var uri = Uri.parse(Platform.isAndroid
          ? "google.navigation:q=$lat,$long&mode=d"
          : "https://maps.apple.com/?q=$lat,$long");
      launchUrl(uri);
    });

    on(gotoCompaignEvent);

    on<MoveToFeedBackEvent>((event, emit) => emit(MoveToFeedBackState()));
  }

  bool get isMarkedIn =>
      AppStorage().markedInStoreId != null &&
      AppStorage().markedInStoreId == storeDetail?.storeId;

  Future<void> gotoCompaignEvent(GotoCompaignEvent event, emit) async {
    emit(CompaignsLoadedPromoterState());
    // if (storeDetail?.storeId == null) {
    //   emit(PromoterToastMessageState('Store not found'));
    //   return;
    // }
    // List<CampaignDetailModel> compaignsResponse =
    //     await repo.getCompaignList(storeDetail!.storeId).catchError((onError) {
    //   emit(PromoterToastMessageState(onError.toString()));
    //   return <CampaignDetailModel>[];
    // });

    // final now = DateTime.now();
    // compaigns = compaignsResponse
    //     .where((element) =>
    //         element.startDate.isBefore(now) && element.endDate.isAfter(now))
    //     .toList();

    // if (compaigns.isNotEmpty) {
    //   emit(CompaignsLoadedPromoterState());
    // } else {
    //   emit(PromoterToastMessageState("No Campaign"));
    // }
  }

  Future<void> _markOutStore(PromoterCheckOutStoreEvent event, emit) async {
    emit(PromoterStoreDetailLoadingState());

    if (storeDetail?.storeId == null) {
      emit(PromoterToastMessageState('Store not found'));
      return;
    }

    if (userDetail?.configuration.requiresAllFillCampigned ?? false) {
      final list = await repo
          .getCampaignsForStore(storeDetail?.storeId.toString() ?? "");
      if (list.any((element) => !filledCampaignList.contains(element.uuid))) {
        emit(PromoterToastMessageState(
            'Please fill all campaign before mark-out.'));

        return;
      }
    }

    final loc = await ContinuousLocationService.instance.resolveForSecureAction().catchError((onError) {
      emit(PromoterToastMessageState(onError.toString()));
      emit(PromoterStoreDetailLoadedState());
      return Future<Position>.error(onError);
    });

    final storeDistance =
        (userDetail?.configuration.requiredGeoFencingForMarkIn ?? true)
            ? Geolocator.distanceBetween(storeDetail?.latitude ?? 0,
                    storeDetail?.longitude ?? 0, loc.latitude, loc.longitude)
                .toInt()
            : 0;
    if (storeDistance > AppConstant.storeRange) {
      emit(PromoterToastMessageState('You are not in store range'));
      return;
    }

    if (AppStorage().userDetail?.companyName.toLowerCase() == "organic india") {
      try {
        final checkActivity =
            await repo.checkActivity(storeDetail?.storeId ?? -1);
        if (!checkActivity.campaignResponseSubmitted) {
          emit(PromoterPOPMessageState(
              "Please perform all activities (i.e., Sales log and start campaign) to mark out from Store."));
          return;
        } 
        // else if (!checkActivity.inventoryAdd) {
        //   emit(PromoterPOPMessageState(
        //       "Please perform all activities (i.e., Sales log, Inventory and start campaign) to mark out from Store."));
        //   return;
        // }
         else if (!checkActivity.salesLog) {
          emit(PromoterPOPMessageState("Please perform all activities (i.e., Sales log and start campaign) to mark out from Store."));
          return;
        } else if (checkActivity.redirect) {
          emit(ShowSalesMessage(
              "Sales or Quantity is low -Please give your feedback"));
          //  emit(MoveToFeedBackState());
          return;
        }
      } catch (error) {
        emit(PromoterToastMessageState(error.toString()));
        return;
      }
    }
    if (userDetail?.configuration.requiredSelfieForMarkIn ?? true) {
      emit(TakeMarkOutImage(loc));
      return;
    }
    
    try {
      final response = await repo.markInOutStore(
        null,
        loc.latitude,
        loc.longitude,
        storeDetail!.storeId,
        false,
        userDetail?.configuration.requiredSelfieForMarkIn ?? false,
        userDetail?.configuration.requiredGeoFencingForMarkIn ?? false,
        storeDistance,
      );
      
      emit(PromoterToastMessageState(response));
      AppStorage().markedInStoreId = null;
      isAlreadyMarkin = true;
      emit(PromoterStoreDetailLoadedState());
    } on OfflineMarkinMarkoutException catch (e) {
      // Offline - data queued for sync
      final pendingCount = repo.markinMarkoutOfflineService.getPendingSubmissionCount();
      emit(PromoterToastMessageState(
        "${e.message} $pendingCount pending submission(s)."
      ));
      AppStorage().markedInStoreId = null;
      isAlreadyMarkin = true;
      emit(PromoterStoreDetailLoadedState());
    } catch (error) {
      emit(PromoterToastMessageState(error.toString()));
      emit(PromoterStoreDetailLoadedState());
    }
  }

  Future<void> _markoutWithImage(
      MarkOutWithImage event, Emitter<PromoterState> emit) async {
    final loc = await ContinuousLocationService.instance.resolveForSecureAction().catchError((onError) {
      emit(PromoterToastMessageState(onError.toString()));
      emit(PromoterStoreDetailLoadedState());
      return Future<Position>.error(onError);
    });

    final storeDistance =
        (userDetail?.configuration.requiredGeoFencingForMarkIn ?? true)
            ? Geolocator.distanceBetween(storeDetail?.latitude ?? 0,
                    storeDetail?.longitude ?? 0, loc.latitude, loc.longitude)
                .toInt()
            : 0;
    if (storeDistance > AppConstant.storeRange) {
      emit(PromoterToastMessageState('You are not in store range'));
      return;
    }

    emit(PromoterStoreDetailLoadingState());
    final device = Device();
    const text = "";
    //  'DateTime: ${DateTime.now().toStringFormat("dd-MMM-yyyy hh:mm aa")}\nLatitude: ${event.loc.latitude}\nLongitude: ${event.loc.longitude}';

    // Process image
    final modifiedImage =
        (await device.compressImage(event.file.path, text, "markout"));
    //await Device().addTextToImagex(event.file, text, 'markout');
      try {
        final response = await repo.markInOutStore(
          XFile(modifiedImage),
          loc.latitude,
          loc.longitude,
          storeDetail!.storeId,
          false,
          userDetail?.configuration.requiredSelfieForMarkIn ?? false,
          userDetail?.configuration.requiredGeoFencingForMarkIn ?? false,
          storeDistance,
        );
        
        emit(PromoterToastMessageState(response));
        AppStorage().markedInStoreId = null;
        isAlreadyMarkin = true;
        emit(PromoterStoreDetailLoadedState());
      } on OfflineMarkinMarkoutException catch (e) {
        // Offline - data queued for sync
        final pendingCount = repo.markinMarkoutOfflineService.getPendingSubmissionCount();
        emit(PromoterToastMessageState(
          "${e.message} $pendingCount pending submission(s)."
        ));
        AppStorage().markedInStoreId = null;
        isAlreadyMarkin = true;
        emit(PromoterStoreDetailLoadedState());
      } catch (error) {
        emit(PromoterToastMessageState(error.toString()));
        emit(PromoterStoreDetailLoadedState());
      }
  }

  Future<void> _markinWithImage(
      MarkingWithImage event, Emitter<PromoterState> emit) async {
    final loc = await ContinuousLocationService.instance.resolveForSecureAction().catchError((onError) {
      emit(PromoterToastMessageState(onError.toString()));
      emit(PromoterStoreDetailLoadedState());
      return Future<Position>.error(onError);
    });
    final storeDistance =
        (userDetail?.configuration.requiredGeoFencingForMarkIn ?? true)
            ? Geolocator.distanceBetween(storeDetail?.latitude ?? 0,
                    storeDetail?.longitude ?? 0, loc.latitude, loc.longitude)
                .toInt()
            : 0;
    if (storeDistance > AppConstant.storeRange) {
      emit(PromoterToastMessageState('You are not in store range'));
      return;
    }
    final device = Device();
    const text = "";
    //     'DateTime: ${DateTime.now().toStringFormat("dd-MMM-yyyy hh:mm aa")}\nLatitude: ${event.loc.latitude}\nLongitude: ${event.loc.longitude}';

    // Process image
    final modifiedImage =
        (await device.compressImage(event.file.path, text, "markin"));
    // await Device().addTextToImagex(event.file, text, 'markin');
      try {
        final response = await repo.markInOutStore(
          XFile(modifiedImage),
          event.loc.latitude,
          event.loc.longitude,
          storeDetail!.storeId,
          true,
          userDetail?.configuration.requiredSelfieForMarkIn ?? true,
          userDetail?.configuration.requiredGeoFencingForMarkIn ?? false,
          storeDistance,
        );
        
        emit(PromoterToastMessageState(response));
        AppStorage().markedInStoreId = storeDetail!.storeId;
        emit(PromoterStoreDetailLoadedState());
      } on OfflineMarkinMarkoutException catch (e) {
        // Offline - data queued for sync
        final pendingCount = repo.markinMarkoutOfflineService.getPendingSubmissionCount();
        emit(PromoterToastMessageState(
          "${e.message} $pendingCount pending submission(s)."
        ));
        AppStorage().markedInStoreId = storeDetail!.storeId;
        emit(PromoterStoreDetailLoadedState());
      } catch (error) {
        emit(PromoterToastMessageState(error.toString()));
        emit(PromoterStoreDetailLoadedState());
      }
  }

  Future<void> _checkInStore(
      PromoterCheckInStoreEvent event, Emitter<PromoterState> emit) async {
    emit(PromoterStoreDetailLoadingState());
    if (storeDetail?.storeId == null) {
      emit(PromoterToastMessageState('Store not found'));
      return;
    }

    if (userDetail?.userConfiguration.requiredStartDuty == true ||
        userDetail?.configuration.requiredStartDuty == true) {
      if (!AppStorage().isDutyStarted) {
        emit(PromoterToastMessageState('Please start your Duty first'));
        return;
      }
    }

    final loc = await ContinuousLocationService.instance.resolveForSecureAction().catchError((onError) {
      emit(PromoterToastMessageState(onError.toString()));
      emit(PromoterStoreDetailLoadedState());
      return Future<Position>.error(onError);
    });

    final storeDistance =
        AppStorage().userDetail?.configuration.requiredGeoFencingForMarkIn ??
                true
            ? Geolocator.distanceBetween(storeDetail!.latitude,
                    storeDetail!.longitude, loc.latitude, loc.longitude)
                .toInt()
            : 0;
    if (storeDistance > 250) {
      emit(PromoterToastMessageState('You are not in store range'));
      return;
    }
    // final img = await ImagePicker().pickImage(source: ImageSource.camera);
    // if (img == null) {
    //   emit(PromoterToastMessageState('Please click image'));
    //   emit(PromoterStoreDetailLoadedState());
    //   return;
    // }

    if (AppStorage().userDetail?.configuration.requiredSelfieForMarkIn ??
        true) {
      emit(TakeMarkinImage(loc));
      return;
    }

    try {
      final response = await repo.markInOutStore(
        null,
        loc.latitude,
        loc.longitude,
        storeDetail!.storeId,
        true,
        userDetail?.configuration.requiredSelfieForMarkIn ?? false,
        userDetail?.configuration.requiredGeoFencingForMarkIn ?? true,
        storeDistance,
      );
      
      emit(PromoterToastMessageState(response));
    } on OfflineMarkinMarkoutException catch (e) {
      // Offline - data queued for sync
      final pendingCount = repo.markinMarkoutOfflineService.getPendingSubmissionCount();
      emit(PromoterToastMessageState(
        "${e.message} $pendingCount pending submission(s)."
      ));
    } catch (error) {
      emit(PromoterToastMessageState(error.toString()));
    }
    AppStorage().markedInStoreId = storeDetail!.storeId;
    emit(PromoterStoreDetailLoadedState());
  }

  Future<void> _getInventoryDetails(Emitter<PromoterState> emit) async {
    if (storeDetail?.storeId == null) {
      emit(PromoterToastMessageState("Store not found"));
      emit(StoreInventoryLoadedState());
      return;
    }
    emit(StoreInventoryLoadingState());
    await repo.getInventoryDetail(storeDetail!.storeId).then((value) {
      inventoryDetail = value;
      filteredList = value.productList;
      emit(StoreInventoryLoadedState());
    }).catchError((err) {
      emit(PromoterToastMessageState(err.toString()));
      emit(StoreInventoryLoadedState());
    });
  }

  Future<void> _getStoreDetails(Emitter<PromoterState> emit) async {
    emit(PromoterStoreDetailLoadingState());
    await repo.getStoreDetails().then((value) {
      storeDetail = value;
      isAlreadyMarkin = storeDetail?.alreadyMarkout ?? true;
      if (value.latitude <= 0) {
        emit(PromoterToastMessageState(
            "Store coordinates not found.\nPlease contact admin."));
      }
      AppStorage().markedInStoreId = value.markIn ? value.storeId : null;
      emit(PromoterStoreDetailLoadedState());
      add(GetCampaignFilledEvent());
    }).catchError((err) {
      emit(PromoterToastMessageState(err.toString()));
      emit(PromoterStoreDetailLoadedState());
    });
  }

  void _filterProduct(String val, Emitter<PromoterState> emit) {
    if (val.isNotEmpty) {
      filteredList = inventoryDetail?.productList
              .where((element) =>
                  element.productName.toLowerCase().contains(val.toLowerCase()))
              .toList() ??
          [];
    } else {
      filteredList = inventoryDetail?.productList ?? [];
    }
    emit(StoreInventoryLoadedState());
  }

  Future<void> _getFilledCampaign(GetCampaignFilledEvent event, emit) async {
    if (!(userDetail?.configuration.requiresAllFillCampigned ?? false)) {
      return;
    }
    try {
      filledCampaignList =
          await repo.getFilledCampaign(storeDetail?.storeId.toString() ?? "");
      emit(PromoterStoreDetailLoadedState());
    } catch (onError) {
      emit(PromoterToastMessageState(onError.toString()));
    }
  }
  
  /// Sync pending markin/markout submissions
  Future<void> _syncMarkinMarkout({bool bySync = false}) async {
    final offlineService = repo.markinMarkoutOfflineService;
    final isOnline = await offlineService.isOnline();
    if (!isOnline) return;
    
    final pending = await offlineService.getPendingSubmissions();
    if (pending.isEmpty) return;
    
    for (var submission in pending) {
      try {
        await offlineService.updateSubmissionStatus(
          submission['id'],
          'processing',
        );
        
        // Reconstruct request and submit with bySync: true
        await repo.markInOutStore(
          submission['imagePath'] != null && 
                  (submission['imagePath'] as String).isNotEmpty
              ? XFile(submission['imagePath'])
              : null,
          submission['latitude'] as double,
          submission['longitude'] as double,
          submission['storeId'] as int,
          submission['isIn'] as bool,
          submission['isImage'] as bool,
          submission['geofence'] as bool,
          submission['distance'] as int,
          bySync: true, // Auto sync
        );
        
        // Success - remove from queue
        await offlineService.removeSubmission(submission['id']);
        if (kDebugMode) {
          debugPrint('✅ Synced markin/markout: ${submission['id']}');
        }
      } catch (e) {
        // Failed - mark as failed for retry
        await offlineService.updateSubmissionStatus(
          submission['id'],
          'failed',
          error: e.toString(),
        );
        if (kDebugMode) {
          debugPrint(
              '❌ Failed to sync markin/markout: ${submission['id']}, $e');
        }
      }
    }
  }
}
