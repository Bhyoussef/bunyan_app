import 'dart:convert';
import 'dart:io';

import 'package:bunyan/exceptions/signup_failed.dart';
import 'package:bunyan/exceptions/unauthorized.dart';
import 'package:bunyan/models/about.dart';
import 'package:bunyan/models/auth.dart';
import 'package:bunyan/models/chat.dart';
import 'package:bunyan/models/enterprise.dart';
import 'package:bunyan/models/favorite.dart';
import 'package:bunyan/models/person.dart';
import 'package:bunyan/models/product.dart';
import 'package:bunyan/models/product_list.dart';
import 'package:bunyan/models/service.dart';
import 'package:bunyan/tools/res.dart';
import 'package:bunyan/tools/webservices/base.dart';
import 'package:bunyan/ui/auth/login_screen.dart';
import 'package:dio/dio.dart';
import 'package:bunyan/tools/extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SoacialMethod {
  Facebook,
Apple,
Google
}

class UsersWebService extends BaseWebService {

  Future<PersonModel> login({String mail, String passwd}) async {
    try {
      final data = {'email': mail, 'password': passwd};
      print(data);
      final response = (await dio.post('login',
              data: FormData.fromMap(data)))
          .data;
      print(response);
      if (Map.of(response).containsKey('status') && response['status'] != 200) throw UnauthorizedException();
      Res.token = response['token'];
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('token', Res.token);
      return PersonModel.fromJson(response['user']);
    } on DioError catch (e) {
      throw e;
    }
  }

  Future<bool> signup(PersonModel usr) async {
    Map<String, dynamic> map = usr.toRequest();

    // if (map.get('profile_photo') != null) {
    //   final profilePicture = File(usr.profilePicture.path);
    //   map['profile_photo'] = await MultipartFile.fromFile(profilePicture.path);
    // }
    // if (map.get('entreprize_photo') != null) {
    //   final entrPicture = File(usr.entrPhoto.path);
    //   map['entreprize_photo'] = await MultipartFile.fromFile(entrPicture.path);
    // }

    // if (map.get('entreprize_lat') == null) map['entreprize_lat'] = '';
    // if (map.get('entreprize_lng') == null) map['entreprize_lng'] = '';

    FormData data = FormData.fromMap(map);

    final response = (await dio.post(
      'register',
      data: map,
    ))
        .data;
    print(response.toString() + ' mlkjfu');
    try {
      return true;
    } catch (e) {
      if (response.toString().contains('invalid')) {
        String errors = '';
        Map.of(Map.from(response)['errors']).forEach((key, value) {errors += (value[0].toString() + '\n');});
        throw SignupFailedException(cause: errors);
      } else
        throw e;
    }
  }

  Future<void> followUser({int id, bool follow = true}) async {
    final dio2 = Dio();
    final response = (await dio2.post(
            'https://bunyan.qa/users/${follow ? '' : 'un'}follow',
            data: {'followed_id': id, 'follower_id': Res.USER.id},
            options: Options(contentType: Headers.formUrlEncodedContentType)))
        .data;
    return response['message'].toString().contains('query saved');
  }

  Future<Map<String, dynamic>> getUserProfile(int id) async {
    final dio2 = Dio();
    int id_Session = Res.USER != null ? Res.USER.id : null;
    final params = {
      'selected_profile': id ?? Res.USER.id,
      'id_session': id_Session,
    };

    final response = (await dio2.get('https://bunyan.qa/Users/profile',
            queryParameters: params))
        .data;
    Map<String, dynamic> data = {};
    PersonModel profileinfo;
    profileinfo = PersonModel.fromJson(response['profile']);
    List<ProductModel> products = [];
    List<ServiceModel> services = [];
    List<ProductListModel> listing = [];

    //print('profile listing {$products}');

    data['user'] = PersonModel.fromJson(response['profile']);
    //data['products'] = products;
    //data['services'] = services;
    return data;
  }

