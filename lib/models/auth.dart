import 'dart:io';

class AuthModel {
  String name;
  String company_name;
  String mail;
  String phone;
  String passwd;
  String confirm_passwd;
  String type;
  String crNumber;
  String entrMail;
  String entrDesc;
  String entrName;
  String entrAdr;
  String entrPhone;
  String entrLat;
  String entrLng;
  File profilePicture;
  File entrPhoto;

  AuthModel(
      {this.name,
        this.company_name,
        this.mail,
        this.phone,
        this.passwd,
        this.confirm_passwd,
        this.type,
        this.crNumber,
        this.entrMail,
        this.entrDesc,
        this.entrName,
        this.entrAdr,
        this.entrPhone,
        this.entrLat,
        this.entrLng,
        this.profilePicture,
        this.entrPhoto});

  Map<String, dynamic> _toRequest() {
    return {
      "name": this.name,
      "company_name": this.company_name,
      "email": this.mail,
      "phone": this.phone,
      "password": this.passwd,
      "password_confirmation": this.confirm_passwd,
      "user_type": this.type,
      "cr_number": this.crNumber,
      "entreprize_email": this.entrMail,
      "entreprize_desc": this.entrDesc,
      "entreprize_name": this.entrName,
      "entreprize_address": this.entrAdr,
      "entreprize_phone": this.entrPhone,
      "entreprize_lat": this.entrLat,
      "entreprize_lng": this.entrLng,
      "profile_photo": this.profilePicture,
      'entreprize_photo': this.entrPhoto,
    };
  }

  Map<String, dynamic> toRequest() {
    Map<String, dynamic> request = this._toRequest();
    List<String> keys = [];
    request.keys.forEach((key) {
      if (request[key] != null || request[key].toString().isEmpty)
        keys.add(key);
    });
    Map<String, dynamic> response = Map();
    keys.forEach((key) {
      response[key] = request[key];
    });
    return response.isNotEmpty ? response : null;
  }
}
