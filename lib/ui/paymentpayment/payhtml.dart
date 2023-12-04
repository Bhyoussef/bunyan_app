

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentScreenhtml extends StatefulWidget {
  final String paymentUrl;
  final Map<String, String> paymentData;

  PaymentScreenhtml({
    Key key,
     this.paymentUrl,
     this.paymentData,
  }) : super(key: key);

  @override
  _PaymentScreenhtmlState createState() => _PaymentScreenhtmlState();
}

class _PaymentScreenhtmlState extends State<PaymentScreenhtml> {
  WebViewController _webViewController;
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment'),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            WebView(
              initialUrl: _getUrlWithQueryParams(),
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (controller) {
                _webViewController = controller;
              },
              onPageFinished: (url) {
                setState(() {
                  _isLoading = false;
                });
              },
            ),
            if (_isLoading) Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  String _getUrlWithQueryParams() {
    final queryParams = widget.paymentData.entries.map((entry) {
      return '${entry.key}=${Uri.encodeQueryComponent(entry.value)}';
    }).join('&');

    return '${widget.paymentUrl}?$queryParams';
  }
}
