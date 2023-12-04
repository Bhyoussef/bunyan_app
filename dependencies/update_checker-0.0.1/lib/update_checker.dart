import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

class UpdateChecker {
  static const MethodChannel _channel = const MethodChannel('update_checker');

  ///
  /// this method is for getting current app version and match it with store version
  /// pass play store URL or app store URL according to your Device URL
  /// Note: take app URL from browser
  /// android like that: https://play.google.com/store/apps/details?id=YOUR_ID
  /// iOs like that: https://apps.apple.com/eg/app/levc/idYOUR_ID
  Future<bool> checkForUpdates(String storeURL) async {
    final String version = await _channel.invokeMethod('getCurrentVersion');
    final bool isAvailable = await _isUpdateAvailable(storeURL, version);
    return isAvailable;
  }

  ///
  ///isUpdateAvailable returns true if any update available
  ///just pass store URL for android and ios
  Future<bool> _isUpdateAvailable(String storeURL, String versionNumber) async {
    if (Platform.isIOS) {
      final response = await http.get(Uri.parse(storeURL));
      final document = html_parser.parse(response.body);

      // Google has the best class names.
      final results = document.getElementsByClassName(
          'l-column small-6 medium-12 whats-new__latest__version');

      print('ios store version : ${results[0].text.split(" ")[1]}');
      print('ios app version : $versionNumber');

      if (_isOld(versionNumber, results[0].text.split(" ")[1])) {
        print("ios update");
        return true;
      }
    } else {
      final response = await http.get(Uri.parse(storeURL));
      final document = html_parser.parse(response.body);

      // Google has the best class names.
      final results = document.getElementsByClassName('IQ1z0d');

      var placement = 1;
      print('Android store version : ${results[5].text}');
      print('Android app version : $versionNumber');
      if (_isOld(versionNumber, results[5].text)) {
        print('android update');
        return true;
      }
    }
    return false;
  }


  bool _isOld(String v1String, String v2String) {
    bool isV1Lower = false;

    final v1 = v1String.split('.').map((e) => int.parse(e)).toList();
    final v2 = v2String.split('.').map((e) => int.parse(e)).toList();

    for (int i = 0; i < (v1.length >= v2.length ? v2.length : v1.length); i++) {
      if (v2[i] > v1[i]) {
        isV1Lower = true;
        break;
      }
    }
    return isV1Lower;
  }
}
