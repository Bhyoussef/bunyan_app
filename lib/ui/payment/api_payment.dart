import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> initiatePayment(
    String merchantId, String merchantPassword, double amount, String orderId) async {

  final response = await http.post(Uri.https('https://sadad.com/v2/payment/initiate'),

    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Basic ${base64.encode(utf8.encode('$merchantId:$merchantPassword'))}',
    },
    body: jsonEncode({
      'amount': amount,
      'currency': 'SAR',
      'orderId': orderId,
      'language': 'en',
      'returnUrl': 'https://your.return.url',
      'failureUrl': 'https://your.failure.url',
      'billing': {
        'name': 'John Doe',
        'email': 'johndoe@example.com',
        'phone': '+966500000000',
      },
    }),
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> responseData = jsonDecode(response.body);
    return responseData;
  } else {
    throw Exception('Failed to initiate payment');
  }
}
