import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_densfa/module/my_activity_module/model/my_activity_model.dart';
import 'package:i_densfa/module/my_activity_module/my_activity_repository.dart';

part 'my_activity_event.dart';
part 'my_activity_state.dart';

class MyActivityBloc extends Bloc<MyActivityEvent, MyActivityState> {
  List<MyActivityDataList> activityList = []; 
  List<MyActivityDataList> tempActivityList = []; 
  DateTime selected = DateTime.now();
  MyActivityRepository repo;

  MyActivityBloc(this.repo) : super(MyActivityInitial()) {
    on<MyActivityEvent>((event, emit) {});
    on<GetMyAcivityEvent>(
        (event, emit) async => await _getMyActivity(emit, selected));
    on<MyActivityChangeMonth>((event, emit) {
      selected = event.date;
      emit(MyAcivityMonthChangeState());
      add(GetMyAcivityEvent());
    });

     on((SearchActivityEvent event, emit) {
     
if (event.searchText.trim().isEmpty) activityList = tempActivityList;
      activityList = tempActivityList
          .where((element) =>
              element.storeName
                  .toLowerCase()
                  .contains(event.searchText.toLowerCase()) ||
              element.activityName.toLowerCase().toString().contains(event.searchText))
          .toList();
      emit(MyActivityWithData());
    });
  }

  _getMyActivity(Emitter<MyActivityState> emit, DateTime selected) async {
    emit(MyActivityLoadingState());

    activityList = await repo.getMyActivity(dateTime: selected).catchError((error) {
      emit(MyActivityWithData());
      emit(MyActivityShowSnack(error.toString()));
      return <MyActivityDataList>[];
    });

    tempActivityList=activityList;

    emit(MyActivityWithData());
  }
}