  Future<Map<String, dynamic>> getProfileListing(PersonModel ent) async {
    final dio2 = Dio();
    int id_Session = Res.USER != null ? Res.USER.id : null;
    final params = {
      'selected_profile': ent.id ?? Res.USER.id,
      'company_id': ent.enterprise != null ? ent.enterprise.id : null,
      'id_session': id_Session,
    };

    final response = (await dio2.get('https://bunyan.qa/Users/profile_listing',
            queryParameters: params))
        .data;
    Map<String, dynamic> data = {};
    //PersonModel profileinfo;
    //profileinfo=PersonModel.fromJson(response['profile']);
    List<ProductModel> products = [];
    List<ServiceModel> services = [];
  /*  if (response != null) {
      if (ent.enterprise.type == '1') {
        products = [];
        List.of(response).forEach((element) {
          products.add(ProductModel.fromJson(element));
        });
        data['company_profile'] = ent.enterprise;
        data['profile'] = ent;
        data['listing'] = products;
      } else if (ent.enterprise.type == '2') {
        services = [];
        List.of(response).forEach((element) {
          //print('ayman $product');
          services.add(ServiceModel.fromJson(element));
        });
        data['company_profile'] = ent.enterprise;
        data['profile'] = ent;
        data['listing'] = services;
      }
    } else {
      data['company_profile'] = null;
      data['profile'] = null;
      data['listing'] = null;
    }*/

    return data;
  }

  Future<Map<String, dynamic>> getCompanyListing(
      PersonModel ent, EnterpriseModel comp) async {
    final dio2 = Dio();
    int id_Session = Res.USER != null ? Res.USER.id : null;
    Map<String, dynamic> params;
    if (ent != null) {
      params = {
        'selected_profile': ent.id ?? null,
        'company_id': ent.enterprise != null ? ent.enterprise.id : null,
        'id_session': id_Session,
      };
    } else if (comp != null) {
      params = {
        'selected_profile': null,
        'company_id': comp != null ? comp.id : null,
        'id_session': id_Session,
      };
    }

    //print(' hello here '+params.toString());

    final response = (await dio2.get('https://bunyan.qa/Users/entreprise_ads',
            queryParameters: params))
        .data;

    Map<String, dynamic> data = {};
    List<ProductModel> products = [];
    List<ServiceModel> services = [];

   /* if (response != null) {
      if (ent != null) {
        if (ent.enterprise.type == '1') {
          products = [];
          List.of(response).forEach((element) {
            products.add(ProductModel.fromJson(element));
          });
          data['company_profile'] = ent.enterprise;
          data['profile'] = ent;
          data['listing'] = products;
        } else if (ent.enterprise.type == '2') {
          services = [];
          List.of(response).forEach((element) {
            //print('ayman $product');
            services.add(ServiceModel.fromJson(element));
          });
          data['company_profile'] = ent.enterprise;
          data['profile'] = ent;
          data['listing'] = services;
        }
      } else if (comp != null) {
        if (comp.type == '1') {
          products = [];
          List.of(response).forEach((element) {
            products.add(ProductModel.fromJson(element));
          });
          data['company_profile'] = comp;
          data['profile'] = null;
          data['listing'] = products;
        } else if (comp.type == '2') {
          services = [];
          List.of(response).forEach((element) {
            //print('ayman $product');
            services.add(ServiceModel.fromJson(element));
          });
          data['company_profile'] = comp;
          data['profile'] = null;
          data['listing'] = services;
        }
      }
    } else {
      data['company_profile'] = null;
      data['profile'] = null;
      data['listing'] = null;
    }*/
    //print('Ayman company ${response}');
    return data;
  }

  Future<List<ChatModel>> getChats() async {
    final dio2 = Dio();
    final response =
        (await dio2.get('https://bunyan.qa/Users/chat/${Res.USER.id}')).data;
    List<ChatModel> chats = [];
    List.of(response).forEach((element) {
      chats.add(ChatModel.fromJson(element));
    });
    return chats;
  }

  Future<List<FavoriteModel>> getFav() async {
    final response = (await dio.get('favourite')).data;
    List<FavoriteModel> favs = [];
    List.of(response).forEach((element) {
      favs.add(FavoriteModel.fromJson(element));
    });
    return favs;
  }

