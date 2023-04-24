import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';

part 'policy_event.dart';
part 'policy_state.dart';

class PolicyBloc extends Bloc<PolicyEvent, PolicyState> {
  String fileText = "";
  WebViewController webViewController;
  PolicyBloc(this.webViewController) : super(PolicyInitial()) {
    on<GetFile>((event, emit) async {
      await _getFilePath();
    });
  }

  Future<void> _getFilePath() async {
    fileText = await rootBundle.loadString('assets/privacy.html');
    webViewController.loadHtmlString(fileText);
  }
}
