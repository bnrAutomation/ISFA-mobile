import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AppWebView extends StatelessWidget {
  final String link;
  const AppWebView({super.key, required this.link});
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: WebViewWidget(controller: getController(link)));
  }

  WebViewController getController(String link) {
    link.contains("pdf");
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
      )
      ..loadRequest(Uri.parse(link.contains("pdf")
          ? "https://docs.google.com/gview?embedded=true&url=$link"
          : link));
  }
}
