import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'change_email_phone_event.dart';
part 'change_email_phone_state.dart';

class ChangeEmailPhoneBloc
    extends Bloc<ChangeEmailPhoneEvent, ChangeEmailPhoneState> {
  ChangeEmailPhoneBloc() : super(ChangeEmailPhoneInitial()) {
    on<ChangeEmailPhoneEvent>((event, emit) {});
  }
}
