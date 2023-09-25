import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:i_densfa/module/campaign_module/campaign_model.dart';
import 'package:i_densfa/module/my_schedule_module/beat_plan_model.dart';
import 'package:i_densfa/module/promoter_module/feedback/model/feedback_model.dart';
import 'package:i_densfa/module/store_detail_module/store_detail_model.dart';

import 'package:i_densfa/module/store_detail_module/store_detail_repositry.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/device_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

part 'store_detail_event.dart';
part 'store_detail_state.dart';

class StoreDetailBloc extends Bloc<StoreDetailEvent, StoreDetailState> {
  BeatPlanModel beatPlanModel;
  List<CampaignDetailModel> compaigns = [];
  List<FeedbackDataList> feedbackList = [];
  final StoreDetailRepository repo;
  GetStoreDetailDataModel? details;
  Position? userLocation;
  StoreDetailBloc(this.repo, this.beatPlanModel) : super(StoreDetailInitial()) {
    on(_getStoreDetails);
    on(_getFeedback);
    on(gotoCompaignEvent);
    on(_markOutStore);
    on(_checkInStore);
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
    add(GetStoreDetailsEvent());
    add(GetFeedbackEvent());
  }

  double get distanceFromStore {
    if (userLocation == null) {
      return -1;
    } else {
      if (kReleaseMode) {
        return Geolocator.distanceBetween(
            details?.latitude ?? 0,
            details?.longitude ?? 0,
            userLocation!.latitude,
            userLocation!.longitude);
      } else {
        return 0;
      }
    }
  }

  String noteToAdd = "";
  Future<void> _addNote(SaveNoteStoreDetailEvent event, emit) async {
    final resp = await repo
        .addNoteForStore(noteToAdd, beatPlanModel.storeId)
        .catchError((onError) {
      debugPrint(onError.toString());
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

  Future<void> _getStoreDetails(GetStoreDetailsEvent event, emit) async {
    _updateUserPosition().catchError((onError) {
      debugPrint(onError.toString());
    });
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
      emit(StoreDetailToastMessageState(onError.toString()));
      return Future<List<FeedbackDataList>>.error(onError);
    });
    emit(LoadedFeedbackState());
  }

  void gotoCompaignEvent(GotoCompaignEvent event, emit) {
    emit(CompaignsLoadedStoreDetailState());
  }

  Future<void> _checkInStore(
      MarkInStoreDetailEvent event, Emitter<StoreDetailState> emit) async {
    final now = DateTime.now();
    if (beatPlanModel.pjpDate.isAfter(DateTime(now.year, now.month, now.day + 1)
        .subtract(const Duration(minutes: 1)))) {
      emit(
          StoreDetailToastMessageState('You can not Mark In for future dates'));
      return;
    }

    if (!AppStorage().isDutyStarted) {
      emit(StoreDetailToastMessageState('Please start your Duty first'));
      return;
    }
    if (AppStorage().markedInStoreId != null &&
        AppStorage().markedInStoreId != beatPlanModel.storeId) {
      emit(StoreDetailToastMessageState(
          'You are already marked In for other store\nPlease mark Out first.'));
      return;
    }
    emit(MarkingLoadingStoreDetailState());
    await _updateUserPosition().catchError((onError) {
      emit(StoreDetailToastMessageState(onError.toString()));
      return Future<void>.error(onError);
    });

    if (distanceFromStore > AppConstant.storeRange) {
      emit(StoreDetailToastMessageState('You are not in store range'));
      return;
    } else if (distanceFromStore < 0) {
      emit(StoreDetailToastMessageState('Please enable location service'));
      return;
    }
    final img = await ImagePicker().pickImage(
        source: kReleaseMode ? ImageSource.camera : ImageSource.gallery);
    if (img == null) {
      emit(StoreDetailToastMessageState('Please click image'));
      return;
    }

    final response = await repo
        .markInOutStore(
            file: img,
            latitude: userLocation!.latitude,
            longitude: userLocation!.longitude,
            pjpId: beatPlanModel.pjpId,
            isIn: true,
            storeId: beatPlanModel.storeId)
        .catchError((error) {
      emit(StoreDetailToastMessageState(error.toString()));
      return Future<String>.error(error);
    });
    beatPlanModel.markin = true;
    AppStorage().markedInStoreId = beatPlanModel.storeId;
    emit(StoreDetailToastMessageState(response));
  }

  Future<void> _markOutStore(MarkOutStoreDetailEvent event, emit) async {
    await _updateUserPosition().catchError((onError) {
      emit(StoreDetailToastMessageState(onError.toString()));
      return Future<void>.error(onError);
    });

    if (distanceFromStore > AppConstant.storeRange) {
      emit(StoreDetailToastMessageState('You are not in store range'));
      return;
    } else if (distanceFromStore < 0) {
      emit(StoreDetailToastMessageState('Please enable location service'));
      return;
    }
    final img = await ImagePicker().pickImage(
        source: kReleaseMode ? ImageSource.camera : ImageSource.gallery);
    if (img == null) {
      emit(StoreDetailToastMessageState('Please click image'));
      return;
    }
    final response = await repo
        .markInOutStore(
            file: img,
            latitude: userLocation!.latitude,
            longitude: userLocation!.longitude,
            pjpId: beatPlanModel.pjpId,
            isIn: false,
            storeId: beatPlanModel.storeId)
        .catchError((error) {
      emit(StoreDetailToastMessageState(error.toString()));
      return Future<String>.error(error);
    });
    beatPlanModel.markin = false;
    AppStorage().markedInStoreId = null;
    beatPlanModel.isAlreadyMarkin = true;
    emit(StoreDetailToastMessageState(response));
  }

  Future<void> _updateUserPosition() async {
    final loc = await Device().userPosition();
    userLocation = loc;
  }
}
