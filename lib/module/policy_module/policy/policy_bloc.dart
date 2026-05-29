import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';

part 'policy_event.dart';
part 'policy_state.dart';

class PolicyBloc extends Bloc<PolicyEvent, PolicyState> {
  final WebViewController webViewController;

  PolicyBloc(this.webViewController) : super(PolicyInitial()) {
    on<GetFile>((event, emit) async {
      await _getFilePath();
    });
  }

  Future<void> _getFilePath() async {
    await webViewController.loadFlutterAsset('assets/privacy.html');
  }
}
