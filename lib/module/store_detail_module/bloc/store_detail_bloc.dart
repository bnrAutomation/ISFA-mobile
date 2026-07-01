import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:i_densfa/module/campaign_module/campaign_model.dart';
import 'package:i_densfa/module/campaign_module/new_models/campaign.dart';
import 'package:i_densfa/module/my_schedule_module/beat_plan_model.dart';
import 'package:i_densfa/module/promoter_module/feedback/model/feedback_model.dart';
import 'package:i_densfa/module/store_detail_module/store_detail_model.dart';

import 'package:i_densfa/module/store_detail_module/store_detail_repository.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/base_bloc.dart';
import 'package:i_densfa/utility/continuous_location_service.dart';
import 'package:i_densfa/utility/device_helper.dart';
import 'package:i_densfa/utility/services/global_offline_sync_service.dart';
import 'package:i_densfa/utility/services/markin_markout_offline_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

part 'store_detail_event.dart';
part 'store_detail_state.dart';

class StoreDetailBloc extends BaseBloc<StoreDetailEvent, StoreDetailState> with LocationMixin {
  BeatPlanModel beatPlanModel;
  List<CampaignDetailModel> campaigns = [];
  List<FeedbackDataList> feedbackList = [];
  List<String> filledCampaignList = [];
  List<AllCampaignModel> availableCampaigns = [];
  int campaignListRefreshToken = 0;
  final StoreDetailRepository repo;
  GetStoreDetailDataModel? details;
  Position? userLocation;
  final userDetail = AppStorage().userDetail;
  StoreDetailBloc(this.repo, this.beatPlanModel) : super(StoreDetailInitial()) {
    // Initialize offline service
    repo.markinMarkoutOfflineService.init();
    
    // Register sync handler with global service
    GlobalOfflineSyncService.instance.registerSyncHandler(
      SyncDataType.markinMarkout,
      (bool bySync) => _syncMarkinMarkout(bySync: bySync),
    );
    on(_getStoreDetails);
    on(_getFilledCampaign);
    on(_getFeedback);
    on(gotoCampaignEvent);
    on(_markOutStore);
    on(_checkInStore);
    on(_markinWithImage);
    on(_markoutWithImage);
    on(_addNote);
    on((ShowStoreOnMapStoreDetailEvent event, emit) {
      final lat = details?.latitude ?? 0;
      final long = details?.longitude ?? 0;
      var uri = Uri.parse(Platform.isAndroid
          ? "google.navigation:q=$lat,$long&mode=d"
          : "https://maps.apple.com/?q=$lat,$long");
      launchUrl(uri);
    });
    on((CallStoreDetailEvent event, emit) {
      final no = details?.phoneNo ?? "";
      if (no.isEmpty) {
        emit(StoreDetailToastMessageState('Phone number not found!'));
      } else {
        launchUrlString('tel://$no');
      }
    });
    on(_deleteNote);
    on(_fetchCampaignsForAdd);
    on(_addCampaignToStore);
    on<ChangeStateEvent>((event, emit) => emit(ChangeState()));
    add(GetStoreDetailsEvent());
    add(GetCampaignFilledEvent());
    add(GetFeedbackEvent());
  }

  int get distanceFromStore {
    if (userLocation == null) {
      return -1;
    } else if (!(userDetail?.configuration.requiredGeoFencingForMarkIn ??
        true)) {
      return 0;
    } else {
      return Geolocator.distanceBetween(
          details?.latitude ?? 0.0,
          details?.longitude ?? 0.0,
          userLocation!.latitude,
          userLocation!.longitude).toInt();
    }
  }

  String noteToAdd = "";
  bool loading = false;

  Future<void> _addNote(SaveNoteStoreDetailEvent event, emit) async {
    final resp = await repo
        .addNoteForStore(noteToAdd, beatPlanModel.storeId)
        .catchError((onError) {
      return false;
    });
    if (resp) {
      emit(StoreDetailToastMessageState('Successfully added note'));
      add(GetStoreDetailsEvent());
    } else {
      emit(StoreDetailToastMessageState('Failed to add note'));
    }
  }

  Future<void> _deleteNote(DeleteNoteStoreDetailEvent event, emit) async {
    final resp = await repo.deleteNoteForStore(event.noteId);
    if (resp) {
      emit(StoreDetailToastMessageState('Note successfully deleted'));
      add(GetStoreDetailsEvent());
    } else {
      emit(StoreDetailToastMessageState('Failed to delete note'));
    }
  }

