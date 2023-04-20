import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:i_densfa/module/beatplan_stores_module/beat_plan_model.dart';
import 'package:i_densfa/module/campaign_module/campaign_model.dart';
import 'package:i_densfa/module/store_detail_module/store_detail_model.dart';

import 'package:i_densfa/module/store_detail_module/store_detail_repositry.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/device_helper.dart';
import 'package:image_picker/image_picker.dart';

part 'store_detail_event.dart';
part 'store_detail_state.dart';

class StoreDetailBloc extends Bloc<StoreDetailEvent, StoreDetailState> {
  BeatPlanModel beatPlanModel;
  List<CampaignDetailModel> compaigns = [];
  final StoreDetailRepository repo;
  GetStoreDetailDataModel? details;
  StoreDetailBloc(this.repo, this.beatPlanModel) : super(StoreDetailInitial()) {
    on(_getStoreDetails);
    on(gotoCompaignEvent);
    on(_markOutStore);
    on(_checkInStore);
    on(_addNote);
    add(GetStoreDetailsEvent());
  }

  String noteToAdd = "";
  Future<void> _addNote(SaveNoteStoreDetailEvent event, emit) async {
    final resp = await repo.addNoteForStore(noteToAdd, beatPlanModel.storeId);
    if (resp) {
      emit(StoreDetailToastMessageState('Successfully added note'));
      add(GetStoreDetailsEvent());
    } else {
      emit(StoreDetailToastMessageState('Failed to add note'));
    }
  }

  Future<void> _getStoreDetails(GetStoreDetailsEvent event, emit) async {
    details =
        await repo.getStoreDetails(beatPlanModel.storeId).catchError((onError) {
      emit(StoreDetailToastMessageState(onError.toString()));
      return Future<GetStoreDetailDataModel>.error(onError);
    });
    emit(LoadedStoreDetailState());
  }

  void gotoCompaignEvent(GotoCompaignEvent event, emit) {
    emit(CompaignsLoadedStoreDetailState());
  }

  Future<void> _checkInStore(
      MarkInStoreDetailEvent event, Emitter<StoreDetailState> emit) async {
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
    final loc = await Device().userPosition().catchError((onError) {
      emit(StoreDetailToastMessageState(onError.toString()));
      return Future<Position>.error(onError);
    });
    // final storeDistance =
    //     Geolocator.distanceBetween(0, 0, loc.latitude, loc.longitude);
    // if (storeDistance > 100) {
    //   emit(StoreDetailToastMessageState('You are not in store range'));
    //   return;
    // }
    final img = await ImagePicker().pickImage(source: ImageSource.camera);
    if (img == null) {
      emit(StoreDetailToastMessageState('Please click image'));
      return;
    }

    final response = await repo
        .markInOutStore(
            file: img,
            latitude: loc.latitude,
            longitude: loc.longitude,
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
    final loc = await Device().userPosition().catchError((onError) {
      emit(StoreDetailToastMessageState(onError.toString()));
      return Future<Position>.error(onError);
    });

    final img = await ImagePicker().pickImage(source: ImageSource.camera);
    if (img == null) {
      emit(StoreDetailToastMessageState('Please click image'));
      return;
    }

    final response = await repo
        .markInOutStore(
            file: img,
            latitude: loc.latitude,
            longitude: loc.longitude,
            pjpId: beatPlanModel.pjpId,
            isIn: false,
            storeId: beatPlanModel.storeId)
        .catchError((error) {
      emit(StoreDetailToastMessageState(error.toString()));
      return Future<String>.error(error);
    });
    beatPlanModel.markin = false;
    AppStorage().markedInStoreId = null;
    emit(StoreDetailToastMessageState(response));
  }
}
