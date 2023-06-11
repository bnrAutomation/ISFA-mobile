import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  String userImageLink =
      'https://tastevibe.web.app/assets/images/placeholder-user.png';

  SettingsBloc() : super(SettingsInitial()) {
    on((ChangeImageSettingsEvent event, emit) {});
    on((ChangeEmailSettingsEvent event, emit) async {
      final bool emailValid = RegExp(
              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
          .hasMatch(event.email);
      if (event.email.trim().isEmpty) {
        emit(SnackBarMessageSettingsState("Please enter email"));
      } else if (!emailValid) {
        emit(
            SnackBarMessageSettingsState("Please enter a valid email address"));
      } else {
        await _saveEmailAddress(event.email, emit);
      }
    });
    on((ChangePhoneSettingsEvent event, emit) async {
      if (event.phone.trim().isEmpty) {
        emit(SnackBarMessageSettingsState("Please enter number"));
      } else if (double.tryParse(event.phone) == null) {
        emit(SnackBarMessageSettingsState("Please enter valid number"));
      } else {
        await _savePhoneAddress(event.phone, emit);
      }
    });
  }

  Future<void> _saveEmailAddress(
      String email, Emitter<SettingsState> emit) async {}

  Future<void> _savePhoneAddress(
      String phone, Emitter<SettingsState> emit) async {}
}
