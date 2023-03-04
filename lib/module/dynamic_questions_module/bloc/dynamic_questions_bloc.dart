import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'dynamic_questions_event.dart';
part 'dynamic_questions_state.dart';

class DynamicQuestionsBloc extends Bloc<DynamicQuestionsEvent, DynamicQuestionsState> {
  DynamicQuestionsBloc() : super(DynamicQuestionsInitial()) {
    on<DynamicQuestionsEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
