import 'package:bunyan/models/category.dart';
import 'package:bunyan/models/real_estate_type.dart';
import 'package:bunyan/tools/res.dart';
import 'package:equatable/equatable.dart';
import 'package:bunyan/tools/extensions.dart';

class ServicesFilter {
  int page;
  CategoryModel category;
  double minPrice;
  double maxPrice;
  String query;
  int id_session;
  bool promoted;

  ServicesFilter(
      {this.page = 1,
      this.category,
      this.minPrice,
      this.maxPrice,
      this.query,
      this.id_session});

  factory ServicesFilter.fromJson(Map<String, dynamic> json) {
    return ServicesFilter(
      page: json.get("page") == null
          ? null
          : int.parse(json.get("page").toString()),
      category: json.get("category") == null
          ? null
          : CategoryModel.fromJson(json.get("category")),
      minPrice: json.get("minPrice") == null
          ? null
          : double.parse(json.get("minPrice").toString()),
      maxPrice: json.get("maxPrice") == null
          ? null
          : double.parse(json.get("maxPrice").toString()),
      query: json.get('query') == null ? null : json.get('query'),
      id_session: json.get('id_session') == null ? null : json.get('id_session'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "page": this.page,
      "category": this.category?.toJson(),
      "minPrice": this.minPrice,
      "maxPrice": this.maxPrice,
      'query': this.query,
      'id_session':this.id_session,
    };
  }

  Map<String, dynamic> _toRequest() {
    //var userid=(Res.USER!=null) ? Res.USER.id : null;
    return {
      "page": this.page?.toString(),
      "category_id": this.category?.id,
      "min_price": this.minPrice?.toString(),
      "max_price": this.maxPrice?.toString(),
      "query" :this.query,
      "userid": (Res.USER!=null) ? Res.USER.id : null,
      "id_session":(Res.USER!=null) ? Res.USER.id : null
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
