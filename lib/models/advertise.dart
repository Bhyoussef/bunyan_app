import 'package:bunyan/tools/res.dart';

class Advertise {
  int id;
  String image;

  Advertise({this.id, this.image});

  factory Advertise.fromJson(Map<String, dynamic> json) {
    return Advertise(
      id: int.parse(json['id_ban'].toString()),
      image: json['image_ban'].toString().startsWith('http')
          ? json['image_ban']
          : Res.baseUrl + 'images/' + json['image_ban'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id_ban'] = this.id.toString();
    data['image_ban'] = this.image;
    return data;
  }
}