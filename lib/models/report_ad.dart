import 'package:bunyan/tools/webservices/products.dart';

class ReportAdModel {
  String name;
  String email;
  String phone;
  String message;
  String slug;
  int type;

  ReportAdModel({this.name, this.email, this.phone, this.message, this.slug, this.type}){
    this.slug = 'https://bunyan.qa/${type == ProductsWebService.REAL_ESTATE ? 'property' : 'service'}/$slug';
  }

  Map<String, dynamic> toJson() {
    return {
      'name': this.name,
      'email': this.email,
      'phone': this.phone,
      'message': this.message,
      'slug': this.slug
    };
  }
}