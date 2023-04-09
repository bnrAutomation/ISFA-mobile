import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_densfa/module/promoter_module/models/compaigns_model.dart';
import 'package:i_densfa/module/store_detail_module/store_detail_repositry.dart';

part 'store_detail_event.dart';
part 'store_detail_state.dart';

class StoreDetailBloc extends Bloc<StoreDetailEvent, StoreDetailState> {
  List<CompaignsModel> compaigns = [];
  final StoreDetailRepository repo;
  StoreDetailBloc(this.repo) : super(StoreDetailInitial()) {
    on<StoreDetailEvent>((event, emit) {});
    on(gotoCompaignEvent);
  }

  Future<void> gotoCompaignEvent(GotoCompaignEvent event, emit) async {
    compaigns = await repo.getCompaignList(event.storeId).catchError((onError) {
      emit(StoreDetailToastMessageState(onError.toString()));
      return <CompaignsModel>[];
    });

    if (compaigns.isNotEmpty) {
      emit(CompaignsLoadedStoreDetailState());
    } else {
      emit(StoreDetailToastMessageState("No Campaign"));
    }
  }
}
