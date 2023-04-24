import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_densfa/module/my_activity_module/model/my_activity_model.dart';
import 'package:i_densfa/module/my_activity_module/my_activity_repository.dart';

part 'my_activity_event.dart';
part 'my_activity_state.dart';

class MyActivityBloc extends Bloc<MyActivityEvent, MyActivityState> {
  List<MyActivityDataList> dataList = [];
  DateTime selected = DateTime.now();
  MyActivityRepository repo;

  MyActivityBloc(this.repo) : super(MyActivityInitial()) {
    on<MyActivityEvent>((event, emit) {});
    on<GetMyAcivityEvent>(
        (event, emit) async => await _getMyActivity(emit, selected));
    on<MyActivityChangeMonth>((event, emit) => {
          selected = event.date,
          emit(MyAcivityMonthChangeState()),
          add(GetMyAcivityEvent())
        });
  }

  _getMyActivity(Emitter<MyActivityState> emit, DateTime selected) async {
    emit(MyActivityLoadingState());

    dataList = await repo.getMyActivity(dateTime: selected).catchError((error) {
      emit(MyActivityWithData());
      emit(MyActivityShowSnack(error.toString()));
      return <MyActivityDataList>[];
    });

    emit(MyActivityWithData());
  }
}
