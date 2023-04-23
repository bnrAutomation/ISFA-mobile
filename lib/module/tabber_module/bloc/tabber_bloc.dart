import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_densfa/module/tabber_module/models/side_menu_model.dart';
import 'package:i_densfa/module/tabber_module/tabbar_repository.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/device_helper.dart';
import 'package:image_picker/image_picker.dart';

part 'tabber_event.dart';
part 'tabber_state.dart';

class TabberBloc extends Bloc<TabberEvent, TabberState> {
  final TabbarRepository repo;
  int selectIndex = 0;
  SideMenuModel? sideMenuData;
  var tabberItems = TabbarItemCase.values.toList();
  TabberBloc(this.repo) : super(TabberInitial()) {
    on<TabberEvent>((event, emit) {
      if (event is ChangeTabEvent) {
        selectIndex = event.selectIndex;
        emit(UpdateIndexState(selectIndex));
      }
    });

    on((UpdateSideMenuDetailsEvent event, emit) async =>
        await _getSideMenuData(emit));
    on(_endDuty);
    on(_startDuty);
  }

  Future<void> _getSideMenuData(Emitter<TabberState> emit) async {
    var data = await repo.getSideMenuDetails().catchError((onError) {
      emit(TabbarSnackBarMessageState(onError.toString()));
      return Future<SideMenuModel>.error(onError);
    });
    if (data.userInfo.designation.toLowerCase() != 'promoter') {
      data.menu.removeWhere((element) => element.key == 'promoter');
    } else {
      tabberItems.removeWhere((element) => element == TabbarItemCase.schedule);
    }
    sideMenuData = data;
    AppStorage().markedInStoreId = data.userInfo.markInStoreId;
    AppStorage().isDutyStarted = data.userInfo.startDuty;
    AppStorage().homeInfo = sideMenuData;
    emit(state);
  }

  Future<void> _startDuty(StartDutyStatusTabberEvent event, emit) async {
    if (AppStorage().markedInStoreId != null) {
      emit(TabbarSnackBarMessageState("Please mark-out from the store first"));
      return;
    }

    final loc = await Device().userPosition().onError((error, stackTrace) {
      emit(TabbarSnackBarMessageState(error.toString()));
      throw error ?? stackTrace;
    });

    if (event.file == null) {
      emit(TabbarSnackBarMessageState("Please add image"));
    }
    final response = await repo
        .startEndDuty(event.file!, loc.latitude, loc.longitude, true)
        .catchError((onError) {
      emit(TabbarSnackBarMessageState(onError.toString()));
      return Future<String>.error(onError);
    });

    AppStorage().isDutyStarted = true;
    emit(TabbarSnackBarMessageState(response));
    emit(OnlineStatusUpdateState());
  }

  Future<void> _endDuty(EndDutyStatusTabberEvent event, emit) async {
    if (AppStorage().markedInStoreId != null) {
      emit(TabbarSnackBarMessageState('Please Markout from store first'));
      return;
    }
    final loc = await Device().userPosition().catchError((error) {
      emit(TabbarSnackBarMessageState(error.toString()));
      throw error;
    });

    if (event.file == null) {
      emit(TabbarSnackBarMessageState("Please add image"));
    }
    final response = await repo
        .startEndDuty(event.file!, loc.latitude, loc.longitude, false)
        .catchError((onError) {
      emit(TabbarSnackBarMessageState(onError.toString()));
      return Future<String>.error(onError);
    });

    AppStorage().isDutyStarted = false;
    emit(TabbarSnackBarMessageState(response));
    emit(OnlineStatusUpdateState());
  }
}
