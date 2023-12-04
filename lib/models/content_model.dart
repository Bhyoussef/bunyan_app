class Content {
  String title;
  String titleAr;
  String description;
  String descriptionAr;

  Content({this.title, this.titleAr, this.description, this.descriptionAr});

  Content.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    titleAr = json['title_ar'];
    description = json['description'];
    descriptionAr = json['description_ar'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['title_ar'] = this.titleAr;
    data['description'] = this.description;
    data['description_ar'] = this.descriptionAr;
    return data;
  }
}