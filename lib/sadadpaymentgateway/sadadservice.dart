import 'dart:convert';

import 'package:http/http.dart' as http;

class SadadService {
  final _baseUrl = 'https://api-s.sadad.qa/api';

  Future<Map<String, dynamic>> makePayment(String amount, String description) async {
    final token = await _getAccessToken();
    if (token == null) {
      return null;
    }

    final headers = {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'};
    final data = {'Amount': amount, 'Description': description};

    final response = await http.post(Uri.parse('$_baseUrl/PaymentGateway/PaymentRequest'),
        headers: headers, body: json.encode(data));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print('Failed to make payment: ${response.statusCode}');
      return null;
    }
  }

  Future<String> _getAccessToken() async {
    final headers = {'Content-Type': 'application/json'};
    final data = {'sadadId': 'YOUR_SADAD_ID', 'secretKey': 'YOUR_SECRET_KEY', 'domain': 'YOUR_WEBSITE_URL'};

    final response = await http.post(Uri.parse('$_baseUrl/userbusinesses/login'), headers: headers, body: json.encode(data));
    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      final accessToken = jsonBody['accessToken'] as String;
      return accessToken;
    } else {
      print('Failed to get access token: ${response.statusCode}');
      return null;
    }
  }
}
