import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<void> processPayment(
    String cardNumber,
    String expiryMonth,
    String expiryYear,
    String cvv,
    String merchantId,
    String securityKey,
    String returnUrl,
    double amount,
    String currency,
    String description,
    ) async {
  final String apiUrl = 'https://sadadqa.com/webpurchase';

  final Map<String, dynamic> paymentData = {
    'amount': amount,
    'currency': currency,
    'card_number': cardNumber,
    'expiry_month': expiryMonth,
    'expiry_year': expiryYear,
    'cvv': cvv,
    'merchant_id': merchantId,
    'security_key': securityKey,
    'return_url': returnUrl,
    'description': description,
  };

  try {
    final http.Response response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(paymentData),
    );

    if (response.statusCode == 200) {
      // Payment successful
      print(response);
      print('Payment successful!');
    } else {
      // Payment failed
      print('Payment failed!');
    }
  } catch (e) {
    String errorMessage = e.message;
    print('Payment failed due to an error: $errorMessage');
  }
}
