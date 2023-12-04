import 'package:bunyan/tools/webservices/products.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';


class InitiatePaymentPage extends StatefulWidget {
  @override
  State<InitiatePaymentPage> createState() => _InitiatePaymentPageState();
}

class _InitiatePaymentPageState extends State<InitiatePaymentPage> {
  WebViewController controller;
  ProductsWebService _paymentService = ProductsWebService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPaymentPage();
  }

  Future<void> _loadPaymentPage() async {
    final formData = await _paymentService.initiatePayment();
    setState(() {
      _isLoading = false;
      print(formData);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: ProductsWebService().initiatePayment(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data;
            return WebView(
              initialUrl: 'https://sadadqa.com/webpurchase',
              javascriptMode: JavascriptMode.unrestricted,
              onPageFinished: (String url) {
                if (url == 'https://sadadqa.com/webpurchase') {
                  final script = '''
                    document.getElementById('merchant_id').value = '${data['merchant_id']}';
                    document.getElementById('ORDER_ID').value = '${data['ORDER_ID']}';
                    document.getElementById('WEBSITE').value = '${data['WEBSITE']}';
                    document.getElementById('TXN_AMOUNT').value = '${data['TXN_AMOUNT']}';
                    document.getElementById('CUST_ID').value = '${data['CUST_ID']}';
                    document.getElementById('EMAIL').value = '${data['EMAIL']}';
                    document.getElementById('MOBILE_NO').value = '${data['MOBILE_NO']}';
                    document.getElementById('CALLBACK_URL').value = '${data['CALLBACK_URL']}';
                    document.getElementById('txnDate').value = '${data['txnDate']}';
                    document.getElementById('productdetail[0][order_id]').value = '${data['productdetail[0][order_id]']}';
                    document.getElementById('productdetail[0][itemname]').value = '${data['productdetail[0][itemname]']}';
                    document.getElementById('productdetail[0][amount]').value = '${data['productdetail[0][amount]']}';
                    document.getElementById('productdetail[0][quantity]').value = '${data['productdetail[0][quantity]']}';
                    document.getElementById('checksumhash').value = '${data['checksumhash']}';
                    document.gosadad.submit();
                  ''';
                  controller.evaluateJavascript(script);
                }
              },
              onWebViewCreated: (controller) {
                this.controller = controller;
              },
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
