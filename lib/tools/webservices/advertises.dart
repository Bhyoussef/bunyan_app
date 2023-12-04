import 'dart:convert';
import 'package:bunyan/models/advertise.dart';
import 'package:bunyan/models/banner.dart';
import 'package:bunyan/models/city.dart';
import 'package:bunyan/models/product.dart';
import 'package:bunyan/models/service.dart';
import 'package:bunyan/tools/res.dart';
import 'package:bunyan/tools/webservices/base.dart';
import 'package:dio/dio.dart';

class AdvertisesWebService extends BaseWebService {
  Future<List<Advertise>> getAds() async {
    /*try {*/
    final response =
        jsonDecode((await dio.get('application/bannier.php')).data);
    List<Advertise> ads = List();
    List.of(response).forEach((ad) {
      ads.add(Advertise.fromJson(ad));
    }
    );
    return ads;
  }

  Future<dynamic> getHomeData() async {

    final response = (await dio.get('index')).data;

    return response;
  }

  Future<List<BannerModel>> getBanners(int type) async {
    try {
      final params = {
        'type': 'Property',
      };
      final response = (await dio.get('sliders', queryParameters: params)).data;
      List<BannerModel> banners = [];

      List.of(response['sliders']).forEach((banner) {
        banners.add(BannerModel.fromJson(banner));
      });

      return banners;
    } on DioError catch (e) {
      if (e.response != null) print(e.response.statusCode);

      print('dio error:   $e');
      return null;
    }
  }
  Future<List<BannerModel>> getBannersService(int type) async {
    try {
      final params = {
        'type': 'Service',
      };
      final response = (await dio.get('serviceSliders', queryParameters: params)).data;

      return List.of(response['sliders']).map((banner) => BannerModel.fromJson(banner)).toList();

    } on DioError catch (e) {
      if (e.response != null) print(e.response.statusCode);

      print('dio error:   $e');
      return null;
    }
  }

  Future<void> addView(String slug, {bool isProperty = true}) async {
    final response = (await dio.post('${isProperty ? 'viewProperty' : 'viewService'}/$slug')).data;
    print('added vieww:     ${response}');
    return;
  }

  Future<Map<String, dynamic>> getUserAds({int userId}) async {
    if (userId != null) {
      final response = (await dio.get('userPosts/${userId}')).data;
      final properties = List.of(response['properties']).map((json) =>
          ProductModel.fromJson(json)).toList();
      final services = List.of(response['services']).map((json) =>
          ServiceModel.fromJson(json)).toList();
      return {'properties': properties, 'services': services};
    } else {
      final futures = await Future.wait([
        dio.get('app_property'),
        dio.get('app_service'),
      ]);

      final properties = List.of(futures[0].data['properties']).map((json) =>
          ProductModel.fromJson(json)).toList();
      final services = List.of(futures[1].data['services']).map((json) =>
          ServiceModel.fromJson(json)).toList();
      final result = {'properties': properties, 'services': services};
      return result;
    }
  }

  Future<List<CityModel>> getCities() async {
    final response = (await dio.get('regions')).data;

    return List.of(response['regions']).map((e) => CityModel.fromJson(e)).toList();
  }

}
