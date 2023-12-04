import 'dart:convert';

import 'package:bunyan/models/address.dart';
import 'package:bunyan/models/person.dart';
import 'package:bunyan/models/position.dart';
import 'package:bunyan/models/real_estate_type.dart';
import 'package:bunyan/models/region.dart';
import 'package:bunyan/tools/extensions.dart';
import 'package:equatable/equatable.dart';

import 'category.dart';
import 'city.dart';
import 'enterprise.dart';

class ServiceListModel with EquatableMixin {
  int id;
  String title;
  double price;
  String currency;
  String description;
  String reference;
  DateTime createdAt;
  List<dynamic> photos;
  CategoryModel category;
  EnterpriseModel enterprise;
  PersonModel owner;
  dynamic adr;
  bool favorite;
  bool isLiked;
  PositionModel position;
  RegionModel region;
  CityModel city;
  RealEstateTypeModel type;
  String views;

  ServiceListModel(
      {this.id,
      this.title,
      this.price,
      this.currency,
      this.description,
      this.reference,
      this.createdAt,
      this.photos,
      this.category,
      this.owner,
      this.adr,
      this.enterprise,
      this.favorite,
      this.isLiked,
      this.position,
      this.region,
      this.city,
      this.type,
      this.views});

  factory ServiceListModel.fromJson(Map<String, dynamic> json) {
    print('json $json');
    return ServiceListModel(
      id: int.parse(json.get("id")),
      title: json.get("name"),
      price: double.parse(json.get("price")),
      currency: json.get("currency"),
      description: json.get("description"),
      reference: json.get("reference"),
      createdAt: DateTime.parse(json.get("created_at")),
      photos: List.of(json.get("photos")).map<String>((i) => i).toList(),
      category: CategoryModel.fromJson(json.get("category_id")),
      owner: json.get('owner') == null
          ? null
          : PersonModel.fromJson(json.get("owner")),
      adr: AddressModel.fromJson(json.get("adresse")),
      enterprise: json.get('entreprise') != null
          ? EnterpriseModel.fromJson(json['entreprise'])
          : PersonModel.fromJson(json.get("owner")).enterprise != null
              ? PersonModel.fromJson(json.get("owner")).enterprise
              : null,
      favorite: json['is_favorit'],
      isLiked: json.get('is_liked') ?? false,
      position: PositionModel.fromJson(json.get('position')),
      views: json.get("views"),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": this.id,
      "name": this.title,
      "price": this.price,
      "currency": this.currency,
      "description": this.description,
      "reference": this.reference,
      "create_at": this.createdAt.toIso8601String(),
      "photos": jsonEncode(this.photos),
      "category_id": this.category,
      "owner": this.owner?.toJson(),
      "adresse": this.adr,
      'enterprise': this.enterprise != null
          ? this.enterprise.toJson()
          : this.owner?.enterprise != null
              ? this.owner.enterprise?.toJson()
              : null,
      'position': this.position?.toJson(),
      'favorite': this.favorite,
      'is_liked': this.isLiked,
      'views': this.views,
    };
  }

  @override
  List<Object> get props => [id];
}
