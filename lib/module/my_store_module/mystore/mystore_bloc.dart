
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_densfa/module/my_schedule_module/beat_plan_model.dart';
import 'package:i_densfa/module/my_store_module/my_store_repository.dart' show MyStoreRepository;
import 'package:i_densfa/utility/app_storage.dart';

part 'mystore_event.dart';
part 'mystore_state.dart';

class MystoreBloc extends Bloc<MystoreEvent, MystoreState> {
  MyStoreRepository repository;
  bool isFromfilter=false;
  String filerValue="";
  int pageOffset=0;
  int pageCount=0;
  bool canpopbool =true;
  bool isLoad=false;
  List<BeatPlanModel> allPlans = [];
  List<BeatPlanModel> beatPlans = [];
  
  List<String> filledCampaignList = [];
  var isAccending = false;
  final userDetail = AppStorage().userDetail;
  ScrollController controller = ScrollController();
  MystoreBloc(this.repository) : super(MystoreInitial()) {
   // controller.addListener(_scrollListener);
    on<MyStoreUpdateData>((event, emit) async => await _getStoreList(event, emit));
    // on<GetNextIssuesEvent>((event, emit) async => await _getNextStoreList(event, emit));
    on<SearchMyStoreEvent>((event,emit){
        if (event.value.trim().isEmpty) beatPlans = allPlans;
            beatPlans = allPlans.where((element) =>
              element.storecode.toString().contains(event.value) ||
              element.storeId.toString().contains(event.value) ||
              element.storeName.toLowerCase().contains(event.value.toLowerCase()) ||
              element.pjpId.toString().toLowerCase().contains(event.value.toLowerCase())).toList();
              emit(MyStoreSussesfully());
     }
     //async=> await _getStoreListBySearch(event, emit)
     );
    // on<GetNextFilterStoreEvent>((event,emit)async=> await _getNextStoreListBySearch(event, emit));

    on<SortMyStoreEvent>((event,emit){
      if (isAccending) {
        isAccending = false;
        beatPlans.sort(
            (a, b) => a.storeName.compareTo(b.storeName));
      } else {
        isAccending = true;
        beatPlans.sort(
            (a, b) => b.storeName.compareTo(a.storeName));
      }
      emit(MyStoreSussesfully());
    });
    on(_getFilledCampaign);
  }

    Future<void> _getFilledCampaign(GetCampaignFilledEvent event, emit) async {
    if (!(userDetail?.configuration.requiresAllFillCampigned ?? false)) {
      return;
    }
    try {
      emit(LoadedFillCampainState());
      filledCampaignList = await repository.getFilledCampaign(event.store.storeId);
      canpopbool = await canpop(event.store);
    } catch (onError) {
      emit(MyStoreShowError(onError.toString()));
    }
  }


  // void _scrollListener() {
  //   if (controller.offset >= controller.position.maxScrollExtent &&
  //       !controller.position.outOfRange) {
  //     isFromfilter
  //         ? add(GetNextFilterStoreEvent(filerValue))
  //         : add(GetNextIssuesEvent());
  //   }
  // }

  Future<void>_getStoreList(MyStoreUpdateData event, Emitter<MystoreState> emit) async {
    try {
      emit(MyStoreLoadingState());
      pageOffset = 0;
      final queryParameters  ={
          'pageOffset': pageOffset.toString(),
          'pageSize': 25.toString()
        };
      final resposne = await repository.getBeatPlans(queryParameters);
      allPlans= resposne;
      beatPlans= resposne;
      // allPlans= resposnse.dataList;
      // pageCount = resposnse.totalPages;
      emit(MyStoreSussesfully());
    } catch (err) {
      emit(MyStoreShowError(err.toString()));
    }

  }

  Future<bool> canpop(BeatPlanModel store) async {
     if (userDetail?.configuration.requiresAllFillCampigned ?? false) {
      final list =
          await repository.getCampaignsForStore(store.storeId.toString());
      if (list.any((element) => !filledCampaignList.contains(element.uuid))) {
        // emit(StoreDetailToastMessageState(
        //     'Please fill all campaign before mark-out.'));
        // loading = false;
        return true;
      }else {
        return false;
      }
    }else {
      return false;
    }
  }
}
