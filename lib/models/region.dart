import 'package:bunyan/models/city.dart';
import 'package:equatable/equatable.dart';
import 'package:bunyan/tools/extensions.dart';
import 'package:flutter/material.dart';

class RegionModel extends Equatable {
  int id;
  String name;
  String nameAr;
  int properties_count;
  int services_count;
  List<CityModel> cities;


  RegionModel({this.id, this.name, this.nameAr, this.cities,this.properties_count,this.services_count});

  factory RegionModel.fromJson(Map<String, dynamic> json) {
    return RegionModel(
      id: int.parse(json["id"].toString()),
      name: json["name"],
      nameAr: json["name_ar"],
      properties_count:json.get("properties_count"),
      services_count:json.get("services_count"),
      cities: json.get('cities') != null
          ? List.of(json['cities'])
              .map((e) => CityModel.fromJson(json['cities'])).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": this.id,
      "name": this.name,
      "name_ar": this.nameAr,
      "properties_count": this.properties_count,
      "services_count": this.services_count,
      'cities': this.cities != null ? cities.map((e) => e.toJson()).toList() : null,
    };
  }

  @override
  List<Object> get props => [id];

  bool operator ==(dynamic other) =>
      other != null && other is RegionModel && (this.name == other.name || this.nameAr == other.nameAr);

  @override
  int get hashCode => super.hashCode;
}
