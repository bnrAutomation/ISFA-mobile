import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:i_densfa/module/beatplan_stores_module/beat_plan_model.dart';
import 'package:i_densfa/module/campaign_module/campaign_model.dart';

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
  StoreDetailBloc(this.repo, this.beatPlanModel) : super(StoreDetailInitial()) {
    on<StoreDetailEvent>((event, emit) {});
    on(gotoCompaignEvent);
    on(_markOutStore);
    on(_checkInStore);
  }

  Future<void> gotoCompaignEvent(GotoCompaignEvent event, emit) async {
    emit(CompaignsLoadedStoreDetailState());
    // List<CampaignDetailModel> compaignsResponse =
    //     await repo.getCompaignList(event.storeId).catchError((onError) {
    //   emit(StoreDetailToastMessageState(onError.toString()));

    //   return <CampaignDetailModel>[];
    // });

    // final now = DateTime.now();
    // compaigns = compaignsResponse
    //     .where((element) =>
    //         element.startDate.isBefore(now) && element.endDate.isAfter(now))
    //     .toList();

    // if (compaigns.isNotEmpty) {
    //   emit(CompaignsLoadedStoreDetailState());
    // } else {
    //   emit(StoreDetailToastMessageState("No Campaign"));
    // }
  }

  Future<void> _checkInStore(
      MarkInStoreDetailEvent event, Emitter<StoreDetailState> emit) async {
    if (AppStorage().isMarkedIn != null &&
        AppStorage().isMarkedIn != beatPlanModel.storeId) {
      emit(StoreDetailToastMessageState(
          'You are already marked In for other store\nPlease mark Out first.'));
      return;
    }
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
            isIn: true,
            storeId: beatPlanModel.storeId)
        .catchError((error) {
      emit(StoreDetailToastMessageState(error.toString()));
      return Future<String>.error(error);
    });
    beatPlanModel.markin = true;
    AppStorage().isMarkedIn = beatPlanModel.storeId;
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
    AppStorage().isMarkedIn = null;
    emit(StoreDetailToastMessageState(response));
  }
}
