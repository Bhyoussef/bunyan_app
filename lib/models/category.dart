import 'package:bunyan/tools/extensions.dart';

class CategoryModel {
  int id;
  String name;
  String arabicName;
  String photo;
   int properties_count;
   int services_count;

  CategoryModel({this.id,
    this.name,
    this.photo,
    this.arabicName,
     this.properties_count,
    this.services_count
  });

  Map<String, dynamic> toJson() {
    return {
      "id": this.id,
      "name": this.name,
      "photo": this.photo,
      'arabic_name': this.arabicName,
       'properties_count': this.properties_count,
      'services_count': this.services_count,

    };
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json.get("id"),
      name: json.get("name"),
      photo: json.get("image"),
      arabicName: json['name_ar'],
      properties_count: json.get('properties_count'),
      services_count: json.get('services_count'),
    );
  }

}