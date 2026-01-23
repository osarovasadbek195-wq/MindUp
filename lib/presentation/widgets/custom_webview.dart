import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomWebView extends StatefulWidget {
  final String url;
  final String title;
  final bool showHelpButton;
  final VoidCallback? onHelpPressed;

  const CustomWebView({
    super.key,
    required this.url,
    required this.title,
    this.showHelpButton = true,
    this.onHelpPressed,
  });

  @override
  State<CustomWebView> createState() => _CustomWebViewState();
}

class _CustomWebViewState extends State<CustomWebView> {
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;
  double progress = 0;
  bool isLoading = true;
  bool canGoBack = false;
  bool canGoForward = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            if (canGoBack) {
              await webViewController?.goBack();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        actions: [
          if (canGoBack)
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => webViewController?.goBack(),
            ),
          if (canGoForward)
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: () => webViewController?.goForward(),
            ),
          if (widget.showHelpButton)
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: widget.onHelpPressed ?? () {
                _showHelpDialog();
              },
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => webViewController?.reload(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          if (isLoading)
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
            ),
          
          // WebView
          Expanded(
            child: InAppWebView(
              key: webViewKey,
              initialUrlRequest: URLRequest(url: WebUri(widget.url)),
              initialSettings: InAppWebViewSettings(
                domStorageEnabled: true,
                javaScriptEnabled: true,
                useShouldOverrideUrlLoading: true,
                mediaPlaybackRequiresUserGesture: false,
                allowsInlineMediaPlayback: true,
                // AdBlocker - Basic ad blocking
                resourceCustomSchemes: ['mailto', 'tel'],
                blockNetworkLoads: false,
                // User agent
                userAgent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
              ),
              onWebViewCreated: (controller) {
                webViewController = controller;
              },
              onLoadStart: (controller, url) {
                setState(() {
                  isLoading = true;
                });
              },
              onProgressChanged: (controller, progress) {
                setState(() {
                  this.progress = progress / 100;
                });
              },
              onLoadStop: (controller, url) async {
                setState(() {
                  isLoading = false;
                });
                
                // Check navigation state
                final canGoBack = await controller.canGoBack();
                final canGoForward = await controller.canGoForward();
                setState(() {
                  this.canGoBack = canGoBack;
                  this.canGoForward = canGoForward;
                });
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                final url = navigationAction.request.url;
                
                // Handle special schemes
                if (url != null) {
                  if (url.scheme == 'mailto') {
                    await launchUrl(url);
                    return NavigationActionPolicy.CANCEL;
                  }
                  if (url.scheme == 'tel') {
                    await launchUrl(url);
                    return NavigationActionPolicy.CANCEL;
                  }
                }
                
                return NavigationActionPolicy.ALLOW;
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        mini: true,
        onPressed: () async {
          if (canGoBack) {
            await webViewController?.goBack();
          } else {
            _showExitDialog();
          }
        },
        backgroundColor: const Color(0xFF3B82F6),
        child: const Icon(Icons.arrow_back, color: Colors.white),
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit'),
        content: const Text('Are you sure you want to exit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Use back button or swipe to go back'),
            SizedBox(height: 8),
            Text('• Press refresh button to reload'),
            SizedBox(height: 8),
            Text('• Use help button for assistance'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
