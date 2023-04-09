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
  bool isOnline = false;
  SideMenuModel? sideMenuData;
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

  String tabTitle() {
    final titles = ['My Schedule', 'ISFA', 'ISFA', 'ISFA', 'ISFA'];
    return titles[selectIndex];
  }

  Future<void> _getSideMenuData(Emitter<TabberState> emit) async {
    sideMenuData = await repo.getSideMenuDetails().catchError((onError) {
      emit(TabbarSnackBarMessageState(onError.toString()));
      return Future<SideMenuModel>.error(onError);
    });
    AppStorage().homeInfo = sideMenuData;
    emit(state);
  }

  Future<void> _startDuty(StartDutyStatusTabberEvent event, emit) async {
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
      return onError.toString();
    });

    isOnline = true;
    emit(TabbarSnackBarMessageState(response));
    emit(OnlineStatusUpdateState());
  }

  Future<void> _endDuty(EndDutyStatusTabberEvent event, emit) async {
    final loc = await Device().userPosition().onError((error, stackTrace) {
      emit(TabbarSnackBarMessageState(error.toString()));
      throw error ?? stackTrace;
    });

    if (event.file == null) {
      emit(TabbarSnackBarMessageState("Please add image"));
    }
    final response = await repo
        .startEndDuty(event.file!, loc.latitude, loc.longitude, false)
        .catchError((onError) {
      return onError.toString();
    });

    isOnline = false;
    emit(TabbarSnackBarMessageState(response));
    emit(OnlineStatusUpdateState());
  }
}
