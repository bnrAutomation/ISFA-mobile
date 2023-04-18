import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:i_densfa/module/campaign_module/campaign_model.dart';

import 'package:i_densfa/module/promoter_module/models/inventory_detail_model.dart';
import 'package:i_densfa/module/promoter_module/models/promoter_store_detail_model.dart';
import 'package:i_densfa/module/promoter_module/promoter_repository.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/device_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher_string.dart';

part 'promoter_event.dart';
part 'promoter_state.dart';

class PromoterBloc extends Bloc<PromoterEvent, PromoterState> {
  final PromoterRepository repo;

  InventoryDetailModel? inventoryDetail;
  PromoterStoreDetailModel? storeDetail;
  List<InventoryProductDetailModel> filteredList = [];
  List<CampaignDetailModel> compaigns = [];
  PromoterBloc(this.repo) : super(PromoterInitial()) {
    on((GetInventoryDetailEvent event, emit) async =>
        await _getInventoryDetails(emit));
    on((GetStoreDetailEvent event, emit) async => await _getStoreDetails(emit));
    on((SearchByNamePromoterEvent event, emit) =>
        _filterProduct(event.name, emit));

    on((PromoterShowToastMessageEvent event, emit) =>
        emit(PromoterToastMessageState(event.message)));
    on(_checkInStore);
    on(_markOutStore);
    on((GoToMapPromoterEvent event, emit) {
      final lat = storeDetail?.latitude ?? "";
      final long = storeDetail?.longtitude ?? "";
      final url = 'http://www.google.com/maps/place/$lat,$long';
      launchUrlString(url);
    });

    on(gotoCompaignEvent);
  }

  bool get isMarkedIn =>
      AppStorage().isMarkedIn != null &&
      AppStorage().isMarkedIn == storeDetail?.storeId;

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
    if (storeDetail?.storeId == null) {
      emit(PromoterToastMessageState('Store not found'));
      return;
    }

    emit(PromoterStoreDetailLoadingState());
    final loc = await Device().userPosition().catchError((onError) {
      emit(PromoterToastMessageState(onError.toString()));
      emit(PromoterStoreDetailLoadedState());
      return Future<Position>.error(onError);
    });

    final img = await ImagePicker().pickImage(source: ImageSource.camera);
    if (img == null) {
      emit(PromoterToastMessageState('Please click image'));
      emit(PromoterStoreDetailLoadedState());
      return;
    }

    final response = await repo
        .markInOutStore(
            img, loc.latitude, loc.longitude, storeDetail!.storeId, false)
        .catchError((error) {
      emit(PromoterToastMessageState(error.toString()));
      return Future<String>.error(error);
    });

    emit(PromoterToastMessageState(response));
    AppStorage().isMarkedIn = null;
    emit(PromoterStoreDetailLoadedState());
  }

  Future<void> _checkInStore(
      PromoterCheckInStoreEvent event, Emitter<PromoterState> emit) async {
    if (storeDetail?.storeId == null) {
      emit(PromoterToastMessageState('Store not found'));
      return;
    }
    if (!AppStorage().isDutyStarted) {
      emit(PromoterToastMessageState('Please start your Duty first'));
      return;
    }
    emit(PromoterStoreDetailLoadingState());
    final loc = await Device().userPosition().catchError((onError) {
      emit(PromoterToastMessageState(onError.toString()));
      emit(PromoterStoreDetailLoadedState());
      return Future<Position>.error(onError);
    });

    final img = await ImagePicker().pickImage(source: ImageSource.camera);
    if (img == null) {
      emit(PromoterToastMessageState('Please click image'));
      emit(PromoterStoreDetailLoadedState());
      return;
    }

    final response = await repo
        .markInOutStore(
            img, loc.latitude, loc.longitude, storeDetail!.storeId, true)
        .catchError((error) {
      emit(PromoterToastMessageState(error.toString()));
      return Future<String>.error(error);
    });

    emit(PromoterToastMessageState(response));
    AppStorage().isMarkedIn = storeDetail!.storeId;
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
      AppStorage().isMarkedIn = value.markIn ? value.storeId : null;
      emit(PromoterStoreDetailLoadedState());
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
}
