import 'package:bunyan/models/category.dart';
import 'package:bunyan/models/real_estate_type.dart';
import 'package:bunyan/tools/extensions.dart';

class RealEstateFilterModel {
  int page;
  CategoryModel category;
  RealEstateTypeModel type;
  double minPrice;
  double maxPrice;
  int livingRooms;
  double minLand;
  double maxLand;
  bool swimmingPool;
  int bathRooms;
  bool furnished;
  String query;
  String adTitle;

  RealEstateFilterModel({
    this.page = 1,
    this.category,
    this.type,
    this.minPrice,
    this.maxPrice,
    this.livingRooms,
    this.minLand,
    this.maxLand,
    this.swimmingPool,
    this.bathRooms,
    this.furnished,
    this.query,
    this.adTitle = '',
  });

  factory RealEstateFilterModel.fromJson(Map<String, dynamic> json) {
    return RealEstateFilterModel(
      page: json.get("page") == null
          ? null
          : int.parse(json.get("page").toString()),
      category: json.get("category") == null
          ? null
          : CategoryModel.fromJson(json.get("category")),
      type: json.get("type") == null
          ? null
          : RealEstateTypeModel.fromJson(json.get("type")),
      minPrice: json.get("minPrice") == null
          ? null
          : double.parse(json.get("minPrice").toString()),
      maxPrice: json.get("maxPrice") == null
          ? null
          : double.parse(json.get("maxPrice").toString()),
      livingRooms: json.get("livingRooms") == null
          ? null
          : int.parse(json.get("livingRooms").toString()),
      minLand: json.get("minLand") == null
          ? null
          : double.parse(json.get("minLand").toString()),
      maxLand: json.get("maxLand") == null
          ? null
          : double.parse(json.get("maxLand").toString()),
      swimmingPool:
          json.get("swimmingPool") == null ? null : json.get("swimmingPool"),
      bathRooms: json.get("bathRooms") == null
          ? null
          : int.parse(json.get("bathRooms").toString()),
      furnished: json.get("furnished") == null ? null : json.get("furnished"),
      query: json.get('query') == null ? null : json.get('query'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "page": this.page,
      "category": this.category?.toJson(),
      "type": this.type?.toJson(),
      "minPrice": this.minPrice,
      "maxPrice": this.maxPrice,
      "livingRooms": this.livingRooms,
      "minLand": this.minLand,
      "maxLand": this.maxLand,
      "swimmingPool": this.swimmingPool,
      "bathRooms": this.bathRooms,
      "furnished": this.furnished,
      'query': this.query,
    };
  }

  Map<String, dynamic> _toRequest() {
    return {
      "page": this.page?.toString(),
      "category_id": this.category?.id,
      "type": this.type?.id,
      "min_price": this.minPrice?.toString(),
      "max_price": this.maxPrice?.toString(),
      "livingrooms": this.livingRooms?.toString(),
      "min_land": this.minLand?.toString(),
      "max_land": this.maxLand?.toString(),
      "swimmingpool": this.swimmingPool == null
          ? null
          : this.swimmingPool
              ? "1"
              : "0",
      "bathrooms": this.bathRooms?.toString(),
      "furnished": this.furnished == null
          ? null
          : this.furnished
              ? '1'
              : '0',
      "query": this.query,
      "ad_title": this.adTitle,
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

//

}
