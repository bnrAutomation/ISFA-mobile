import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_densfa/module/policy_module/policy/policy_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PolicyView extends StatelessWidget {
  const PolicyView({super.key});

  WebViewController getController() {
    return WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    WebViewController webViewController = getController();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(title: const Text("Policy")),
      body: BlocProvider(
        create: (context) => PolicyBloc(webViewController)..add(GetFile()),
        child: BlocBuilder<PolicyBloc, PolicyState>(
          builder: (context, state) =>
              WebViewWidget(controller: webViewController),
        ),
      ),
    );
  }
}
