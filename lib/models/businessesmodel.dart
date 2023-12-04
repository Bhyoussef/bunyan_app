class Busnisscategory {
  int id;
  String name;
  String nameAr;
  String image;
  List<Children> children;

  Busnisscategory({this.id, this.name, this.nameAr, this.image, this.children});

  Busnisscategory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    nameAr = json['name_ar'];
    image = json['image'];
    if (json['children'] != null) {
      children = <Children>[];
      json['children'].forEach((v) {
        children.add(new Children.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['name_ar'] = this.nameAr;
    data['image'] = this.image;
    if (this.children != null) {
      data['children'] = this.children.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Children {
  int id;
  String name;
  String nameAr;
  String image;
  int parentId;
  int propertiesCount;
  int servicesCount;

  Children(
      {this.id,
        this.name,
        this.nameAr,
        this.image,
        this.parentId,
        this.propertiesCount,
        this.servicesCount});

  Children.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    nameAr = json['name_ar'];
    image = json['image'];
    parentId = json['parent_id'];
    propertiesCount = json['properties_count'];
    servicesCount = json['services_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['name_ar'] = this.nameAr;
    data['image'] = this.image;
    data['parent_id'] = this.parentId;
    data['properties_count'] = this.propertiesCount;
    data['services_count'] = this.servicesCount;
    return data;
  }
}