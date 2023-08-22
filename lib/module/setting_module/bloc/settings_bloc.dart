import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_densfa/module/setting_module/settings_respository.dart';
import 'package:image_picker/image_picker.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final repo = SettingsRespository();

  SettingsBloc() : super(SettingsInitial()) {
    on((ChangeImageSettingsEvent event, emit) async {
      emit(ImageLoadingState());
      final response =
          await repo.updateProfilePic(event.imageFile).catchError((onError) {
        return onError.toString();
      });
      emit(SnackBarMessageSettingsState(response));
    });

    on((ChangeEmailPhoneSettingsEvent event, emit) {
      emit(EmailPhoneUpdatedSettingsState());
    });
  }
}
