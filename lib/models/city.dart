import 'package:bunyan/tools/extensions.dart';
import 'package:equatable/equatable.dart';

class CityModel extends Equatable {

  int id;
  String name;
  String arabicName;
  int propertiesNumber;
  int servicesNumber;



  CityModel({this.id,
    this.name ,
    this.arabicName,
    this.propertiesNumber,
    this.servicesNumber,
  });

  @override
  List<Object> get props => [id,name,arabicName];

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: int.parse(json["id"].toString()),
      name: json["name"],
      arabicName: json['arabic_name'],
      propertiesNumber: json.get("properties_count"),
      servicesNumber: json.get("services_count"),


    );
  }


  Map<String, dynamic> toJson() {
    return {
      "id": this.id,
      "name": this.name,
      'arabic_name': this.arabicName,
      'properties_count':this.propertiesNumber,
      'services_count': this.servicesNumber,
    };
  }



}