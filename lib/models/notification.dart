import 'dart:convert';

import 'package:bunyan/models/person.dart';
import 'package:bunyan/models/product.dart';
import 'package:date_format/date_format.dart';
import 'package:equatable/equatable.dart';

class NotificationModel with EquatableMixin {

  int id;
  String title;
  String slug;
  DateTime createdAt;



  NotificationModel({this.id, this.title, this.slug, this.createdAt});


  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: int.parse(json["id"].toString()),
      title: jsonDecode(json["data"].toString().replaceAll('\\', ''))['letter']['title'],
      slug: jsonDecode(json["data"].toString().replaceAll('\\', ''))['letter']['slug'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      "id": this.id,
      "data": {'letter': {'title': title, 'slug': slug}},
      'created_at': formatDate(createdAt, [yyyy, '-', mm, '-', dd, 'T', hh, ':', nn]),
    };
  }

  @override
  List<Object> get props => [id];

}