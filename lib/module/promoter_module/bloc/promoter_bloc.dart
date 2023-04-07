import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:i_densfa/module/promoter_module/models/inventory_detail_model.dart';
import 'package:i_densfa/module/promoter_module/models/promoter_store_detail_model.dart';
import 'package:i_densfa/module/promoter_module/promoter_repository.dart';
import 'package:url_launcher/url_launcher_string.dart';

part 'promoter_event.dart';
part 'promoter_state.dart';

class PromoterBloc extends Bloc<PromoterEvent, PromoterState> {
  final PromoterRepository repo;

  InventoryDetailModel? inventoryDetail;
  PromoterStoreDetailModel? storeDetail;
  List<InventoryProductDetailModel> filteredList = [];

  PromoterBloc(this.repo) : super(PromoterInitial()) {
    on((GetInventoryDetailEvent event, emit) async =>
        await _getInventoryDetails(emit));
    on((GetStoreDetailEvent event, emit) async => await _getStoreDetails(emit));
    on((SearchByNamePromoterEvent event, emit) =>
        _filterProduct(event.name, emit));

    on((PromoterShowToastMessageEvent event, emit) =>
        emit(PromoterToastMessageState(event.message)));
    on(_checkInStore);

    on((GoToMapPromoterEvent event, emit) {
      final lat = storeDetail?.latitude ?? "";
      final long = storeDetail?.longtitude ?? "";
      final url = 'http://www.google.com/maps/place/$lat,$long';
      launchUrlString(url);
    });
  }

  Future<void> _checkInStore(
      PromoterCheckInStoreEvent event, Emitter<PromoterState> emit) async {
    if (storeDetail?.latitude == null) {
      emit(PromoterToastMessageState(
          'Unable to CheckIn.\nStore location is unknown'));
      return;
    }
    final storeLat = double.parse(storeDetail!.latitude!);
    final storeLong = double.parse(storeDetail!.longtitude!);
    emit(PromoterStoreDetailLoadingState());
    final loc = await _determinePosition().catchError((onError) {
      emit(PromoterToastMessageState(onError.toString()));
      return Future<Position>.error(onError);
    });

    final distanceMtrs = Geolocator.distanceBetween(
        loc.latitude, loc.longitude, storeLat, storeLong);
    emit(PromoterToastMessageState("Distance is $distanceMtrs"));
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

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}
