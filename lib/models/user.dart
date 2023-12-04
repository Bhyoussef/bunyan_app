import 'package:equatable/equatable.dart';
import 'package:bunyan/tools/extensions.dart';

class UserModel extends Equatable {

  int id;
  String name;
  String email;
  String photo;
  String phone;
  int followers;
  bool isFollowing;


  UserModel({this.id, this.name, this.email, this.photo, this.phone, this.followers, this.isFollowing});


  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: int.parse(json["id"].toString()),
      name: json["name"],
      photo: json.get('photo'),
      phone: json.get('phone'),
      email: json["email"],
      followers: json.get('followers_number'),
      isFollowing: json.get('is_following'),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      "id": this.id.toString(),
      "name": this.name,
      "email": this.email,
      "photo": this.photo,
      'phone': this.phone,
      'is_following': this.isFollowing,
      'followers_number': this.followers,
    };
  }

  @override
  List<Object> get props => [id];

}