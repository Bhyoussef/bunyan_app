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

abstract class ProductListModel with EquatableMixin {
  int id;
  String title;
  double price;
  String currency;
  String description;
  bool forSell;
  bool furnished;
  String reference;
  DateTime createdAt;
  List<dynamic> photos;
  String category;
  EnterpriseModel enterprise;
  PersonModel owner;
  dynamic adr;
  bool favorite;
  int bathrooms;
  String landSize;
  int rooms;
  bool isLiked;
  bool promoted;
  PositionModel position;
  RegionModel region;
  CityModel city;
  bool swimmingPool;
  RealEstateTypeModel type;
  String views;
  String titleAr;
  String slug;
  String ownerImage;
  bool status;
  String promoted_for;

  ProductListModel(
      {this.id,
      this.title,
      this.price,
      this.currency,
      this.description,
      this.forSell,
      this.reference,
      this.createdAt,
      this.photos,
      this.category,
      this.owner,
      this.adr,
      this.furnished,
      this.enterprise,
      this.favorite,
      this.bathrooms,
      this.landSize,
      this.rooms,
      this.isLiked,
      this.position,
      this.region,
      this.city,
      this.swimmingPool,
      this.type,
      this.views,
        this.titleAr,
      this.slug,
      this.promoted,this.promoted_for});

  ProductListModel.fromJson(Map<String, dynamic> json){}

  Map<String, dynamic> toJson() {}

  @override
  List<Object> get props => [id];
}
