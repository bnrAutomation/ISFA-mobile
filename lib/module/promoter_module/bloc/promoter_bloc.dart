import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_densfa/module/promoter_module/models/inventory_detail_model.dart';
import 'package:i_densfa/module/promoter_module/models/promoter_store_detail_model.dart';
import 'package:i_densfa/module/promoter_module/promoter_repository.dart';

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
}
