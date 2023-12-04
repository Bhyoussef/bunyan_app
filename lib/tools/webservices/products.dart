
import 'dart:io';
import 'package:bunyan/models/about.dart';
import 'package:html/parser.dart' as html;
import 'package:http/http.dart' as http;
import 'package:bunyan/models/banner.dart';
import 'package:bunyan/models/category.dart';
import 'package:bunyan/models/city.dart';
import 'package:bunyan/models/enterprise.dart';
import 'package:bunyan/models/favorite.dart';
import 'package:bunyan/models/news.dart';
import 'package:bunyan/models/product.dart';
import 'package:bunyan/models/product_list.dart';
import 'package:bunyan/models/properties_filter.dart';
import 'package:bunyan/models/real_estate_filter.dart';
import 'package:bunyan/models/report_ad.dart';
import 'package:bunyan/models/service.dart';
import 'package:bunyan/models/service_filter.dart';
import 'package:bunyan/models/services_filter.dart';
import 'package:bunyan/tools/res.dart';
import 'package:bunyan/tools/webservices/base.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../models/pakage.dart';
import 'package:html/parser.dart' show parse;

import '../../models/paymentmodel.dart';
import 'package:html/parser.dart' as parser;

class ProductsWebService extends BaseWebService {
  static const REAL_ESTATE = 1;
  static const SERVICE = 2;

  int retryTimes = 0;

  Future<List<ProductModel>> getHomeProducts(String lang,
      {RealEstateFilterModel filter}) async {
    Map<String, dynamic> data = filter == null ? {} : filter.toRequest();

    data['id_session'] = Res.USER != null ? Res.USER.id : null;

    final response =
        (await dio.get('properties?lng_type=$lang', queryParameters: data));

    List<ProductModel> products = [];
    List.of(response.data).forEach((product) {
      products.add(ProductModel.fromJson(product));
    });
    return products;
  }

  Future<List<ProductModel>> getPremiumProducts(
      {RealEstateFilterModel filter}) async {
    Map<String, dynamic> data = filter == null ? {} : filter.toRequest();
    data['id_session'] = Res.USER != null ? Res.USER.id : null;
    data['is_premium'] = 1;
    //data['id_session'] = Res.USER.id;

    final response = (await dio.get('filter_ads', queryParameters: data));

    List<ProductModel> products = [];
    List.of(response.data).forEach((product) {
      products.add(ProductModel.fromJson(product));
    });
    return products;
  }

  Future<List<ServiceModel>> getPremiumServices({ServicesFilter filter}) async {
    Map<String, dynamic> data = filter == null ? {} : filter.toRequest();
    data['id_session'] = Res.USER != null ? Res.USER.id : null;
    data['is_premium'] = 1;
    //data['id_session'] = Res.USER.id;

    final response = (await dio.get('services', queryParameters: data));

    List<ServiceModel> services = [];
    List.of(response.data['services']).forEach((product) {
      services.add(ServiceModel.fromJson(product));
    });
    return services;
  }

  Future<List<ServiceModel>> getHomeServices({ServicesFilter filter}) async {
    Map<String, dynamic> data = filter == null ? {} : filter.toRequest();
    data['id_session'] = Res.USER != null ? Res.USER.id : null;
    //data['id_session'] = Res.USER.id;

    final response = (await dio.get('services', queryParameters: data));

    List<ServiceModel> services = [];
    List.of(response.data).forEach((product) {
      services.add(ServiceModel.fromJson(product));
    });
    return services;
  }

  Future<List<ProductModel>> getTop10(
      {int page, int retry = 5, PropertiesFilterModel filter}) async {
    try {
      Map<String, dynamic> data = {};
      if (page != null) data['page'] = page;

      if (filter?.toRequest() != null) data.addAll(filter.toRequest());

      print(data);

      final response = (await dio.get('properties', queryParameters: data));
      List<ProductModel> products = [];
      List.of(response.data['properties']).forEach((product) {
        products.add(ProductModel.fromJson(product));
      });
      retryTimes = 0;
      return products;
    } on DioError catch (e) {
      if (retryTimes != retry) {
        getTop10(page: page, retry: retry);
        retryTimes++;
      } else
        throw e;
    }
  }