  Future<void> _getFilledCampaign(GetCampaignFilledEvent event, emit) async {
    if (!(userDetail?.configuration.requiresAllFillCampigned ?? false)) {
      return;
    }
    try {
      emit(LoadedStoreDetailState());
      filledCampaignList = await repo.getFilledCampaign(beatPlanModel.storeId);
    } catch (onError) {
      emit(StoreDetailToastMessageState(onError.toString()));
    }
  }

  Future<void> _getStoreDetails(GetStoreDetailsEvent event, emit) async {
    _updateUserPosition().catchError((onError) {});
    details =
        await repo.getStoreDetails(beatPlanModel.storeId).catchError((onError) {
      emit(StoreDetailToastMessageState(onError.toString()));
      return Future<GetStoreDetailDataModel>.error(onError);
    });
    emit(LoadedStoreDetailState());
  }

  Future<void> _getFeedback(GetFeedbackEvent event, emit) async {
    feedbackList =
        await repo.getFeedback(beatPlanModel.storeName).catchError((onError) {
      // In offline mode or on network error, show a friendly message and
      // treat it as "no feedback" instead of failing the flow.
      emit(StoreDetailToastMessageState(
          'Unable to load feedback in offline mode.'));
      return <FeedbackDataList>[];
    });
    emit(LoadedFeedbackState());
  }

  void gotoCampaignEvent(GotoCampaignEvent event, emit) {
    emit(CampaignsLoadedStoreDetailState());
  }

  Future<void> _fetchCampaignsForAdd(
      FetchCampaignsStoreDetailEvent event, emit) async {
    try {
      emit(AddCampaignFetchLoadingState());
      availableCampaigns = await repo.fetchAllCampaigns();
      emit(AddCampaignLoadedStoreDetailState(availableCampaigns));
    } catch (e) {
      emit(AddCampaignFetchErrorState(e.toString()));
    }
  }

  Future<void> _addCampaignToStore(
      AddCampaignStoreDetailEvent event, emit) async {
    try {
      emit(AddCampaignSubmitLoadingState());
      await repo.postStoreBeatPlan(
        storeId: beatPlanModel.storeId,
        campaignUuid: event.campaignUuid,
        visitDate: event.visitDate,
        agenda: event.agenda,
      );
      campaignListRefreshToken++;
      emit(AddCampaignSuccessStoreDetailState());
    } catch (e) {
      emit(AddCampaignSubmitErrorState(e.toString()));
    }
  }

  Future<void> _markoutWithImage(
      MarkOutWithImage event, Emitter<StoreDetailState> emit) async {
    loading = true;
    await _updateUserPosition(secure: true).catchError((onError) {
      loading = false;
      userLocation = null;
      emit(StoreDetailToastMessageState(onError.toString()));
      return Future<void>.error(onError);
    });
    if (distanceFromStore > AppConstant.storeRange) {
      loading = false;
      emit(StoreDetailToastMessageState('You are not in store range'));
      return;
    } else if (distanceFromStore < 0) {
      loading = false;
      emit(StoreDetailToastMessageState('Please enable location service'));
      return;
    }
    emit(MarkingLoadingStoreDetailState());
    try {
      final response = await repo.markInOutStore(
        uploadFile: event.file,
        latitude: userLocation?.latitude ?? 0.0,
        longitude: userLocation?.longitude ?? 0.0,
        pjpId: beatPlanModel.pjpId,
        isIn: false,
        storeId: beatPlanModel.storeId,
        isImage: true,
        distance: distanceFromStore,
        geofence: userDetail?.configuration.requiredGeoFencingForMarkIn ?? false,
      );
      
      beatPlanModel.markin = false;
      loading = false;
      AppStorage().markedInStoreId = null;
      beatPlanModel.isAlreadyMarkin = true;
      emit(StoreDetailToastMessageState(response));
    } on OfflineMarkinMarkoutException catch (e) {
      // Offline - data queued for sync
      final pendingCount = repo.markinMarkoutOfflineService.getPendingSubmissionCount();
      emit(StoreDetailToastMessageState(
        "${e.message} $pendingCount pending submission(s)."
      ));
      beatPlanModel.markin = false;
      loading = false;
      AppStorage().markedInStoreId = null;
      beatPlanModel.isAlreadyMarkin = true;
    } catch (error) {
      loading = false;
      emit(StoreDetailToastMessageState(error.toString()));
    }
  }

