import 'package:bunyan/tools/extensions.dart';
import 'package:equatable/equatable.dart';

class RealEstateTypeModel extends Equatable {

  int id;
  String name;
  String arabicName;
  int ads_nbr;


  RealEstateTypeModel({this.id, this.name,this.arabicName,this.ads_nbr});


  factory RealEstateTypeModel.fromJson(Map<String, dynamic> json) {
    return RealEstateTypeModel(
      id: int.parse(json["id"].toString()),
      name: json["name"],
      arabicName: json['arabic_name'],
      ads_nbr: json.get('ads_nbr'),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      "id": this.id,
      "name": this.name,
      'arabic_name': this.arabicName,
      'ads_nbr':this.ads_nbr,
    };
  }

  @override
  List<Object> get props => [id];



}