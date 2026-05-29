import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';

class HeroPhotoViewRouteWrapper extends StatelessWidget {
  const HeroPhotoViewRouteWrapper({
    super.key,
    required this.imageProvider,
    required this.tag,
    this.backgroundDecoration,
    this.minScale,
    this.maxScale,

  });

  final CachedNetworkImageProvider imageProvider;
  final BoxDecoration? backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;
  final String tag;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          constraints: BoxConstraints.expand(
            height: MediaQuery.of(context).size.height,
          ),
          child: PhotoView(
            imageProvider: imageProvider,
            backgroundDecoration: backgroundDecoration,
            minScale: minScale,
            maxScale: maxScale,
            heroAttributes: PhotoViewHeroAttributes(
              tag: tag,
              transitionOnUserGestures: true,
            ),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SafeArea(
                child: GestureDetector(
                  onTap: () async {
                    downloadFile(imageProvider.url);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).primaryColor),
                      child: const Center(child: Icon(Icons.download)),
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).primaryColor),
                      child: const Center(child: Icon(Icons.clear)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Future<void> downloadFile(String url) async {
    await _launchInBrowser(Uri.parse(url));
  }

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(url,
        mode: LaunchMode.externalApplication,
        webViewConfiguration: WebViewConfiguration(headers: {
          HttpHeaders.authorizationHeader: 'Bearer ${AppStorage().authToken}',
        }))) {
      throw Exception('Could not launch $url');
    }
  }
}
