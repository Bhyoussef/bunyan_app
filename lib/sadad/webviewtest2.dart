import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
import 'dart:convert';
import '../tools/res.dart';
import '../tools/webservices/products.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_html/flutter_html.dart';
import 'package:html/parser.dart' as parser;

class PaymentScreentest2 extends StatefulWidget {
  @override
  _PaymentScreentest2State createState() => _PaymentScreentest2State();
}

class _PaymentScreentest2State extends State<PaymentScreentest2> {
  final Completer<WebViewController> _controller =
  Completer<WebViewController>();
  String merchantId = '';
  String orderId = '';
  String website = '';
  String txnAmount = '';
  String custId = '';
  String email = '';
  String mobileNo = '';
  String callbackUrl = '';
  String txnDate = '';
  String orderItemName = '';
  String orderAmount = '';
  String orderQuantity = '';
  String checksumhash = '';
  bool isLoading = true;

  String _merchantId = '8685598';
  String _orderId = '630';
  String _website = 'bunyan.qa';
  String _txnAmount = '40';
  String _custId = 'ammalnaveed50@gmail.com';
  String _email = 'ammalnaveed50@gmail.com';
  String _mobileNo = '66235580';
  String _callbackUrl = 'http://bunyan.qa/property-payment-response';
  String _txnDate = '2023-04-01 09:24:51';
  String _productDetails = 'test to test';
  String _checksumHash = 'VzuYvhiNm+JornqN7XerIa5gzi4fRZT7fKtJH3vIs9RVVlwPuytNE03DyOgH7Rh1DKaes3k01/jD9gGxo2GkQ3kBSEeCpydN0H2d9vFBaIE=';

  final TextEditingController _merchantIdController = TextEditingController();
  final TextEditingController _orderIdController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _txnAmountController = TextEditingController();
  final TextEditingController _custIdController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileNoController = TextEditingController();
  final TextEditingController _callbackUrlController =
  TextEditingController();
  final TextEditingController _txnDateController = TextEditingController();
  final TextEditingController _orderDetailController = TextEditingController();
  final TextEditingController _checksumHashController =
  TextEditingController();
  ProductsWebService _paymentService = ProductsWebService();
  bool _isLoading = true;
  Map<String, String> _paymentFormData = {};

  @override
  void initState() {

    fetchData();

    super.initState();
  }
  Future<void> _loadPaymentPage() async {
    final formData = await _paymentService.initiatePayment();
    setState(() {
      _isLoading = false;
      _paymentFormData=formData;
      print(formData);
    });
  }

  getresponse() async {
    var url = Uri.parse('https://bunyan.qa/api/proceed-property-payment',);
    var response = await http.post(url, headers: {'accept': 'application/json',
      'Authorization': 'Bearer ${Res.token}'});
    print(response);


    var document = html.parse(response);
    var message = document
        .querySelector('#message')
        .text;
    var transactionDate = document
        .querySelector('#transaction_date')
        .text;
    print('Message: $message');
    print('Transaction Date: $transactionDate');
  }

  Future<void> getFormValues() async {
    var url = Uri.parse('https://example.com/payment-gateway-response');
    var response = await http.post(url, headers: {'accept': 'application/json',
      'Authorization': 'Bearer ${Res.token}'});
    print(response);

    // Parse the HTML response
    var bytes = response.bodyBytes;
    print(bytes);
    var document = html.parse(response.body);

    // Get the form element and all the input elements
    var form = document.querySelector('form');
    var inputs = form.querySelectorAll('input');

    // Extract the values of each input field
    var values = {};
    for (var input in inputs) {
      var name = input.attributes['name'];
      var value = input.attributes['value'];
      if (name != null && value != null) {
        values[name] = value;
      }
    }

    // Set the values of each input field to a TextEditingController
    _merchantIdController.text = values['merchant_id'] ?? '';
    _orderIdController.text = values['ORDER_ID'] ?? '';
    _websiteController.text = values['WEBSITE'] ?? '';
    _txnAmountController.text = values['TXN_AMOUNT'] ?? '';
    _custIdController.text = values['CUST_ID'] ?? '';
    _emailController.text = values['EMAIL'] ?? '';
    _mobileNoController.text = values['MOBILE_NO'] ?? '';
    _callbackUrlController.text = values['CALLBACK_URL'] ?? '';
    _txnDateController.text = values['txnDate'] ?? '';
    _orderDetailController.text = values['productdetail[0][itemname]'] ?? '';
    _checksumHashController.text = values['checksumhash'] ?? '';
  }

