import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Bundled policy document (pdf2htmlEX export). Must match [pubspec.yaml] assets.
const String _policyAssetPath = 'assets/privacy.html';

class PolicyView extends StatefulWidget {
  const PolicyView({super.key});

  @override
  State<PolicyView> createState() => _PolicyViewState();
}

class _PolicyViewState extends State<PolicyView> {
  WebViewController? _controller;
  double _progress = 0;
  String? _errorMessage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  Future<void> _initWebView() async {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (!mounted) return;
            setState(() => _progress = progress / 100);
          },
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() {
              _isLoading = false;
              _errorMessage = null;
            });
          },
          onWebResourceError: (error) {
            if (!mounted) return;
            if (error.isForMainFrame != false) {
              setState(() {
                _isLoading = false;
                _errorMessage = error.description;
              });
            }
          },
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            if (uri == null) return NavigationDecision.prevent;
            if (uri.scheme == 'http' ||
                uri.scheme == 'https' ||
                uri.scheme == 'mailto' ||
                uri.scheme == 'file' ||
                uri.scheme == 'about') {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      );

    if (!mounted) return;
    setState(() => _controller = controller);
    await _loadPolicy(controller);
  }

  /// Large local HTML (pdf2htmlEX) must load from a file/asset URL — not
  /// [WebViewController.loadHtmlString], which often shows a blank page on Android.
  Future<void> _loadPolicy(WebViewController controller) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await controller.loadFlutterAsset(_policyAssetPath);
      return;
    } catch (_) {
      // Fall through to file-based load.
    }

    try {
      final bytes = await rootBundle.load(_policyAssetPath);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/privacy_policy.html');
      await file.writeAsBytes(
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
        flush: true,
      );
      await controller.loadRequest(Uri.file(file.path));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Unable to open the policy document. Please try again.\n($e)';
      });
    }
  }

  Future<void> _retry() async {
    final controller = _controller;
    if (controller == null) {
      await _initWebView();
      return;
    }
    await _loadPolicy(controller);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = _controller;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Policy'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: _isLoading && _progress < 1
              ? LinearProgressIndicator(value: _progress)
              : const SizedBox(height: 2),
        ),
      ),
      body: _errorMessage != null
          ? _PolicyErrorBody(
              message: _errorMessage!,
              onRetry: _retry,
            )
          : controller == null
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                  children: [
                    WebViewWidget(controller: controller),
                    if (_isLoading && _progress < 0.99)
                      const Center(child: CircularProgressIndicator()),
                  ],
                ),
    );
  }
}

class _PolicyErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _PolicyErrorBody({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Policy unavailable',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
