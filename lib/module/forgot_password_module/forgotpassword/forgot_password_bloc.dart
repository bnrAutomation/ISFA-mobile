import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_densfa/module/forgot_password_module/forget_password_repository.dart';

part 'forgot_password_event.dart';
part 'forgot_password_state.dart';

class ForgotPasswordBloc
    extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  final ForgotPasswordRepository repo;
  ForgotPasswordBloc(this.repo) : super(ForgotPasswordInitial()) {
    on<ChangeTextEvent>((event, emit) {
      emit(ForgotPasswordValidState());
    });
    on<ForgotPasswordSubmitEvent>((event, emit) async {
      if (event.userid.isEmpty) {
        emit(ForgotPasswordErrorState("Please enter your registered email"));
      } else {
        try {
          emit(ForgotPasswordLoadingState());
          final forgotPasswordResponse =
              await repo.forgotPassword(username: event.userid);
          emit(ForgotPasswordSuccesfullState(
              event.userid, forgotPasswordResponse.message));
        } catch (err) {
          emit(ForgotPasswordErrorState(err.toString()));
        }
      }
    });
  }
}
