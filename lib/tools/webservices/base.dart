import 'dart:io';

import 'package:bunyan/tools/res.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';

class BaseWebService {
  Dio dio;

  BaseWebService() {
    dio = Dio(BaseOptions(baseUrl: Res.baseUrl, headers: {'accept': 'application/json', 'Authorization': 'Bearer ${Res.token}'},));
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      return client;
    };
  }
}