  Future<List<ChatModel>> getConversation(ChatModel chat) async {
    final dio2 = Dio();
    final response = (await dio2.get(
            'https://bunyan.qa/Users/chat_message/${chat.sender.id}/${chat.receiver.id}'))
        .data;
    List<ChatModel> chats = [];

    List.of(response).forEach((element) {
      chats.add(ChatModel.fromJson(element));
    });

    return chats;
  }

  Future<EnterpriseModel> checkEnterprise(String crNumber) async {
    final dio2 = Dio();
    final response =
        (await dio2.get('https://bunyan.qa/Api/entreprise_id/$crNumber'))
            .data[0];

    return response == null ? null : EnterpriseModel.fromJson(response);
  }

  Future<bool> sendMessage({String text, int receiver}) async {
    final dio2 = Dio();

    final data = {
      'sender': Res.USER.id,
      'receiver': receiver,
      'content': Uri.encodeFull(text),
    };

    final response = (await dio2.get('https://bunyan.qa/Users/add_message',
            queryParameters: data))
        .data;
    return response['return'];
  }

  Future<bool> followEnterprise({int id}) async {
    final dio2 = Dio();
    final response = (await dio2.get(
            'https://bunyan.qa/Users/follow_entreprise/${Res.USER.id}/$id'))
        .data;
    return response['return'];
  }

  Future<bool> unfollowEnterprise({int id}) async {
    final dio2 = Dio();
    final response = (await dio2.get(
            'https://bunyan.qa/Users/unfollow_entreprise/${Res.USER.id}/$id'))
        .data;
    return response['return'];
  }

  Future updatePhotoProfile({int idsession, File profilePhoto}) async {
    final dio2 = Dio();
    // var photo = await MultipartFile.fromFile(profilePhoto);
    // final response = (await dio2.post(
    //         'https://bunyan.qa/Users/update_profile_photo',
    //         data: {'profile_photo': photo, 'idsession': idsession}))
    //     .data;
    //
    // return response['return'];

    FormData formData = FormData.fromMap({
      "profile_photo": await MultipartFile.fromFile(profilePhoto.path),
      'idsession': idsession
    });
    var response = await dio2
        .post("https://bunyan.qa/Users/update_profile_photo", data: formData);
    return response.data;
  }

  Future<bool> forgetPasswd(String email) async {
    final data = {'email': email};
    final response =
        (await dio.post('forgotPassword', data: data))
            .data;
    return true;
  }

  Future<bool> checkForgetPasswdCode({String mail, String code}) async {
    final dio2 = Dio();
    final data = FormData.fromMap({'email': mail, 'code': code});
    final response = (await dio2
            .post('https://bunyan.qa/Users/find_current_key_code', data: data))
        .data;
    return response['query'];
  }

  Future<bool> updateForgetPasswdCode(
      {String mail, String code, String passwd}) async {
    final dio2 = Dio();
    final data =
        FormData.fromMap({'email': mail, 'code': code, 'password': passwd});
    final response = (await dio2
            .post('https://bunyan.qa/Users/update_new_password', data: data))
        .data;
    return response['status'];
  }

  Future<bool> chekcodepin({String mail, String code}) async {
    final dio2 = Dio();
    final data = FormData.fromMap({'email': mail, 'code': code});
    final response = (await dio2
            .post('https://bunyan.qa/Users/find_current_key_code', data: data))
        .data;
    return response['query'];
  }

  Future<void> logout() async {
    await dio.post('logout');
  }

  Future<void> updateUser(PersonModel user) async {
    await dio.post('updateProfile', data: user.toUpdateRequest());
  }
  
  Future<bool> updatePassword() async {
    try {
      await dio.post('updatePassword', data: Res.USER.toUpdatePasswordRequest());
      return true;
    } on DioError catch(e) {
      print('errrrrorr issss ${e.response.data}');
      return false;
    }
  }

  void socialLogin(SocialMethod method, String token) {
    print('$method   $token');
  }

  Future<bool> deleteAccount() async {
    final response = (await dio.post('deleteAccount')).data;
    return true;
  }
}
