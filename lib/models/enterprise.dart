class EnterpriseModel {
  int id;
  String name;
  String nameAr;
  String email;
  String code;
  int phone;
  String crNumber;
  String address;
  double lat;
  double lng;
  String image;
  Null website;
  int views;
  String description;
  String descriptionAr;
  String updatedAt;
  String regionName;
  String regionNameAr;
  List<Images> images;
  List<Products> products;
  String type;
  int nbr_services;
  int nbr_sell;
  int nbr_rent;
  int nbr_request;

  EnterpriseModel(
      {this.id,
        this.name,
        this.nameAr,
        this.email,
        this.code,
        this.phone,
        this.crNumber,
        this.address,
        this.lat,
        this.lng,
        this.image,
        this.website,
        this.views,
        this.description,
        this.descriptionAr,
        this.updatedAt,
        this.regionName,
        this.regionNameAr,
        this.images,
        this.products});

  EnterpriseModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    nameAr = json['name_ar'];
    email = json['email'];
    code = json['code'];
    phone = json['phone'];
    crNumber = json['cr_number'];
    nbr_services = json['phone'];
    address = json['address'];
    lat = json['lat'];
    lng = json['lng'];
    image = json['image'];

    views = json['views'];
    description = json['description'];
    descriptionAr = json['description_ar'];
    updatedAt = json['updated_at'];
    regionName = json['region_name'];
    regionNameAr = json['region_name_ar'];
    if (json['images'] != null) {
      images = <Null>[];
      json['images'].forEach((v) {
        images.add(new Images.fromJson(v));
      });
    }
    if (json['products'] != null) {
      products = <Products>[];
      json['products'].forEach((v) {
        products.add(new Products.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['name_ar'] = this.nameAr;
    data['email'] = this.email;
    data['code'] = this.code;
    data['phone'] = this.phone;
    data['cr_number'] = this.crNumber;
    data['address'] = this.address;
    data['lat'] = this.lat;
    data['lng'] = this.lng;
    data['image'] = this.image;
    data['website'] = this.website;
    data['views'] = this.views;
    data['description'] = this.description;
    data['description_ar'] = this.descriptionAr;
    data['updated_at'] = this.updatedAt;
    data['region_name'] = this.regionName;
    data['region_name_ar'] = this.regionNameAr;
    if (this.images != null) {
      data['images'] = this.images.map((v) => v.toJson()).toList();
    }
    if (this.products != null) {
      data['products'] = this.products.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Products {
  int id;
  String title;
  String titleAr;
  int priceStartFrom;
  int price;
  Null description;
  List<Images> images;

  Products(
      {this.id,
        this.title,
        this.titleAr,
        this.priceStartFrom,
        this.price,
        this.description,
        this.images});

  Products.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    titleAr = json['title_ar'];
    priceStartFrom = json['price_start_from'];
    price = json['price'];
    description = json['description'];
    if (json['images'] != null) {
      images = <Images>[];
      json['images'].forEach((v) {
        images.add(new Images.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['title_ar'] = this.titleAr;
    data['price_start_from'] = this.priceStartFrom;
    data['price'] = this.price;
    data['description'] = this.description;
    if (this.images != null) {
      data['images'] = this.images.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Images {
  int id;
  String image;

  Images({this.id, this.image});

  Images.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['image'] = this.image;
    return data;
  }
}