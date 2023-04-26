import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class AppWebView extends StatelessWidget {
  final String link;
  const AppWebView({super.key, required this.link});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: link.contains("pdf")
            ? SfPdfViewer.network(link,
                canShowScrollHead: false, canShowScrollStatus: false)

            //  PDF(pageSnap: false, autoSpacing: false).cachedFromUrl(
            //     link,
            //     placeholder: (progress) => Center(child: Text('$progress %')),
            //     errorWidget: (error) => Center(child: Text(error.toString())),
            //   )
            : WebViewWidget(controller: getController(link)));
  }

  WebViewController getController(String link) {
    return WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {},
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
