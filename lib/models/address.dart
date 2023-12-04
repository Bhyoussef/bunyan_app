import 'package:bunyan/tools/extensions.dart';

class AddressModel {
  int id;
  String name;

  AddressModel({this.id, this.name});

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json.get("id"),
      name: json.get("adr"),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": this.id,
      "adr": this.name,
    };
  }

//

}