import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'forgot_password_event.dart';
part 'forgot_password_state.dart';

class ForgotPasswordBloc
    extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  ForgotPasswordBloc() : super(ForgotPasswordInitial()) {
    on<ForgotPasswordEvent>((event, emit) {
      if (event is ChangeTextEvent) {
        if (event.useridValue.isEmpty) {
          emit(ForgotPasswordErrorState("Feild should not be empty."));
        } else {
          emit(ForgotPasswordValidState());
        }
      } else if (event is ForgotPasswordSubmitEvent) {
        if (event.userid.isEmpty) {
          emit(ForgotPasswordErrorState("Feild should not be empty."));
        } else {
          emit(ForgotPasswordSuccesfullState());
        }
      }
    });
  }
}
