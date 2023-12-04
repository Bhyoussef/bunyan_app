import 'package:bunyan/tools/extensions.dart';

class BannerModel {
  int id;
  String photo;

  BannerModel({this.id = 0, this.photo});

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: 0,
      photo: json.get("image"),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": 0,
      "url": this.photo,
    };
  }
}