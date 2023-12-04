import 'dart:convert';

import 'package:bunyan/models/address.dart';
import 'package:bunyan/models/city.dart';
import 'package:bunyan/models/enterprise.dart';
import 'package:bunyan/models/person.dart';
import 'package:bunyan/models/position.dart';
import 'package:bunyan/models/product_list.dart';
import 'package:bunyan/models/real_estate_type.dart';
import 'package:bunyan/models/region.dart';
import 'package:bunyan/tools/extensions.dart';
import 'package:bunyan/tools/res.dart';

class ProductModel extends ProductListModel {
  int id;
  String title;
  double price;
  String currency;
  String description;
  String descriptionAr;
  bool forSell;
  bool furnished;
  String reference_id;
  DateTime createdAt;
  List<dynamic> photos;
  String category;
  int categoryId;
  String categoryAr;
  String categorySlug;
  EnterpriseModel enterprise;
  String ownerImage;
  String ownerName;
  String ownerPhone;
  String ownerEmail;
  String email;
  String furnish;
  bool status;
  dynamic adr;
  bool favorite;
  int bathrooms;
  String landSize;
  int rooms;
  bool isLiked;
  String slug;
  PositionModel position;
  RegionModel region;
  CityModel city;
  bool swimmingPool;
  RealEstateTypeModel type;
  String views;
  double lat;
  double lng;
  String adress;
  String titleAr;
  String ownerType;
  bool isreported;
  int ownerId;
  String phone;
  bool promoted;
  bool forRent = false;
  String category_name;
  String promoted_for;

  ProductModel({
    this.id,
    this.title,
    this.price,
    this.currency,
    this.description,
    this.descriptionAr,
    this.forSell,
    this.reference_id,
    this.createdAt,
    this.photos,
    this.category,
    this.ownerImage,
    this.ownerName,
    this.ownerEmail,
    this.adr,
    this.furnish,
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
    this.lat,
    this.lng,
    this.adress,
    this.titleAr,
    this.ownerType,
    this.isreported,
    this.slug,
    this.ownerId,
    this.phone,
    this.categoryAr,
    this.categorySlug,
    this.categoryId,
    this.promoted,
    this.email,
    this.ownerPhone,
    this.status,
    this.forRent,
    this.category_name,
    this.promoted_for
  }) {
    this.photos = photos ?? [];
  }

