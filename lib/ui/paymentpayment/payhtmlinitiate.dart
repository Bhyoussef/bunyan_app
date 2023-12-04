import 'dart:convert';


import 'package:bunyan/ui/paymentpayment/payhtml.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

import '../../tools/res.dart';

class InitiatePaymentPagepayment extends StatefulWidget {
  @override
  _InitiatePaymentPagepaymentState createState() => _InitiatePaymentPagepaymentState();
}

class _InitiatePaymentPagepaymentState extends State<InitiatePaymentPagepayment> {
  String _paymentUrl;
  Map<String, String> _paymentData = {};

  @override
  void initState() {
    super.initState();
    _initiatePayment();
  }

  void _initiatePayment() async {
    final response = await http.get(Uri.parse('https://bunyan.qa/api/proceed-property-payment'),
      headers: {
      'accept': 'application/json',
      'Authorization': 'Bearer ${Res.token}'
    },);
    if (response.statusCode == 200) {
      final htmlResponse = response.body;
      final pattern = RegExp('name="([^"]*)".*?value="([^"]*)"');
      final matches = pattern.allMatches(htmlResponse);

      final data = <String, String>{};
      for (Match match in matches) {
        final name = match.group(1);
        final value = match.group(2);
        data[name] = value;
      }

      setState(() {
        _paymentUrl = 'https://sadadqa.com/webpurchase';
        _paymentData = data;
      });
    } else {
      throw Exception('Failed to load payment data');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_paymentData == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return PaymentScreen(
        paymentUrl: _paymentUrl,
        paymentData: _paymentData,
      );
    }
  }
}

class PaymentScreen extends StatelessWidget {
  final String paymentUrl;
  final Map<String, String> paymentData;

  PaymentScreen({this.paymentUrl, this.paymentData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebView(
        initialUrl: paymentUrl,
        javascriptMode: JavascriptMode.unrestricted,
        onPageFinished: (url) {
          if (url.contains('/property-payment-response')) {
            Navigator.of(context).pop();
          }
        },
        navigationDelegate: (NavigationRequest request) {
          if (request.url.contains('/property-payment-response')) {
            Navigator.of(context).pop();
            return NavigationDecision.prevent;
          } else {
            return NavigationDecision.navigate;
          }
        },
      ),
    );
  }
}
