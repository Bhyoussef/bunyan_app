import 'package:bunyan/models/banner.dart';
import 'package:bunyan/models/product.dart';
import 'package:bunyan/models/service.dart';

class PassthroughHome {
  List<ProductModel> products;
  List<ProductModel> premiumProducts;
  List<ServiceModel> services;
  List<ServiceModel> premiumServices;
  List<BannerModel> banners;
  List<BannerModel> serviceBanners;

  PassthroughHome(
      {this.products,
      this.premiumProducts,
      this.services,
      this.premiumServices,
      this.banners,
      this.serviceBanners});
}
