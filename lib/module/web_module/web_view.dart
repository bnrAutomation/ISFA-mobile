import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:photo_view/photo_view.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AppWebView extends StatefulWidget {
  final String link;
  final String contentType;
  const AppWebView({super.key, required this.link,required this.contentType});

  @override
  State<AppWebView> createState() => _AppWebViewState();
}

class _AppWebViewState extends State<AppWebView> {
  double progress = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          bottom: PreferredSize(
              preferredSize: const Size.fromHeight(2),
              child: LinearProgressIndicator(
                value: progress,
              )),
        ),
        body: AppStorage().userDetail?.companyName.toLowerCase()=="BI Demo".toLowerCase()?
        PhotoView(
            imageProvider:  CachedNetworkImageProvider(widget.link
                                                      .trim(),
                                                ),
           
            minScale: PhotoViewComputedScale
                                                    .contained,
            maxScale: PhotoViewComputedScale
                                                    .covered,
            heroAttributes: const PhotoViewHeroAttributes(
              tag: "Doc Image",
              transitionOnUserGestures: true,
            ),
          ):
        widget.contentType.toLowerCase()=="pdf"?
        SfPdfViewer.network(
   widget.link
):
       
        
         WebViewWidget(controller: getController));
  }

  late WebViewController getController = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(const Color(0x00000000))
    ..setNavigationDelegate(
      NavigationDelegate(
        onProgress: (progress) {
          this.progress = progress.toDouble() / 100;
          setState(() {});
        },
        onPageStarted: (url) {},
        onPageFinished: (url) {},
        onWebResourceError: (error) {},
        onNavigationRequest: (request) {
          return NavigationDecision.navigate;
        },
      ),
    )
    ..loadRequest(

      Uri.parse(
        widget.link.contains("pdf")
        ? 'https://docs.google.com/gview?embedded=true&url=${widget.link}' :
        widget.contentType == "pdf" ? 'https://docs.google.com/gview?embedded=true&url=${widget.link}'
        : 
        widget.link
        
        ));
}
