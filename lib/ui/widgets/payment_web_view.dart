import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:sgela_sponsor_app/util/functions.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebView extends StatefulWidget {
  const PaymentWebView({super.key, required this.url});

  final String url;

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {

  late WebViewController webViewController;
  static const mm = ' 💚💚💚💚 PaymentWebView  💚💚';
  @override
  void initState() {
    super.initState();
    _setController();
  }

  _setController() {
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {
            pp('$mm ... onPageStarted ... url: $url');
          },
          onPageFinished: (String url) {
            pp('$mm ... onPageFinished... url: $url');
            //Navigator.of(context).pop(true);
          },
          onWebResourceError: (WebResourceError error) {
            pp('$mm ... onWebResourceError ... error: ${error.description}');
            Navigator.of(context).pop(false);
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: ScreenTypeLayout.builder(
        mobile: (_) {
          return  Stack(
            children: [
              Column(
                children: [
                  const Text('Sponsorship Payment Text'),
                  Expanded(child: WebViewWidget(controller: webViewController))
                ],
              )
            ],
          );
        },
        tablet: (_) {
          return const Stack();
        },
        desktop: (_) {
          return const Stack();
        },
      ),
    ));
  }
}
