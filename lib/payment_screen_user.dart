import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class CheckoutPage extends StatefulWidget {
  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  String _customerName;
  String _email;
  String _phone;
  double _amount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Customer Name',
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _customerName = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email Address',
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter your email address';
                  }
                  return null;
                },
                onSaved: (value) {
                  _email = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
                onSaved: (value) {
                  _phone = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Amount',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter the order amount';
                  }
                  return null;
                },
                onSaved: (value) {
                  _amount = double.parse(value);
                },
              ),
              SizedBox(height: 16.0),
              MaterialButton(
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    _formKey.currentState.save();
                 initiatePayment(
                     '8685598',
                     'xKQZ//aq1EceRoJF',
                     'https://www.example.com/return',
                      3,
                     'QAR',
                     'test payment',
                     '8789789',
                     _customerName,
                     _email,
                     _phone,
                 );

                  }
                },
                child: Text('Pay Now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


Future<String> initiatePayment(
    String sadadId,
    String secretKey,
    String domain,
    double amount,
    String currency,
    String description,
    String referenceNumber,
    String customerName,
    String customerEmail,
    String customerPhone,
    ) async {
  final response = await http.post(
    Uri.parse('https://sadadqa.com/webpurchase/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{
      'sadadId': sadadId,
      'secretKey': secretKey,
      'domain': domain,
      'amount': amount,
      'currency': currency,
      'description': description,
      'referenceNumber': referenceNumber,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
    }),
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> responseData = json.decode(response.body);
    final String paymentId = responseData['paymentId'];
    launchPaymentPage(paymentId);
    return paymentId;
  } else {
    throw Exception('Failed to initiate payment');
  }
}
void launchPaymentPage(String paymentId) async {
  final String paymentUrl = 'https://sadadqa.com/webpurchase/';
  if (await canLaunch(paymentUrl)) {
    await launch(paymentUrl);
  } else {
    throw Exception('Could not launch payment page');
  }
}

