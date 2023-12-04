import 'package:equatable/equatable.dart';

class CityModel extends Equatable {
  int id;
  String name;


  CityModel({this.id, this.name});
  @override
  List<Object> get props => [id,name];

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: int.parse(json["id"]),
      name: json["name"],
    );
  }


  Map<String, dynamic> toJson() {
    return {
      "id": this.id,
      "name": this.name,
    };
  }

  //@override
  //List<Object> get props => [id];

}