import 'package:bunyan/tools/extensions.dart';
import 'package:bunyan/tools/res.dart';

class NewsModel {
  int id;
  String title;
  String titleArabic;
  String photo;
  String description;
  String descAr;
  String url;
  String date;
  bool isFeatured;

  NewsModel({this.id, this.title, this.photo, this.description, this.url,this.date,this.titleArabic, this.descAr, this.isFeatured});

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
        id: int.parse(json.get("id").toString()),
        title: json.get("title"),
        titleArabic: json.get("title_ar"),
        date: json.get("date"),
        description: json.get("description"),
        url: json.get("slug").toString().startsWith('http') ? json.get("slug") : '${Res.host}blogs/${json.get('slug')}',
        photo: json.get('image').toString().startsWith('http') ? json.get('image') : '${Res.host}images/blogs/${json.get('image')}',
      descAr: json.get('description_ar'),
      isFeatured: (json.get('is_feature') ?? 'No') != 'No'
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": this.id,
      "title": this.title,
      "title_ar":this.titleArabic,
      "date": this.date,
      "image": this.photo,
      "contents": this.description,
      "slug": this.url,
      "description_ar": this.descAr,
      "is_feature": isFeatured ? 'Yes' : 'No',
    };
  }
}