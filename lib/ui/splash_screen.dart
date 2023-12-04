import 'dart:convert';
import 'dart:io';
import 'package:bunyan/localization/locale_constant.dart';
import 'package:bunyan/models/passthrough_home.dart';
import 'package:bunyan/models/person.dart';
import 'package:bunyan/models/product.dart';
import 'package:bunyan/models/service.dart';
import 'package:bunyan/tools/res.dart';
import 'package:bunyan/tools/webservices/addresses.dart';
import 'package:bunyan/tools/webservices/advertises.dart';
import 'package:bunyan/tools/webservices/products.dart';
import 'package:bunyan/ui/main/main_screen.dart';
import 'package:bunyan/ui/update_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:update_checker/update_checker.dart';

import 'auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({Key key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Locale currentLang;
  PassthroughHome _passthroughHome;

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    _checkForUpdate();


    super.initState();
  }

  getData() async {
    final futures = await Future.wait([
      getLocale(),
      Future.delayed(Duration(seconds: 7)),
      AdvertisesWebService().getHomeData(),
      ProductsWebService().getTop10(page: 0),
      ProductsWebService().getServices(page: 0),
      AdvertisesWebService().getBanners(1),
      AdvertisesWebService().getBannersService(2),
      AddressesWebService().getRegions(),
      ProductsWebService().getCategories(currentLang.toString()),
    ]).timeout(Duration(hours: 1));
    currentLang = (futures[0] as Locale);
    final productsPremium = List.of(futures[2]['properties'])
        .map((e) => ProductModel.fromJson(e))
        .toList();
    final servicesPremium = List.of(futures[2]['services'])
        .map((e) => ServiceModel.fromJson(e))
        .toList();
    final products = futures[3];
    final services = futures[4];
    final banners  = futures[5];
    final serviceBanners = futures[5];
    Res.regions   = futures[7];
    Res.catgories = futures[8];

    _passthroughHome = PassthroughHome(
        products: products,
        banners: banners,
        premiumProducts: productsPremium,
        premiumServices: servicesPremium,
        services: services,
        serviceBanners: serviceBanners);
    _goToScreen();
  }

  // @override
  // void dispose() {
  //   SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  //   SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Image.asset(
        'assets/Bunyan Splash screen 2022 GIF.gif',
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        fit: BoxFit.cover,
      ),
    );
  }

  Future<void> _goToScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final user = await prefs.getString(('user'));
    Res.token = await prefs.getString('token');
    if (user != null) Res.USER = PersonModel.fromJson(jsonDecode(user));
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => Res.USER != null
                ? MainScreen(
                    showVerifMail: false, passthrough: _passthroughHome)
                : LoginScreen(passthrough: _passthroughHome)));
  }

  Future<void> _checkForUpdate() async {
    try {
      final update = await UpdateChecker().checkForUpdates(Platform.isIOS
          ? 'https://apps.apple.com/tt/app/bunyan/id1589752170'
          : 'https://play.google.com/store/apps/details?id=com.bunyan.bunyan');

      if (update)
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MainScreen()), (route) => false);
      else
        getData();
    } catch (e) {
      print('error isssssssssss:    $e');
      getData();
    }
  }
}
