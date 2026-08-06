import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_densfa/module/promoter_module/feedback/feedback_model.dart';
import 'package:i_densfa/module/promoter_module/feedback/feedback_repository.dart';
import 'package:image_picker/image_picker.dart';

part 'feedback_event.dart';
part 'feedback_state.dart';

class FeedbackBloc extends Bloc<FeedbackEvent, FeedbackState> {
  final FeedbackRepository repo;
  FeedbackPorposeModel? selectedPurpose;
  String remarkAdded = "";
  XFile? selectedImage;

  List<FeedbackPorposeModel> purposes = [];

  FeedbackBloc(this.repo) : super(FeedbackInitial()) {
    on((SelectPurposeFeedbackEvent event, emit) {
      selectedPurpose =
          purposes.firstWhere((element) => element.name == event.purpose);
      emit(FeedbackInitial());
    });
    on((AddRemarkFeedbackEvent event, emit) {
      remarkAdded = event.remark;
      emit(FeedbackInitial());
    });
    on((FeedbackGetPurposesEvent event, emit) async {
      emit(FeedbackLoadingState());
      purposes = await repo.getFeedbackPurposes().catchError((onError) {
        emit(FeedbackErrorState(onError.toString()));
        return <FeedbackPorposeModel>[];
      });
      emit(FeedbackInitial());
    });
    on((ClickImageFeedbackEvent event, emit) async {
      final img = await ImagePicker().pickImage(
          source: kReleaseMode ? ImageSource.camera : ImageSource.gallery);
      if (img != null) {
        selectedImage = img;
        emit(FeedbackInitial());
      }
    });

    on((RemoveSelectedImageFeedbackEvent event, emit) {
      selectedImage = null;
      emit(FeedbackInitial());
    });

    on((FeedbackSaveEvent event, emit) async {
      if (selectedPurpose == null) {
        emit(FeedbackErrorState("Please select purpose"));
        return;
      }

      if (remarkAdded.trim().isEmpty) {
        emit(FeedbackErrorState("Please enter remarks"));
        return;
      }

      // if (selectedImage == null) {
      //   emit(FeedbackErrorState("Please click image"));
      //   return;
      // }
      emit(FeedbackLoadingState());
      final response = await repo
          .saveFeedback(
              selectedImage, selectedPurpose!.id, remarkAdded, event.storeName)
          .catchError((onError) {
        emit(FeedbackErrorState(onError.toString()));
        return false;
      });
      if (response) {
        emit(FeedbackErrorState("Feedback added successfully"));
        emit(FeedbackSuccessState());
      } else {
        emit(FeedbackInitial());
      }
    });
  }
}
