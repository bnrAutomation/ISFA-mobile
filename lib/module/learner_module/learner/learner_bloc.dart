import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_densfa/module/learner_module/learner/model/learner_model.dart';
import 'package:i_densfa/module/learner_module/learner_repository.dart';
import 'package:i_densfa/utility/app_storage.dart';

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
    // debugPrint(AppStorage().homeInfo?.userInfo.companyName.toString());
    await repo.getLearner().then((value) {
      if (AppStorage().homeInfo?.userInfo.companyName == "Mobil") {
        dataList = value.dataList
            .where((element) => element.clientId == "EXXON")
            .toList();
      } else if (AppStorage().homeInfo?.userInfo.companyName ==
          "BrotherInternational") {
        dataList = value.dataList
            .where((element) => element.clientId == "BROTHER-INTERNATIONAL")
            .toList();
      } else if (AppStorage().homeInfo?.userInfo.companyName == "HUL") {
        dataList = value.dataList
            .where((element) => element.clientId == "VIVO")
            .toList();
      }  else if (AppStorage().homeInfo?.userInfo.companyName.toLowerCase() == "amazon") {
        dataList = value.dataList
            .where((element) => element.clientId == "amazon")
            .toList();
      } else {
        dataList = value.dataList;
      }
      emit(LearnerLoadedState());
    }).catchError((err) {
      emit(LearnerToastMessageState(err.toString()));
    });
  }
}
