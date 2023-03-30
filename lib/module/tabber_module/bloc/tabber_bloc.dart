import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_densfa/module/tabber_module/models/side_menu_model.dart';
import 'package:i_densfa/module/tabber_module/tabbar_repository.dart';

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
      } else if (event is UpdateOnlineStatusEvent) {
        isOnline = event.updatedStatus;
        emit(OnlineStatusUpdateState());
      }
    });

    on((UpdateSideMenuDetailsEvent event, emit) async =>
        await _getSideMenuData(emit));
  }

  String tabTitle() {
    final titles = ['My Schedule', 'ISFA', 'ISFA', 'ISFA', 'ISFA'];
    return titles[selectIndex];
  }

  Future<void> _getSideMenuData(Emitter<TabberState> emit) async {
    sideMenuData = await repo.getSideMenuDetails();
    emit(state);
  }
}
