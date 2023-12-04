



import 'package:dio/dio.dart';

import '../../../models/businessesmodel.dart';
import '../../../models/enterprise.dart';
import '../base.dart';

class BusnissApi extends BaseWebService {

/*  Future<List<Busnisscategory>> getEnterprises() async {

    try {
      final response = (await dio.get('categories')).data;
      List<Busnisscategory> enterprises = [];
      for (final enterprise in List.of(response['categories']))
        if (enterprise != null)
          enterprises.add(Busnisscategory.fromJson(enterprise));
      return enterprises;
    } on DioError catch (e) {
      return [];
    }
  }*/
  Future<List<Busnisscategory>> getEnterprises() async {
    try {
      final response = (await dio.get('categories')).data;
      final firstCategory = response['categories'][0];
      final enterprise = Busnisscategory.fromJson(firstCategory);
      return [enterprise];
    } on DioError catch (e) {
      return [];
    }
  }
  Future<List<Busnisscategory>> getEnterprisessecond() async {
    try {
      final response = (await dio.get('categories')).data;
      final secondecategory = response['categories'][1]['children'];
      List<Busnisscategory> enterprises = [];
      for (final enterprise in secondecategory) {
        if (enterprise != null) {
          enterprises.add(Busnisscategory.fromJson(enterprise));
        }
      }
      return enterprises;
    } on DioError catch (e) {
      return [];
    }
  }
  Future<List<Busnisscategory>> getcategorybusiness() async {
    try {
      final response = (await dio.get('categories')).data;
      final secondecategory = response['categories'][2]['children'];
      List<Busnisscategory> enterprises = [];
      for (final enterprise in secondecategory) {
        if (enterprise != null) {
          enterprises.add(Busnisscategory.fromJson(enterprise));
        }
      }
      return enterprises;
    } on DioError catch (e) {
      return [];
    }
  }
  Future<List<Busnisscategory>> getcategoriesbusiness() async {
    try {
      final response = (await dio.get('categories')).data;
      final firstCategory = response['categories'][2];
      final enterprise = Busnisscategory.fromJson(firstCategory);
      return [enterprise];
    } on DioError catch (e) {
      return [];
    }
  }
/*  Future<bool> addEnterprise(EnterpriseModel enterprise) async {
    try {
      final response = await dio.post('app_agency', data: enterprise.toJson());
      return response.statusCode == 200;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }*/
  Future<Response<dynamic>> addEnterprise(FormData formData) async {
    try {
      return await dio.post('https://bunyan.qa/api/app_agency',
          data: formData);
    } catch (error) {
      print(error.response.data);
      throw error;
    }
  }
  Future<Response> createPlace(FormData formData) async {
    try {
      return await dio.post('https://bunyan.qa/api/app_agency',
          data: formData);
    } catch (error) {
      print(error.response.data);
      throw error;
    }
  }

/*  Future<List<EnterpriseModel>> getEnterprisesuser() async {
    try {
      final response = (await dio.get('app_agency')).data;
      final firstCategory = response['agencies'];
      final enterprise = EnterpriseModel.fromJson(firstCategory);
      return [enterprise];
    } on DioError catch (e) {
      return [];
    }
  }*/
/*  Future<List<EnterpriseModel>> getEnterprisesuser() async {
    final response = (await dio.get('app_agency')).data;
    List<EnterpriseModel> entrepriseuser = [];
    List.of(response).forEach((element) {
      entrepriseuser.add(EnterpriseModel.fromJson(element));
    });
    return entrepriseuser;
  }*/
  Future<List<EnterpriseModel>> getEnterprisesuser() async {

    try {
      final response = (await dio.get('app_agency')).data;
      List<EnterpriseModel> enterprises = [];
      for (final enterprise in List.of(response['agencies']))
        if (enterprise != null)
          enterprises.add(EnterpriseModel.fromJson(enterprise));
      return enterprises;
    } on DioError catch (e) {
      return [];
    }
  }




}