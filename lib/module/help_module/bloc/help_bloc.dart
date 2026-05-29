import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';

part 'help_event.dart';
part 'help_state.dart';

class HelpBloc extends Bloc<HelpEvent, HelpState> {
  String? selectedImagePath;
  String title = "";
  String description = "";
  String showDialogMessage = "";
  HelpBloc() : super(HelpInitial()) {
    on((ClickImageHelpEvent event, emit) async {
      selectedImagePath = event.imagePath;
      emit(HelpInitial());
    });

    on((RemoveSelectedImageHelpEvent event, emit) {
      selectedImagePath = null;
      emit(HelpInitial());
    });
    on((AddTitleHelpEvent event, emit) {
      title = event.title;
      emit(HelpInitial());
    });

    on((AddDescriptionHelpEvent event, emit) {
      description = event.description;
      emit(HelpInitial());
    });

    on(_saveHelp);
  }

  void _saveHelp(HelpSaveEvent event, Emitter<HelpState> emit) async {
    if (title.trim().isEmpty) {
      emit(HelpErrorState("Please enter subject"));
      return;
    }

    if (description.trim().isEmpty) {
      emit(HelpErrorState("Please enter body"));
      return;
    }

    if (selectedImagePath == null) {
      emit(HelpErrorState("Please add Image"));
      return;
    }

    emit(HelpLoadingState());
    final response = await _saveApi().catchError((onError) {
      emit(HelpErrorState(onError.toString()));
      return false;
    });
    if (response) {
      emit(HelpSuccessState());
    } else {
      emit(HelpInitial());
    }
  }

  Future<bool> _saveApi() async {
    final userId = AppStorage().userDetail!.id;
    final url = Uri.parse("${URLConstants.helpSupport}/$userId");
    final request = MultipartRequest('POST', url);
    request.headers.addAll({
      'Authorization': 'Bearer ${AppStorage().authToken}',
    });
    request.fields.addAll({
      'userId': userId.toString(),
      'description': description,
      'title': title,
      "activity": "help"
    });

    final multipartFile =
        await MultipartFile.fromPath('image', selectedImagePath!);
    request.files.add(multipartFile);

    final response = await request.send();
    String body = await response.stream.transform(utf8.decoder).join();

    if (response.statusCode == 200) {
      showDialogMessage = json.decode(body)['message'];
      return true;
    } else {
      final bod = jsonDecode(body);
      final String mess = bod['message'] ?? bod["error"];
      throw mess;
    }
  }
}