  bool get isCompany => ownerType == 'Company';

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    try {
      return ProductModel(
        id: json["id"],
        title: json["title"],
        furnish: json["furnish"],
        titleAr: json["title_ar"] ?? '',
        price: double.parse(json["price"].toString()),
        currency: 'QR',
        slug: json['slug'],
        region: json.get('region_name') != null
            ? RegionModel(
            name: json.get('region_name'), nameAr: json.get('region_name_ar'))
            : null,
        ownerType: json['user_type'],
        description: json["description"],
        promoted_for: json["promoted_for"],
        descriptionAr: json["description_ar"],
        forSell: json["type"] == "Rent" ? false : true,
        reference_id: json["reference_id"],
        createdAt: json["updated_at"] != null
            ? DateTime.parse(json["updated_at"])
            : null,
        photos: json["images"] != null
            ? List.of(json["images"]).map<String>((i) => i['image']).toList()
            : [],
        category: json.get('category_name'),
        categoryId: json.get('category_id'),
        categoryAr: json.get('category_name_ar'),
        categorySlug: json.get('category_slug'),
        promoted: (json.get('promoted') ?? '') == 'Promoted',
        ownerImage: json["user_image"],
        ownerName: json["user_name"],
        ownerEmail: json["user_email"],
        email: json['email'],
        adr: AddressModel.fromJson(json.get("adresse")),
        furnished: int.parse((json.get('furnished') ?? 0).toString()) != 0,
        enterprise: json.get('entreprise') != null
            ? EnterpriseModel.fromJson(json['entreprise'])
            : PersonModel
            .fromJson(json.get("owner"))
            .enterprise != null
            ? PersonModel
            .fromJson(json.get("owner"))
            .enterprise
            : null,
        favorite: json['is_favorit'],
        bathrooms: json['bathrooms'],
        landSize: json.get('land'),
        rooms: int.tryParse(json.get('rooms').toString()) ??
            int.tryParse(json.get('bedrooms').toString()) ?? 0,
        isLiked: json.get('is_liked') ?? false,
        position: PositionModel.fromJson(json.get('position')),
        views: json['views'].toString(),
        lat: json['lat'] != null ? double.parse(json['lat']) : 0,
        lng: json['lng'] != null ? double.parse(json['lng']) : 0,
        adress: json.get("address"),
        isreported: json.get('is_reported') ?? false,
        ownerId: json['user_id'],
        ownerPhone: json.get('user_phone').toString(),
        phone: json.get('phone').toString(),
        status: (json.get('status') ?? 'Pending') != 'Pending',
        forRent: (json.get('type') ?? 'Sale') == 'Rent',
        category_name: json["category_name"],
      );
    } catch(e) {
      print(e);
      print('error was in ${json['id']}');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "id": this.id,
      "name": this.title,
      "title_ar": this.titleAr,
      "furnish": this.furnish,
      "price": this.price,
      'region_name': this.region.name,
      'region_name_ar': this.region.nameAr,
      "currency": this.currency,
      "description": this.description,
      "description_ar": this.descriptionAr,
      "for_sell": this.forSell,
      "reference_id": this.reference_id,
      "promoted_for": this.promoted_for,
      "create_at": this.createdAt.toIso8601String(),
      "photos": jsonEncode(this.photos),
      "category_name": this.category,
      'category_name_ar': this.categoryAr,
      'category_slug': this.categorySlug,
      'category_id': this.categoryId,
      'promoted': this.promoted ?? false,
      "owner": this.owner?.toJson(),
      "furnished": this.furnished ? "1" : "0",
      'enterprise': this.enterprise != null
          ? this.enterprise.toJson()
          : this.owner?.enterprise != null
              ? this.owner.enterprise?.toJson()
              : null,
      'position': this.position?.toJson(),
      'favorite': this.favorite,
      'bathrooms': this.bathrooms.toString(),
      'land': this.landSize,
      'rooms': this.rooms.toString(),
      'is_liked': this.isLiked,
      'views': this.views,
      'lat': this.lat.toString(),
      'lng': this.lng.toString(),
      "address": this.adress.toString(),
      'is_reported': this.isreported,
      'slug': this.slug,
      'user_type': this.ownerType,
      'user_id': this.ownerId,
      'user_phone': this.ownerPhone,
      'user_email': this.ownerEmail,
      'email': this.email,
      'phone': this.phone,
      'status': this.status ? 'Finished' : 'Pending',
      'category_name': this.category_name,
    };
  }

  Map<String, dynamic> toRequest() {
    return {
      "title": this.title,
      "title_ar": titleAr,
      "price": this.price,
      "description": this.description,
      "description_ar": this.descriptionAr,
      "habitate_size": this.landSize,
      "for_sell": this.forSell,
      "reference_id": this.reference_id,
      "email": Res.USER.email,
      "phone": Res.USER.phone,
      "category_id": this.categoryId,
      "address": this.adr,
      "furnish": this.furnish,
      'lat': this.position?.lat,
      'lng': this.position?.lng,
      'bathrooms': this.bathrooms.toString(),
      'land': this.landSize,
      'bedrooms': this.rooms.toString(),
      'region_id': this.region.id,
      //'features': this.swimmingPool ? ['swimmingpool'] : [],
      'payement_type': null,
      'swimming_pool': this.swimmingPool ? '1' : '0',
      'views': this.views,
      "address": this.adress,
      'type': (forRent ?? false) ? 'Rent' : 'Sale',
      'deposit': 'None',
      'commission': 'None',
    };
  }
}