  Future<void> _markinWithImage(
      MarkingWithImage event, Emitter<StoreDetailState> emit) async {
    loading = true;

    await _updateUserPosition(secure: true).catchError((onError) {
      loading = false;
      userLocation = null;
      emit(StoreDetailToastMessageState(onError.toString()));
      return Future<void>.error(onError);
    });

    if (distanceFromStore > AppConstant.storeRange) {
      loading = false;
      emit(StoreDetailToastMessageState('You are not in store range'));
      return;
    } else if (distanceFromStore < 0) {
      loading = false;
      emit(StoreDetailToastMessageState('Please enable location service'));
      return;
    }
    emit(MarkingLoadingStoreDetailState());
    try {
      final response = await repo.markInOutStore(
        uploadFile: event.file,
        latitude: userLocation?.latitude ?? 0.0,
        longitude: userLocation?.longitude ?? 0.0,
        pjpId: beatPlanModel.pjpId,
        isIn: true,
        storeId: beatPlanModel.storeId,
        isImage: true,
        distance: distanceFromStore,
        geofence: userDetail?.configuration.requiredGeoFencingForMarkIn ?? false,
      );
      
      beatPlanModel.markin = true;
      loading = false;
      AppStorage().markedInStoreId = beatPlanModel.storeId;
      emit(StoreDetailToastMessageState(response));
    } on OfflineMarkinMarkoutException catch (e) {
      // Offline - data queued for sync
      final pendingCount = repo.markinMarkoutOfflineService.getPendingSubmissionCount();
      emit(StoreDetailToastMessageState(
        "${e.message} $pendingCount pending submission(s)."
      ));
      beatPlanModel.markin = true;
      loading = false;
      AppStorage().markedInStoreId = beatPlanModel.storeId;
    } catch (error) {
      loading = false;
      emit(StoreDetailToastMessageState(error.toString()));
    }
  }

  Future<void> _checkInStore(
      MarkInStoreDetailEvent event, Emitter<StoreDetailState> emit) async {
    loading = true;
    emit(LoadingStoreDetailState());
    final now = DateTime.now();
    if (beatPlanModel.pjpDate.isAfter(DateTime(now.year, now.month, now.day + 1)
        .subtract(const Duration(minutes: 1)))) {
      loading = false;
      emit(
          StoreDetailToastMessageState('You can not Mark In for future dates'));
      return;
    }

    if (userDetail?.userConfiguration.requiredStartDuty == true||userDetail?.configuration.requiredStartDuty==true) {
      if (!AppStorage().isDutyStarted) {
        loading = false;
        emit(StoreDetailToastMessageState('Please start your Duty first'));
        return;
      }
    }

       // FWP: restrict duty start before 10:30 AM (system-level validation)
    if (userDetail?.role.toLowerCase() == 'fwp' &&
        userDetail!.designation.toString().toLowerCase().contains("field") &&
         AppStorage().userDetail?.companyName.toLowerCase() == "BrotherInternational".toLowerCase()) {
      final now = DateTime.now();
      final allowedStart = DateTime(now.year, now.month, now.day, 11, 00);
      if (now.isBefore(allowedStart)) {
        loading = false;
        emit(StoreDetailToastMessageState(
            'You cannot start duty before 11:00 AM'));
        return;
      }
    }

    if (AppStorage().markedInStoreId != null &&
        AppStorage().markedInStoreId != beatPlanModel.storeId) {
      loading = false;
      emit(StoreDetailToastMessageState(
          'You are already marked In for other store\nPlease mark Out first.'));
      return;
    }

    await _updateUserPosition(secure: true).catchError((onError) {
      loading = false;
      userLocation = null;
      emit(StoreDetailToastMessageState(onError.toString()));
      return Future<void>.error(onError);
    });
    if (distanceFromStore > AppConstant.storeRange) {
      loading = false;
      emit(StoreDetailToastMessageState('You are not in store range'));
      return;
    } else if (distanceFromStore < 0) {
      loading = false;
      emit(StoreDetailToastMessageState('Please enable location service'));
      return;
    }



    if (userDetail?.configuration.requiredSelfieForMarkIn ?? true) {
      emit(StoreDetailTakeMarkinImage());
      return;
    }
    emit(MarkingLoadingStoreDetailState());
    try {
      final response = await repo.markInOutStore(
        uploadFile: null,
        latitude: userLocation?.latitude ?? 0.0,
        longitude: userLocation?.longitude ?? 0.0,
        pjpId: beatPlanModel.pjpId,
        isIn: true,
        storeId: beatPlanModel.storeId,
        distance: distanceFromStore,
        isImage: userDetail?.configuration.requiredSelfieForMarkIn ?? false,
        geofence: userDetail?.configuration.requiredGeoFencingForMarkIn ?? false,
      );
      
      beatPlanModel.markin = true;
      loading = false;
      AppStorage().markedInStoreId = beatPlanModel.storeId;
      emit(StoreDetailToastMessageState(response));
    } on OfflineMarkinMarkoutException catch (e) {
      // Offline - data queued for sync
      final pendingCount = repo.markinMarkoutOfflineService.getPendingSubmissionCount();
      emit(StoreDetailToastMessageState(
        "${e.message} $pendingCount pending submission(s)."
      ));
      beatPlanModel.markin = true;
      loading = false;
      AppStorage().markedInStoreId = beatPlanModel.storeId;
    } catch (error) {
      loading = false;
      emit(StoreDetailToastMessageState(error.toString()));
    }
  }

