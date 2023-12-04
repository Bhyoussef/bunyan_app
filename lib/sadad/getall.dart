import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';

import '../tools/res.dart';

class geall extends StatefulWidget {
  @override
  _geallState createState() => _geallState();
}

class _geallState extends State<geall> {
  Map<String, dynamic> paymentData = {};

  @override
  void initState() {
    super.initState();
    fetchPaymentData();
  }

  Future<void> fetchPaymentData() async {
    final response = await http.post(Uri.parse(
        'https://bunyan.qa/api/proceed-property-payment'),
        headers: {'accept': 'application/json',
      'Authorization': 'Bearer ${Res.token}'});


    final document = parse(response.body);
    final forms = document.getElementsByTagName('form');


    final form = forms[0];
    final inputs = form.getElementsByTagName('input');

    final merchantId = inputs
        .firstWhere((input) => input.attributes['name'] == 'merchant_id')
        .attributes['value'];
    final orderId = inputs
        .firstWhere((input) => input.attributes['name'] == 'ORDER_ID')
        .attributes['value'];
    final website = inputs
        .firstWhere((input) => input.attributes['name'] == 'WEBSITE')
        .attributes['value'];
    final transactionAmount = inputs
        .firstWhere((input) => input.attributes['name'] == 'TXN_AMOUNT')
        .attributes['value'];
    final customerId = inputs
        .firstWhere((input) => input.attributes['name'] == 'CUST_ID')
        .attributes['value'];
    final email = inputs
        .firstWhere((input) => input.attributes['name'] == 'EMAIL')
        .attributes['value'];
    final mobileNumber = inputs
        .firstWhere((input) => input.attributes['name'] == 'MOBILE_NO')
        .attributes['value'];
    final callbackUrl = inputs
        .firstWhere((input) => input.attributes['name'] == 'CALLBACK_URL')
        .attributes['value'];
    final transactionDate = inputs
        .firstWhere((input) => input.attributes['name'] == 'txnDate')
        .attributes['value'];

    final productDetailsInputs = inputs.where((input) => input.attributes['name'] == 'productdetail[]').toList();
    final productDetails = productDetailsInputs.map((input) {
      final orderID = input.attributes['value'];
      final itemName = input.nextElementSibling.attributes['value'];
      final amount = input.nextElementSibling.nextElementSibling.attributes['value'];
      final quantity = input.nextElementSibling.nextElementSibling.nextElementSibling.attributes['value'];

      return {
        'order_id': orderID,
        'item_name': itemName,
        'amount': amount,
        'quantity': quantity,
      };
    }).toList();

    print('Merchant ID: $merchantId');
    print('Order ID: $orderId');
    print('Website: $website');
    print('Transaction Amount: $transactionAmount');
    print('Customer ID: $customerId');
    print('Email: $email');
    print('Mobile Number: $mobileNumber');
    print('Callback URL: $callbackUrl');
    print('Transaction Date: $transactionDate');
    print('Product Details: $productDetails');

    setState(() {
      //paymentData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Page'),
      ),
      /*body:  ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          ListTile(
            title: Text('Merchant ID'),
            subtitle: Text(paymentData['merchant_id']),
          ),
          ListTile(
            title: Text('Order ID'),
            subtitle: Text(paymentData['ORDER_ID']),
          ),
          ListTile(
            title: Text('Website'),
            subtitle: Text(paymentData['WEBSITE']),
          ),
          ListTile(
            title: Text('Transaction Amount'),
            subtitle: Text(paymentData['TXN_AMOUNT']),
          ),
          ListTile(
            title: Text('Customer ID'),
            subtitle: Text(paymentData['CUST_ID']),
          ),
          ListTile(
            title: Text('Email'),
            subtitle: Text(paymentData['EMAIL']),
          ),
          ListTile(
            title: Text('Mobile Number'),
            subtitle: Text(paymentData['MOBILE_NO']),
          ),
          ListTile(
            title: Text('Callback URL'),
            subtitle: Text(paymentData['CALLBACK_URL']),
          ),
          ListTile(
            title: Text('Transaction Date'),
            subtitle: Text(paymentData['txnDate']),
          ),
          ListTile(
            title: Text('Product Detail'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < 1; i++)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order ID: ${paymentData['productdetail[$i][order_id]']}'),
                      Text('Item Name: ${paymentData['productdetail[$i][itemname]']}'),
                      Text('Amount: ${paymentData['productdetail[$i][amount]']}'),
                      Text('Quantity: ${paymentData['productdetail[$i][quantity]']}'),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),*/
    );
  }
}
