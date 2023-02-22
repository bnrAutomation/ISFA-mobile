import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'tabber_event.dart';
part 'tabber_state.dart';

class TabberBloc extends Bloc<TabberEvent, TabberState> {
  int selectIndex = 0;
  bool isOnline = false;
  TabberBloc() : super(TabberInitial()) {
    on<TabberEvent>((event, emit) {
      if (event is ChangeTabEvent) {
        selectIndex = event.selectIndex;
        emit(UpdateIndexState(selectIndex));
      } else if (event is UpdateOnlineStatusEvent) {
        isOnline = event.updatedStatus;
        emit(OnlineStatusUpdateState());
      }
    });
  }

  String tabTitle() {
    final titles = ['My Schedule', 'ISFA', 'ISFA', 'ISFA', 'ISFA'];
    return titles[selectIndex];
  }
}
