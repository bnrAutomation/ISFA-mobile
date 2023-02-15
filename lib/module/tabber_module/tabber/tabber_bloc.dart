import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'tabber_event.dart';
part 'tabber_state.dart';

class TabberBloc extends Bloc<TabberEvent, TabberState> {
  int selectIndex = 0;
  TabberBloc() : super(TabberInitial()) {
    on<TabberEvent>((event, emit) {
      if (event is ChangeTabEvent) {
        selectIndex = event.selectIndex;
        emit(UpdateIndexState(selectIndex));
      }
    });
  }
}
