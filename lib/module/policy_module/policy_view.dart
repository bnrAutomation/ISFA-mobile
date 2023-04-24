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

  // _loadHtmlFromAssets(WebViewController controller) async {
  //   String fileText = await rootBundle.loadString('assets/privacy.html');
  //   controller.loadHtmlString(fileText);
  //   // controller.loadUrl( Uri.dataFromString(
  //   //     fileText,
  //   //     mimeType: 'text/html',
  //   //     encoding: Encoding.getByName('utf-8')
  //   // ).toString());
  // }

  @override
  Widget build(BuildContext context) {
    WebViewController webViewController = getController();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Policy",
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(color: Colors.white),
        ),
      ),
      body: BlocProvider(
        create: (context) => PolicyBloc(webViewController)..add(GetFile()),
        child: BlocBuilder<PolicyBloc, PolicyState>(
          builder: (context, state) {
            return WebViewWidget(controller: webViewController);
          },
        ),
      ),
    );
  }
}