  Future<List<BannerModel>> serviceBanner() async {
    var idu = Res.USER != null ? Res.USER.id : null;
    final response = (await dio.get('serviceSliders'));
    List<BannerModel> banners = [];
    List.of(response.data['sliders']).forEach((product) {
      banners.add(BannerModel.fromJson(product));
    });
    return banners;
  }


  Future<List<BannerModel>> propertyBanner() async {
    var idu = Res.USER != null ? Res.USER.id : null;
    final response = (await dio.get('propertySliders'));
    List<BannerModel> banners = [];
    List.of(response.data['sliders']).forEach((product) {
      banners.add(BannerModel.fromJson(product));
    });
    return banners;
  }

  Future<bool> reportProduct(ReportAdModel report) async {
    try {
      final response = (await dio.post('reportAd', data: report.toJson())).data;
      return response['return'];
    } on DioError catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> Add_view({int id, int type}) async {
    var idu = Res.USER != null ? Res.USER.id : null;
    final response = (await dio.get('new_ad_view/', queryParameters: {
      'id': id,
      'type': type,
    }))
        .data;
    return response;
  }

  Future<List<CityModel>> getCity(String lang) async {
    try {
      final response = (await dio.get('cities?lng_type=$lang')).data;
      List<CityModel> cities = [];
      List.of(response).forEach((category) {
        cities.add(CityModel.fromJson(category));
      });
      return cities;
    } on DioError catch (e) {
      if (e.response != null) print(e.response.statusCode);

      print('dio error:   $e');
      return null;
    }
  }
  Future<List<ProductModel>> userproperty() async {
    try {
      final response = (await dio.get('app_property')).data;
      List<ProductModel> cities = [];
      List.of(response['properties']).forEach((category) {
        cities.add(ProductModel.fromJson(category));
      });
      return cities;
    } on DioError catch (e) {
      if (e.response != null) print(e.response.statusCode);

      print('dio error:   $e');
      return null;
    }
  }

  Future<List<CategoryModel>> getCategories(String lang) async {
    try {
      final response = (await dio.get('categories')).data;
      List<CategoryModel> categories = [];
      List.of(response['categories'][0]['children']).forEach((category) {
        categories.add(CategoryModel.fromJson(category));
      });
      return categories;
    } on DioError catch (e) {
      if (e.response != null) print(e.response.statusCode);

      print('dio error:   $e');
      return null;
    }
  }

  Future<List<CategoryModel>> getServicesCategories(String lang) async {
    try {
      final response = (await dio.get('categories')).data;
      List<CategoryModel> services_categories = [];
      List.of(response['categories'][1]['children']).forEach((category) {
        services_categories.add(CategoryModel.fromJson(category));
      });
      return services_categories;
    } on DioError catch (e) {
      if (e.response != null) print(e.response.statusCode);
      print('dio error:  $e');
      return null;
    }
    // }
    // final response = (await dio.get('services_categories?lng_type=$lang')).data;
    // return List.of(response).map((e) => CategoryModel.fromJson(e)).toList();
  }

  Future<List<NewsModel>> getNews() async {
    final response = (await dio.get('news')).data;
    return List.of(response['news'])
        .map((element) => NewsModel.fromJson(element))
        .toList();
  }

  Future<List<AboutModel>> getabout(String lang) async {
    final response = (await dio.get('aboutus?lng_type=$lang')).data;
    List<AboutModel> about = [];
    List.of(response).forEach((element) {
      about.add(AboutModel.fromJson(element));
    });
    return about;
  }

  Future<List<ServiceModel>> getServices(
      {int page, ServicesFilterModel filter}) async {
    Map<String, dynamic> data = {};
    if (page != null) {
      data['page'] = page;
    }

    if (!(filter?.isNull ?? true)) data.addAll(filter.toRequest());

    print('web service    $data');
    final response = (await dio.get('services', queryParameters: data)).data;
    List<ServiceModel> services = [];
    List.of(response['services']).forEach((product) {
      services.add(ServiceModel.fromJson(product));
    });
    return services;
  }

  Future<List<EnterpriseModel>> getEnterprises(int page, {String query, String category,String type}) async {
    Map<String, dynamic> data = {'page': page};
    if (query != null) data['search'] = query;
    try {
      final response = (await dio.get('agencies?$query&category=$category', queryParameters: data)).data;
      List<EnterpriseModel> enterprises = [];
      for (final enterprise in List.of(response['agencies']))
        if (enterprise != null)
          enterprises.add(EnterpriseModel.fromJson(enterprise));
      return enterprises;
    } on DioError catch (e) {
      return [];
    }
  }
  Future<List<EnterpriseModel>> getEnterprisesreal(int page, {String type}) async {
    Map<String, dynamic> data = {'page': page};

    try {
      final response = (await dio.get('agencies?type=$type', queryParameters: data)).data;
      List<EnterpriseModel> enterprises = [];
      for (final enterprise in List.of(response['agencies']))
        if (enterprise != null)
          enterprises.add(EnterpriseModel.fromJson(enterprise));
      return enterprises;
    } on DioError catch (e) {
      return [];
    }
  }
  Future<List<EnterpriseModel>> getentreprisesingle(int page, {int id}) async {
    Map<String, dynamic> data = {'page': page};

    try {
      final response = (await dio.get('agencies?id=$id', queryParameters: data)).data;
      List<EnterpriseModel> enterprises = [];
      for (final enterprise in List.of(response['agencies']))
        if (enterprise != null)
          enterprises.add(EnterpriseModel.fromJson(enterprise));
      return enterprises;
    } on DioError catch (e) {
      return [];
    }
  }

  Future<bool> likeProd(
      {@required int id,
      @required bool isRealEstate,
      @required bool dislike}) async {
    //queryParameters['id_session'] = Res.USER != null ? Res.USER.id : null;
    //${dislike ? 'dis' : ''}
    final response = (await dio.get('like_ads/$id', queryParameters: {
      'type': isRealEstate ? '1' : '2',
      'id_session': Res.USER.id
    }))
        .data;
// print('is_real $isRealEstate');
    return response['success'];
  }

  Future<bool> dislikeProd({
    @required int id,
    @required bool isRealEstate,
  }) async {
    //queryParameters['id_session'] = Res.USER != null ? Res.USER.id : null;
    final response = (await dio.get('dislike_ads/$id', queryParameters: {
      'type': isRealEstate ? 1 : 2,
      'id_session': Res.USER.id
    }))
        .data;
// print('is_real $isRealEstate');
    return response['success'];
  }

  Future<bool> setFavorit(
      {@required int id, @required bool isRealestate}) async {
    final dio2 = Dio();
    final response = (await dio2.post('https://bunyan.qa/Users/set_favorit/$id',
            data: FormData.fromMap(
              {
                'type': isRealestate ? 1 : 2,
                'id_session': Res.USER.id,
                'id_ad': id
              },
            )))
        .statusCode;
    if (response == 200) {
      return true;
    }
    return false;
  }

  Future<FavoriteModel> getFavorites() async {
    try {
      final response = (await dio.get('favourite')).data;

      return FavoriteModel.fromJson(response);
    } on DioError catch (e) {
      print(e.requestOptions.headers);
      print('message:   ${e.response.data}');
    }
  }

  Future<bool> updateFav({int id, int type}) async {
    final response = (await dio.post('likePost', data: {
      'post_id': id,
      'type': type == SERVICE ? 'service' : 'property'
    }))
        .data;

    return response['message'].toString().startsWith('Added');
  }

  // Future<List<RealEstateTypeModel>> getRealEstateTypes(String lang) async {
  //   // /types
  //
  //   final response = (await dio.get('types?lng_type=$lang')).data;
  //
  //   return List.of(response)
  //       .map((e) => RealEstateTypeModel.fromJson(e))
  //       .toList();
  // }

  Future<bool> addProduct(dynamic product, {bool isRealEstate = true}) async {
    List<String> photosPath = List.of(product.photos);
    List<MultipartFile> photos = [];
    product.photos.clear();

    for (final photo in photosPath) {
      final img = await MultipartFile.fromFile(photo);
      photos.add(img);
    }

    Map<String, dynamic> map = product.toRequest();
    map['photos[]'] = photos;

    final data = FormData.fromMap(map);
    final response = (await dio.post(
            'add_${isRealEstate ? 'advertisement' : 'service'}',
            data: data))
        .data;
    return Map.of(response).containsKey('id');
  }

  Future<bool> addRealEstate(ProductModel product) async {
    Map<String, dynamic> map = Map.from(product.toRequest());
    final data = FormData.fromMap(map);
    for (final photo in product.photos) {
      print('photo isss  $photo');
      final img = await MultipartFile.fromFile(photo,
          filename:
              photo.toString().split('/').last.replaceAll('image_picker', ''));
      data.files.add(MapEntry('images[]', img));
    }

    final response = (await dio.post(
      'app_property',
      data: data,
    ))
        .data;
    return true;
  }

  Future<bool> updateRealEstate(
      ProductModel product, List<int> photosToRemove) async {
    final dataMap = product.toRequest();
    dataMap['_method']  = 'PATCH';
    Map<String, dynamic> map = Map.from(dataMap);
    final data = FormData.fromMap(map);
    for (final photo in product.photos) {
      print('photo isss  $photo');
      try {
        final img = await MultipartFile.fromFile(photo,
            filename: photo
                .toString()
                .split('/')
                .last
                .replaceAll('image_picker', ''));
        data.files.add(MapEntry('images[]', img));
      } on FileSystemException catch (e) {}
    }

    photosToRemove.forEach((element) async {
      await dio.delete('deletePropertyImage/$element/${product.id}');
    });

    final response = (await dio.post(
      'app_property/${product.id}',
      data: data,
    ))
        .data;
    return true;
  }

  Future<bool> updateService(
      ServiceModel service, List<int> photosToRemove) async {
    final dataMap = service.toRequest();
    dataMap['_method'] = 'PATCH';
    Map<String, dynamic> map = Map.from(dataMap);
    final data = FormData.fromMap(map);
    for (final photo in service.photos) {
      try {
        final img = await MultipartFile.fromFile(photo,
            filename: photo
                .toString()
                .split('/')
                .last
                .replaceAll('image_picker', ''));
        data.files.add(MapEntry('images[]', img));
      } on FileSystemException catch (e) {}
    }

    photosToRemove.forEach((element) async {
      await dio.delete('deleteServiceImage/$element/${service.id}');
    });

    final response = (await dio.post(
      'app_service/${service.id}',
      data: data,
    ))
        .data;
    return true;
  }

  Future<Map<String, dynamic>> getUpdateRealEstate(int id) async {
    final response = (await dio.get('app_property/$id/edit')).data;
    return response['property'];
  }

  Future<Map<String, dynamic>> getUpdateService(int id) async {
    final response = (await dio.get('app_service/$id/edit')).data;
    return response['service'];
  }

  Future<bool> addService(ServiceModel service) async {
    Map<String, dynamic> map = service.toRequest();

    final data = FormData.fromMap(map);
    for (final photo in service.photos) {
      print('photo isss  $photo');
      final img = await MultipartFile.fromFile(photo,
          filename:
          photo.toString().split('/').last.replaceAll('image_picker', ''));
      data.files.add(MapEntry('images[]', img));
    }
    final response = (await dio.post(
      'app_service',
      data: data,
    ))
        .data;
    debugPrint("response issss:    $response}");
    return true;
  }

  Future<ProductModel> checkProduct(int id) async {
    final dio2 = Dio();
    final response =
        (await dio2.get('https://bunyan.qa/api/property/$id')).data;

    return response == null ? null : ProductModel.fromJson(response);
  }

  Future<ServiceModel> checkService(int id) async {
    final dio2 = Dio();
    final response = (await dio2.get('https://bunyan.qa/api/service/$id')).data;

    return response == null ? null : ServiceModel.fromJson(response);
  }

  Future<ServiceModel> getServiceBySlug(String slug) async {
    final response = (await dio.get('serviceBySlug/$slug')).data;

    return ServiceModel.fromJson(response['service']);
  }

  Future<ProductModel> getPropertyBySlug(String slug) async {
    final response = (await dio.get('proprtyBySlug/$slug')).data;

    return ProductModel.fromJson(response['property']);
  }

  deleteProduct(ProductListModel product) async {
    try {
      final response = (await dio.delete(
          ('app_${product is ProductModel ? 'property' : 'service'}/${product
              .id}')))
          .data;
    } on DioError catch(e) {
      print('error from server    ${product.id}');
      print(e.requestOptions.uri);
      print(e.response);
    }

    return;
  }


  Future<List<Pakage>> getpakage(int page, {int id}) async {
    Map<String, dynamic> data = {'page': page};

    try {
      final response = (await dio.get('packages?id=$id', queryParameters: data)).data;
      List<Pakage> enterprises = [];
      for (final enterprise in List.of(response['packages']))
        if (enterprise != null)
          enterprises.add(Pakage.fromJson(enterprise));
      return enterprises;
    } on DioError catch (e) {
      return [];
    }
  }
  Future<String> getPaymentGatewayUrl() async {

    try {
      final response = await dio.get('https://bunyan.qa/api/app_service', );
      final htmlContent = response.data.toString();
      return htmlContent;
    } on DioError catch (e) {
      return '';
    }
  }



  Future<List<PaymentGatewayData>> makePaymentRequest() async {
    try {
      final url = 'proceed-property-payment';
      final response = await dio.get(url);
      final html = response.data.toString();
      final parsedData = parseHtmlResponse(html);
      print(parsedData);

    } catch (e) {
      // handle errors
    }
  }

  PaymentGatewayData parseHtmlResponse(String html) {
    // Parse the HTML and extract the data
    final document = parse(html);
    final formDataElement = document.querySelector('form#paymentForm');
    final merchantId = formDataElement?.querySelector('input[name="MID"]')?.attributes['value'];
    final orderId = formDataElement?.querySelector('input[name="ORDER_ID"]')?.attributes['value'];
    final website = formDataElement?.querySelector('input[name="WEBSITE"]')?.attributes['value'];
    final txnAmount = formDataElement?.querySelector('input[name="TXN_AMOUNT"]')?.attributes['value'];
    final custId = formDataElement?.querySelector('input[name="CUST_ID"]')?.attributes['value'];
    final email = formDataElement?.querySelector('input[name="EMAIL"]')?.attributes['value'];
    final mobileNo = formDataElement?.querySelector('input[name="MOBILE_NO"]')?.attributes['value'];
    final callbackUrl = formDataElement?.querySelector('input[name="CALLBACK_URL"]')?.attributes['value'];
    final txnDate = formDataElement?.querySelector('input[name="txnDate"]')?.attributes['value'];
    final productOrderId = formDataElement?.querySelector('input[name="productOrderId"]')?.attributes['value'];
    final productItemName = formDataElement?.querySelector('input[name="productItemName"]')?.attributes['value'];
    final productAmount = formDataElement?.querySelector('input[name="productAmount"]')?.attributes['value'];
    final productQuantity = formDataElement?.querySelector('input[name="productQuantity"]')?.attributes['value'];
    final checksumhash = formDataElement?.querySelector('input[name="checksumhash"]')?.attributes['value'];

    // Create an instance of PaymentGatewayData with the extracted data
    return PaymentGatewayData(
      merchantId: merchantId ?? '',
      orderId: orderId ?? '',
      website: website ?? '',
      txnAmount: txnAmount ?? '',
      custId: custId ?? '',
      email: email ?? '',
      mobileNo: mobileNo ?? '',
      callbackUrl: callbackUrl ?? '',
      txnDate: txnDate ?? '',
      productOrderId: productOrderId ?? '',
      productItemName: productItemName ?? '',
      productAmount: productAmount ?? '',
      productQuantity: productQuantity ?? '',
      checksumhash: checksumhash ?? '',
    );
  }

    Future<Map<String, String>> initiatePayment() async {
      var url = Uri.parse('https://bunyan.qa/api/proceed-property-payment',);
      var response = await http.post(url, headers: {'accept': 'application/json',
        'Authorization': 'Bearer ${Res.token}'});
      print(response);
    print('youssef payment data : $response');
    final document = parser.parse(response.body);
    final inputs = document.getElementsByTagName('input');
    final data = <String, String>{};
    for (final input in inputs) {
      final name = input.attributes['name'];
      final value = input.attributes['value'];
      if (name != null && value != null) {
        data[name] = value;
      }
    }

    return data;
  }


}


Future<List<MultipartFile>> _compressPhotos(ProductModel product) async {
  List<MultipartFile> photos = [];

  return photos;
}

