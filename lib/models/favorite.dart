import 'dart:convert';

import 'package:bunyan/models/product.dart';
import 'package:bunyan/models/service.dart';
import 'package:equatable/equatable.dart';

class FavoriteModel {
  List<ProductModel> products;
  List<ServiceModel> services;

  FavoriteModel({this.products, this.services});

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      products: List.of(json["properties"])
          .map((i) => ProductModel.fromJson(i))
          .toList(),
      services: List.of(json["services"])
          .map((i) => ServiceModel.fromJson(i))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "products": jsonEncode(this.products.map((e) => e.toJson()).toList()),
      "services": jsonEncode(this.services.map((e) => e.toJson()).toList()),
    };
  }
}