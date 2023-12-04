import 'package:bunyan/models/city.dart';
import 'package:bunyan/models/region.dart';
import 'package:bunyan/tools/webservices/base.dart';
import 'package:dio/dio.dart';

import '../../models/content_model.dart';
import '../../models/pakage.dart';

class AddressesWebService extends BaseWebService {
  Future<List<RegionModel>> getRegions() async {
    final response = (await dio.get('regions')).data;
    return List.of(response['regions'])
        .map((e) => RegionModel.fromJson(e))
        .toList();
  }

  Future<List<CityModel>> getCities(int regionId) async {
    final response = (await dio.get('/cities/$regionId')).data;
    return List.of(response).map((e) => CityModel.fromJson(e)).toList();
  }

  Future<List<Content>> getcontent() async {
    try {
      final response = (await dio.get('pages')).data;
      List<Content> content = [];
      for (final contents in List.of(response['pages']))
        if (contents != null) content.add(Content.fromJson(contents));
      return content;
    } on DioError catch (e) {
      return [];
    }
  }
  Future<List<Pakage>> getpakage() async {
    try {
      final response = (await dio.get('packages')).data;
      List<Pakage> pakage = [];
      for (final pakages in List.of(response['packages']))
        if (pakages != null) pakage.add(Pakage.fromJson(pakages));
      return pakage;
    } on DioError catch (e) {
      return [];
    }
  }
}
