import 'dart:convert';

import 'package:bunyan/models/category.dart';
import 'package:bunyan/models/city.dart';
import 'package:bunyan/models/enterprise.dart';
import 'package:bunyan/models/person.dart';
import 'package:bunyan/models/position.dart';
import 'package:bunyan/models/product_list.dart';
import 'package:bunyan/models/region.dart';
import 'package:bunyan/tools/extensions.dart';
import 'package:bunyan/tools/res.dart';

class ServiceModel extends ProductListModel {
  int id;
  String title;
  List<dynamic> photos;
  double price;
  String description;

  String descriptionAr;
  String ownerImage;
  String ownerName;
  String ownerEmail;
  String ownerPhone;
  EnterpriseModel enterprise;
  DateTime createdAt;
  bool favorite;
  bool isLiked;
  PositionModel position;
  String category;
  int categoryId;
  String categoryAr;
  String categorySlug;
  CityModel city;
  int likes;
  RegionModel region;
  dynamic adr;
  String views;
  String reference_id;
  double lat;
  double lng;
  String address;
  String titleAr;
  String slug;
  String ownerType;
  int ownerId;
  String phone;
  bool promoted;
  String email;
  bool status;
  String category_name;
  String promoted_for;

  ServiceModel(
      {this.id,
      this.title,
      this.photos,
      this.price,
      this.description,
      this.descriptionAr,
      this.slug,
      this.ownerImage,
      this.ownerName,
      this.ownerEmail,
      this.enterprise,
      this.createdAt,
      this.favorite,
      this.position,
      this.category,
      this.city,
      this.isLiked,
      this.region,
      this.likes,
      this.adr,
      this.views,
      this.reference_id,
      this.lat,
      this.lng,
      this.address,
      this.titleAr,
      this.ownerType,
      this.ownerId,
        this.promoted_for,
        this.phone,
        this.categoryId,
        this.categorySlug,
        this.categoryAr,
        this.promoted,
        this.ownerPhone,
        this.email,
        this.status,
        this.category_name
      });

  bool get isCompany => this.ownerType == 'Company';

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json["id"],
      title: json["title"],

      titleAr: json["title_ar"] ?? '',
      photos: json["images"] != null
          ? List.of(json["images"]).map<String>((i) => i['image']).toList()
          : [],
      slug: json['slug'],
      price: double.parse(json["price"].toString()),
      description: json["description"],
      descriptionAr: json["description_ar"],
      promoted_for: json["promoted_for"],
      address: json.get("address"),
      reference_id: json.get("reference_id"),
      ownerImage: json["user_image"],
      ownerName: json["user_name"],
      ownerEmail: json["email"],
      category: json.get('category_name'),
      categoryId: int.tryParse(json.get('category_id').toString()),
      categoryAr: json.get('category_name_ar'),
      categorySlug: json.get('category_slug'),
      promoted: (json.get('promoted') ?? '') == 'Promoted',
      ownerType: json['user_type'],
      enterprise: json.get('enterprise') != null
          ? EnterpriseModel.fromJson(json["enterprise"])
          : PersonModel.fromJson(json.get('owner')).enterprise != null
              ? PersonModel.fromJson(json.get('owner')).enterprise
              : null,
      createdAt: json.get('updated_at') != null
          ? DateTime.parse(json.get('updated_at'))
          : null,
      favorite: json['is_favorit'],
      isLiked: json.get('is_liked') ?? false,
      views: json['views'].toString(),
      lat: json['lat'] != null ? double.parse(json['lat']) : 0,
      lng: json['lng'] != null ? double.parse(json['lng']) : 0,
      likes: int.tryParse(json.get('likes').toString()),
      region: json.get('region_name') != null
          ? RegionModel(nameAr: json['region_name_ar'], name: json['region_name'])
          : null,
      ownerId: json['user_id'],
      ownerPhone: json.get('user_phone').toString(),
      email: json['email'],
      phone: json['phone'],
      status: (json.get('status') ?? 'Pending') != 'Pending',
      category_name: json["category_name"],
    );
  }


  Map<String, dynamic> toJson() {
    return {
      "id": this.id,
      "title": this.title,
      "title_arabic": this.titleAr,
      "photos": jsonEncode(this.photos),
      "price": this.price,
      "description": this.description,
      "owner": this.owner,
      "enterprise": this.enterprise,
      'add_date': this.createdAt.toIso8601String(),
      'is_favorit': this.favorite,
      'position': this.position?.toJson(),
      'is_liked': this.isLiked,
      'promoted_for': this.promoted_for,
      'likes': this.likes,
      'views': this.views,
      "reference_id": this.reference_id,
      'lat': this.lat.toString(),
      'lng': this.lng.toString(),
      "address": this.address,
      'slug': this.slug,
      'user_type': this.ownerType,
      'user_id': this.ownerId,
      "user_phone": this.ownerPhone,
      "category_name": this.category,
      'category_name_ar': this.categoryAr,
      'category_slug': this.categorySlug,
      'category_id': this.categoryId,
      'promoted': this.promoted ?? false,
      'region_name': this.region?.name,
      'region_name_ar': this.region?.nameAr,
      'status': this.status ? 'Finished' : 'Pending',
      'category_name': this.category_name,
    };
  }

  Map<String, dynamic> toRequest() {
    return {
      "title": this.title,
      "title_ar": this.titleAr,
      'category_id': this.categoryId,
      "price": this.price,
      'email': Res.USER.email,
      'phone': Res.USER.phone,
      "description": this.description,
      'description_ar': this.descriptionAr,
      'address': this.address,
      'region_id': this.region.id,
      'lat': this.position?.lat,
      'lng': this.position?.lng,
    };
  }
}
