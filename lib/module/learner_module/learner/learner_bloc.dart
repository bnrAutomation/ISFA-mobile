import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_densfa/module/learner_module/learner/model/learner_model.dart';
import 'package:i_densfa/module/learner_module/learner_repository.dart';

part 'learner_event.dart';
part 'learner_state.dart';

class LearnerBloc extends Bloc<LearnerEvent, LearnerState> {
  LearnerRepository repo;
  List<LearnerDataList> dataList = [];
  LearnerBloc(this.repo) : super(LearnerInitial()) {
    on<LearnerEvent>((event, emit) {});
    on((GetLearner event, emit) async => await _getLearner(emit));
  }

  Future<void> _getLearner(Emitter<LearnerState> emit) async {
    emit(LearnerLoadingState());
    await repo.getLearner().then((value) {
      dataList = value.dataList;
      emit(LearnerLoadedState());
    }).catchError((err) {
      emit(LearnerToastMessageState(err.toString()));
    });
  }
}
