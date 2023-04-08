import 'package:flutter/foundation.dart';
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
    on(_markOffLine);
    on(_markOnLine);
  }

  String tabTitle() {
    final titles = ['My Schedule', 'ISFA', 'ISFA', 'ISFA', 'ISFA'];
    return titles[selectIndex];
  }

  Future<void> _getSideMenuData(Emitter<TabberState> emit) async {
    sideMenuData = await repo.getSideMenuDetails();
    AppStorage().homeInfo = sideMenuData;
    emit(state);
  }

  Future<void> _markOnLine(StartDutyStatusTabberEvent event, emit) async {
    final loc = await Device().userPosition().onError((error, stackTrace) {
      emit(TabbarSnackBarMessageState(error.toString()));
      throw error ?? stackTrace;
    });

    if (event.file == null) {
      emit(TabbarSnackBarMessageState("Please add image"));
    }
    final response = await repo
        .startDuty(event.file!, loc.latitude, loc.longitude)
        .catchError((onError) {
      emit(TabbarSnackBarMessageState(onError.toString()));
      return false;
    });

    isOnline = response;
    emit(OnlineStatusUpdateState());
  }

  Future<void> _markOffLine(EndDutyStatusTabberEvent event, emit) async {
    final loc = await Device().userPosition().onError((error, stackTrace) {
      emit(TabbarSnackBarMessageState(error.toString()));
      throw error ?? stackTrace;
    });

    final response =
        await repo.endDuty(loc.latitude, loc.longitude).catchError((onError) {
      emit(TabbarSnackBarMessageState(onError.toString()));
      return false;
    });

    isOnline = !response;
    emit(OnlineStatusUpdateState());
  }
}
