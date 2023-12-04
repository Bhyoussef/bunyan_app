class Pakage {
  int id;
  String name;
  int price;
  String difference;
  String type;
  int ads;
  String status;
  String createdAt;
  String updatedAt;

  Pakage(
      {this.id,
        this.name,
        this.price,
        this.difference,
        this.type,
        this.ads,
        this.status,
        this.createdAt,
        this.updatedAt});

  Pakage.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    price = json['price'];
    difference = json['difference'];
    type = json['type'];
    ads = json['ads'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['price'] = this.price;
    data['difference'] = this.difference;
    data['type'] = this.type;
    data['ads'] = this.ads;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}