  Future<void> _getPaymentDetails() async {
    final response = await http.post(
        Uri.parse('https://bunyan.qa/api/proceed-property-payment'),
        headers: {'accept': 'application/json',
          'Authorization': 'Bearer ${Res.token}'});

    Map<String, dynamic> responseData = jsonDecode(response.body);
    // Extract the values from the response here
    String merchantId = responseData['merchant_id'];
    String orderId = responseData['ORDER_ID'];
    String website = responseData['WEBSITE'];
    double txnAmount = double.parse(responseData['TXN_AMOUNT']);
    String custId = responseData['CUST_ID'];
    String email = responseData['EMAIL'];
    String mobileNo = responseData['MOBILE_NO'];
    String callbackUrl = responseData['CALLBACK_URL'];
    String txnDate = responseData['txnDate'];
    // Extract product details from the response here
    List<dynamic> productDetails = responseData['productdetail'];
    // Extract the checksum hash from the response here
    String checksumHash = responseData['checksumhash'];
    // Display the values extracted from the response here
    print('Merchant ID: $merchantId');
    print('Order ID: $orderId');
    print('Website: $website');
    print('Transaction Amount: $txnAmount');
    print('Customer ID: $custId');
    print('Email: $email');
    print('Mobile No: $mobileNo');
    print('Callback URL: $callbackUrl');
    print('Transaction Date: $txnDate');
    // Display the product details extracted from the response here
    for (var product in productDetails) {
      String itemId = product['order_id'];
      String itemName = product['itemname'];
      double amount = double.parse(product['amount']);
      int quantity = int.parse(product['quantity']);
      print('Product ID: $itemId');
      print('Product Name: $itemName');
      print('Amount: $amount');
      print('Quantity: $quantity');
    }
    // Display the checksum hash extracted from the response here
    print('Checksum Hash: $checksumHash');
  }


  Future<void> fetchData() async {
    final response = await http.get(
        Uri.parse('http://bunyan.qa/payment-response',),
        headers: {'accept': 'application/json',
      'Authorization': 'Bearer ${Res.token}'});


      final html = response;
      print(html);
      final document = parser.parse(html);

      setState(() {
        merchantId = document.getElementById('merchant_id').attributes['value'];
        print('youssef is here $merchantId');
        orderId = document.getElementById('ORDER_ID').attributes['value'];
        website = document.getElementById('WEBSITE').attributes['value'];
        txnAmount = document.getElementById('TXN_AMOUNT').attributes['value'];
        custId = document.getElementById('CUST_ID').attributes['value'];
        email = document.getElementById('EMAIL').attributes['value'];
        mobileNo = document.getElementById('MOBILE_NO').attributes['value'];
        callbackUrl = document.getElementById('CALLBACK_URL').attributes['value'];
        txnDate = document.getElementById('txnDate').attributes['value'];
        //orderItemName = document.getElementsByName('productdetail[0][itemname]')[0].attributes['value'];
        //orderAmount = document.getElementsByName('productdetail[0][amount]')[0].attributes['value'];
        //orderQuantity = document.getElementsByName('productdetail[0][quantity]')[0].attributes['value'];
        //checksumhash = document.getElementsByName('checksumhash')[0].attributes['value'];
        isLoading = false;
      });

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       /*title: Text('Payment Amount: ${_paymentFormData['amount']}',style: TextStyle(
         color: Colors.black
       ),),*/
        title: Text('Make Payment',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontSize: 22.sp,
            )),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black, size: 30.sp),
        backgroundColor: Colors.transparent,
      ),
      body: WebView(
          initialUrl: 'about:blank',
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            _controller.complete(webViewController);
            _loadHtmlFromAssets(webViewController);
          },
/*          navigationDelegate: (NavigationRequest request) {
            if (request.url
                .startsWith('http://bunyan.qa/property-payment-response')) {
              // Extract payment status from URL parameters
              Map<String, String> params =
                  Uri.parse(request.url).queryParameters;
              String paymentStatus = params['payment_status'];

              // Show a message to the user indicating the payment status
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('Payment Status'),
                  content: Text(paymentStatus == 'success'
                      ? 'Payment Successful!'
                      : 'Payment Failed!'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('OK'),
                    ),
                  ],
                ),
              );

              // Prevent the web view from navigating to the callback URL again
              return NavigationDecision.prevent;
            }
          }*/
          ),
    );
  }

  void _loadHtmlFromAssets(WebViewController webViewController) {
    String html = '''
      <html>
        <body onload="document.forms[0].submit();">
          <form action="https://sadadqa.com/webpurchase" method="post" name="gosadad">
            <input type="hidden" name="merchant_id" id="merchant_id" value="$_merchantId">
            <input type="hidden" name="ORDER_ID" id="ORDER_ID" value="$_orderId">

            <input type="hidden" name="WEBSITE" id="WEBSITE" value="$_website">
            <input type="hidden" name="TXN_AMOUNT" id="TXN_AMOUNT" value="40">

            <input type="hidden" name="CUST_ID" id="CUST_ID" value="$_custId">
            <input type="hidden" name="EMAIL" id="EMAIL" value="$_email">

            <input type="hidden" name="MOBILE_NO" id="MOBILE_NO" value="$_mobileNo">

            <input type="hidden" name="CALLBACK_URL" id="CALLBACK_URL" value="$_callbackUrl">
            <input type="hidden" name="txnDate" id="txnDate" value="$_txnDate">

            <input type="hidden" name="productdetail[0][order_id]" value="630">
            <input type="hidden" name="productdetail[0][itemname]" value="$_productDetails">
            <input type="hidden" name="productdetail[0][amount]" value="40">
            <input type="hidden" name="productdetail[0][quantity]" value="1">
            <input type="hidden" name="checksumhash" value="$_checksumHash">
          </form>
        </body>
      </html>
    ''';
    webViewController.loadUrl(Uri.dataFromString(html,
            mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
        .toString());
  }
}