  Future<void> _markOutStore(MarkOutStoreDetailEvent event, emit) async {
    loading = true;
    emit(LoadingStoreDetailState());
    if (userDetail?.configuration.requiresAllFillCampigned ?? false) {
      final list =
          await repo.getCampaignsForStore(beatPlanModel.storeId.toString());
      filledCampaignList = await repo.getFilledCampaign(beatPlanModel.storeId);
      if (list.any((element) => !filledCampaignList.contains(element.uuid))) {
        emit(StoreDetailToastMessageState(
            'Please fill all campaign before mark-out.'));
        loading = false;
        return;
      }
    }

    await _updateUserPosition(secure: true).catchError((onError) {
      loading = false;
      userLocation = null;
      emit(StoreDetailToastMessageState(onError.toString()));
      return Future<void>.error(onError);
    });

    if (distanceFromStore > AppConstant.storeRange) {
      loading = false;
      emit(StoreDetailToastMessageState('You are not in store range'));
      return;
    } else if (distanceFromStore < 0) {

      
      loading = false;
      emit(StoreDetailToastMessageState('Please enable location service'));
      return;
    }
    if (userDetail?.configuration.requiredSelfieForMarkIn ?? true) {
      emit(StoreDetailTakeMarkOutImage());
      return;
    }
    emit(MarkingLoadingStoreDetailState());
    try {
      final response = await repo.markInOutStore(
        uploadFile: null,
        latitude: userLocation?.latitude ?? 0.0,
        longitude: userLocation?.longitude ?? 0.0,
        pjpId: beatPlanModel.pjpId,
        isIn: false,
        storeId: beatPlanModel.storeId,
        distance: distanceFromStore,
        isImage: userDetail?.configuration.requiredSelfieForMarkIn ?? false,
        geofence: userDetail?.configuration.requiredGeoFencingForMarkIn ?? false,
      );
      
      beatPlanModel.markin = false;
      loading = false;
      AppStorage().markedInStoreId = null;
      beatPlanModel.isAlreadyMarkin = true;
      emit(StoreDetailToastMessageState(response));
    } on OfflineMarkinMarkoutException catch (e) {
      // Offline - data queued for sync
      final pendingCount = repo.markinMarkoutOfflineService.getPendingSubmissionCount();
      emit(StoreDetailToastMessageState(
        "${e.message} $pendingCount pending submission(s)."
      ));
      beatPlanModel.markin = false;
      loading = false;
      AppStorage().markedInStoreId = null;
      beatPlanModel.isAlreadyMarkin = true;
    } catch (error) {
      loading = false;
      emit(StoreDetailToastMessageState(error.toString()));
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
          uploadFile: submission['imagePath'] != null && 
                  (submission['imagePath'] as String).isNotEmpty
              ? XFile(submission['imagePath'])
              : null,
          latitude: submission['latitude'] as double,
          longitude: submission['longitude'] as double,
          pjpId: submission['pjpId'] as int? ?? beatPlanModel.pjpId,
          isIn: submission['isIn'] as bool,
          storeId: submission['storeId'] as int,
          isImage: submission['isImage'] as bool,
          geofence: submission['geofence'] as bool,
          distance: submission['distance'] as int,
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

  Future<void> _updateUserPosition({bool secure = false}) async {
    final loc = secure
        ? await ContinuousLocationService.instance.resolveForSecureAction()
        : await Device().userPosition();
    userLocation = loc;
  }
}
